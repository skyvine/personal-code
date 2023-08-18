; Copyright 2023 Skyler Ferris
;
; This program is free software: you can redsitribute it and/or modify it under the terms
; of the GNU Affero General Public License as published by the Free Software Foundation,
; either version 3 of the License or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful, but WITHOUT ANY
; WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
; PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
;
; You should have received a copy of the GNU Affero General Public License along with this
; program. If not, see <https://www.gnu.org/licenses>.

; # Documentation
; The intercept server is designed to provide a flexible and powerful interface for
; manipulating HTTP requests and responses between 2 remote endpoints. It provides a guile
; REPL with useful functions preloaded on every request (and, optionally, response) that
; an endpoint sends, in addition to hook points for filtering or automatically modifying
; messages. It is like ZAProxy, except embedded into guile instead of being a standalone
; program.
;
; To start the server run:
;
; guile -q -c '(begin (use-modules (skyler red-team intercept server)) (main))'
;
; The program will then wait for a client to send a request. As an easy way to try out the
; server, you can open a second REPL and run the following commands:
;
; > (use-modules (web client))
; > (current-http-proxy "http://127.0.0.1:8080")
; > (http-get "http://www.example.com")
;
; Then go back to the original guile instance and you should see the request on the
; screen, followed by a REPL. You can forward the request by calling `(forward)` or drop
; it by calling `(drop)` and review the response in the second instance.
;
; Then you can try using the hooks. In the first instance, press Ctrl-Z to send SIGTSTP,
; and the REPL will open without waiting for a new request (if you truly want to suspend
; the server, you can press Ctrl-Z while the REPL is open). Then you can add some hooks:
;
; > (set-pre-intercept-hook! 'hello-world
;                            (lambda () (format #t "Hello, pre-intercept world!")))
; > (set-post-intercept-hook! 'hello-world
;                             (lambda () (format #t "Hello, post-intercept world!")))
;
; Then try calling `http-get` from the second instance again, and you will see the
; messages printed before and after the REPL runs. You can also skip the REPL entirely
; with:
;
; > (set-should-intercept?-hook! 'never (const #f))
;
; Other commands are described in the API documentation for
; `(skyler red-team intercept repl interface)`. Note that for symbols re-exported from
; other modules, you will need to refer to the original module to find the documentation.

; TODO:
;
; Figure out how to exit the server cleanly
; Session saving
; Refactor the pre- and post- hooks to be namespaced based on response mutation
; Decode the body if it's text/, application/xml, or application/json
;   Or maybe there's something in one of the (web *) modules that has better heuristics?
; TUI (request/response in top, repl in bottom)
; History browsing
; Internal CA for https connections
; Auto-launch firefox with temporary profile, pre-proxied, and pre-trust intercept CA
;   https://stackoverflow.com/questions/1345000/programmatically-install-certificate-into-mozzilla
;   https://support.mozzilla.org/en-US/kb/setting-certificate-authorities-firefox
;   https://support.mozzilla.org/en-US/kb/profiles-wherefirefox-stores-user-data
;   --profile option can point to an arbitrary directory to hold profile data

(read-set! keywords #f)

(define-module (skyler red-team intercept server)
	#:use-module (srfi srfi-26)
	#:use-module (web request)
	#:use-module (web response)
	#:use-module (web server)

	#:use-module (skyler red-team intercept repl)
	#:use-module (skyler red-team intercept repl interface)

	#:use-module ((gnutls)          #:prefix tls.)
	#:use-module ((skyler web x509) #:prefix sky.)

	#:export (
		main
		; Signature: (main key: (port 8080))
		;
		; Arguments:
		; port: The TCP port number that the server will listen on.
		;
		; Returns:
		; Unspecified
		;
		; Runs the intercept server. See the module-level documentation for details.

		current-request
		current-request-body
		current-response
		current-response-body
		; Parameters which contain the <request>/<response> object and body currently in use.
		; There are many use-cases where overwriting these paramaters are desirable, but care
		; must be taken, especially if the new version is not based on the original version.
		; They will be automatically overwritten when a new request/response is intercepted,
		; but user-defined variables will persist between intercepts.

		set-pre-intercept-hook!     remove-pre-intercept-hook!
		set-should-intercept?-hook! remove-should-intercept?-hook!
		set-post-intercept-hook!    remove-post-intercept-hook!
		; Signatures: (set-*-hook! name proc) (remove-*-hook! name)
		;
		; Arguments:
		; name: A symbol uniquely identifying the hook.
		;
		; proc: - For pre- and post-, a thunk which will run when the hook is called.
		;       - For should-intercept? a 2-argument procedure which takes in the request and
		;         request body (in that order) and returns #f if the request should NOT be
		;         intercepted.
		;
		; Returns:
		; Unspecified
		;
		; Each of this hooks will run once each time a request is received by the server. The
		; pre- and post- hooks will be called blindly without any further processing. The
		; pre- hook is called just before the REPL starts, and the post- hook is called after
		; the response and response body have been set (eg, if the REPL user did not set them
		; then they will be filled with their default values before the hooks run).
		;
		; The should-intercept? hooks can be used to decide when the REPL should be opened. By
		; default, every request will open the REPL. However, if any of the should-intercept?
		; hooks return #f then the REPL will not open. There is no guarantee that each of the
		; should-intercept? hooks will be called on a given request; if the first hook returns
		; #f, then the server may choose to skip the rest of them.
		;
		; The order that hooks wil run in is unspecified.
))

(read-set! keywords 'postfix)

(define current-request      (make-parameter #f))
(define current-request-body (make-parameter #f))

(define current-response      (make-parameter #f))
(define current-response-body (make-parameter #f))

(define generic-error-response
	(build-response #:code 500
	                #:reason-phrase "Failed to generate response. Check REPL."))

(define pre-intercept-hooks     '())
(define should-intercept?-hooks '())
(define post-intercept-hooks    '())

(define (set-pre-intercept-hook! name proc)
	(set! pre-intercept-hooks (assq-set! pre-intercept-hooks name proc)))

(define (remove-pre-intercept-hook! name)
	(set! pre-intercept-hooks (assq-remove! pre-intercept-hooks name)))

(define (set-should-intercept?-hook! name proc)
	(set! should-intercept?-hooks (assq-set! should-intercept?-hooks name proc)))

(define (remove-should-intercept?-hook! name)
	(set! should-intercept?-hooks (assq-remove! should-intercept?-hooks name)))

(define (set-post-intercept-hook! name proc)
	(set! post-intercept-hooks (assq-set! post-intercept-hooks name proc)))

(define (remove-post-intercept-hook! name)
	(set! post-intercept-hooks (assq-remove! post-intercept-hooks name)))

(define* (should-intercept? key: (remaining-hooks should-intercept?-hooks) (ret #t))
	(if (or (not ret) (null? remaining-hooks))
		ret
		(let ((next (cdr (car remaining-hooks)))
		      (rest (cdr remaining-hooks)))
		(should-intercept? ret:             (next (current-request) (current-request-body))
		                   remaining-hooks: rest))))

(define (intercept-handler request request-body)
	(current-request      request)
	(current-request-body request-body)

	(when (eq? (request-method (current-request)) 'CONNECT)
		(error (string-append " A client sent a CONNECT request to this server. This "
		                      "probably means that it is trying to open an HTTPS connection, "
		                      "which is currently unsupported.")))

	(for-each (lambda (entry) ((cdr entry))) pre-intercept-hooks)

	(format #t "Received request:~%")
	(write-request (current-request) (current-output-port))
	(when (current-request-body)
		(format #t "~A~%" (current-request-body)))

	(if (should-intercept?)
		(repl)
		(forward end-repl?: #f))

	(unless (current-response)
		(current-response      generic-error-response)
		(current-response-body (if (eq? (request-method (current-request)) 'HEAD)
		                       	#f
		                       	"")))

	(for-each (lambda (entry) ((cdr entry))) post-intercept-hooks)

	(current-request      #f)
	(current-request-body #f)
	(values (current-response #f)
	        (current-response-body #f)))

(define* (main key: (port 8080))
	(format #t "Starting HTTP intercept server on port ~a~%" port) 

	(let* ((prior-action (sigaction SIGTSTP))
	       (restore-sigtstp (lambda () 
	       	(sigaction SIGTSTP (car prior-action) (cdr prior-action))))
	       (set-sigtstp (lambda () (sigaction SIGTSTP (lambda (arg) (repl)))))
	      )
		(set-enter-hook! 'sigtstp-handler restore-sigtstp)
		(set-exit-hook!  'sigtstp-handler set-sigtstp)

		(set-sigtstp)
		(run-server intercept-handler 'http `(port: ,port))
		(restore-sigtstp)))
