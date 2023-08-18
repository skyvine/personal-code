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
; This module exports symbols which are available in the intercept REPL, as described in
; the module documentation for `(skyler red-team intercept server)`. See the API
; documentation for details.

(define-module (skyler red-team intercept repl interface)
	#:use-module (web client)
	#:use-module (web request)
	#:use-module (web response)
	#:use-module (web uri)

	#:use-module (skyler red-team intercept server)

	#:re-export (
		; from (skyler red-team intercept server)
		current-request  current-request-body
		current-response current-response-body

		set-pre-intercept-hook!     remove-pre-intercept-hook!
		set-should-intercept?-hook! remove-should-intercept?-hook!
		set-post-intercept-hook!    remove-post-intercept-hook!
	)

	#:export (
		end-repl
		; Signature: (end-repl)
		;
		; Returns:
		; Unspecified
		;
		; Ends the intercept session. The values of (current-response) and
		; (current-response-body) will be passed to the client. If (current-response) is #f,
		; then a generic error will be passed to the client.
		;
		; Note: This is only needed if the response and/or body are set manually at the REPL.
		;       If one of the helpers provided by this module are used, the server will
		;       continue automatically.

		forward
		; Signature: (forward #:key (intercept-response?  #f)
		;                           (print-response-body? #t)
		;                           (end-repl?            #t))
		;
		; Arguments:
		; intercept-response?:  If #t, open the intercept REPL once the response is received
		;                       by the intercept server, but before it is sent to the client.
		;                       This allows for response modification.
		;
		; print-response-body?: If true, the response body will be printed. Currently this
		;                       will print the raw bytevector with no decoding.
		;
		; end-repl?:            If #t, the REPL will exit as soon as the response is sent back
		;                       to the client. This is most useful when the function is called
		;                       programmatically, such as when a should-intercept? hook
		;                       returns #f.
		;
		; Returns:
		; Unspecified, and not guaranteed to return (in particular, will not return if
		; end-repl? is #t).
		;
		; Tells the server to send the message stored in the current-resquest and
		; current-resquest-body parameters to the appropriate remote endpoint and store the
		; response and body in their parameters. This will cause the responses to be sent to
		; the client verbatim, unless they are modified with intercept-response? or a hook.

		drop
		; Signature: (drop)
		;
		; Tells the server to drop the request. It will send an error response back to the
		; client. It will not perform any communication with the remote endpoint.
))

; # Helpers

(define (full-request-uri request)
	(string-append "http://" (car (request-host request))
	               (if (cdr (request-host request))
	               	(string-append ":" (number->string (cdr (request-host request))))
	               	"")
	               (uri-path (request-uri request))))

(define (maybe-read-response-body response request)
	(if (eq? (request-method (current-request)) 'HEAD)
		#f
		(read-response-body response)))

; # Interface

(define (end-repl) (throw 'quit))

(define* (drop)
	(format #t "Dropping request~%")
	(current-response (build-response #:code 599
	                                  #:reason-phrase "Intercept server dropped"))
	(end-repl))

(define* (forward #:key (intercept-response?  #f)
                        (print-response-body? #t)
                        (end-repl?            #t))
	(format #t "Forwarding to: ~s~%" (full-request-uri (current-request)))

	(define forward-port (open-socket-for-uri (full-request-uri (current-request))))
	(current-request (write-request (current-request) forward-port))

	(when (current-request-body)
		(write-request-body (current-request) (current-request-body)))

	(force-output forward-port)

	(current-response      (read-response forward-port))
	(current-response-body (maybe-read-response-body (current-response) (current-request)))

	(format #t "Received response~%")
	(write-response (current-response) (current-output-port))
	(when (and print-response-body? (current-response-body))
		(format #t "~A~%" (current-response-body)))

	(when intercept-response?
		(repl))

	(when end-repl?
		(end-repl)))
