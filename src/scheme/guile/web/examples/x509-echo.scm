(read-set! keywords #f)

(define-module (skyler web examples x509-echo)
	#:use-module (ice-9 binary-ports)
	#:use-module (ice-9 match)
	#:use-module (ice-9 threads)
	#:use-module (rnrs bytevectors)
	#:use-module (skyler standard)
	#:use-module (web client)

	#:use-module (skyler web x509)

	#:use-module ((gnutls) #:prefix tls.)

	#:export (
		main
		; Signature: (main optional: (log-level 0) (log-port (current-output-port)))
		;
		; Arguments:
		; log-level: the level to set the underlying GNUTLS logging to
		; log-port:  the port to write log messages on
		;
		; Returns:
		; Unspecified
		;
		; This function runs the client and server (described below) with a newly generated
		; certificate/key pair and passes some example data back and forth. Output from the
		; client and the server will be interweaved.

		run-echo-client
		; Signature: (run-echo-client sock certificate)
		;
		; Arguments:
		; sock:        an IP/TCP socket that will be used underneath TLS
		; certificate: a certificate that the client trusts; this should either be used
		;              directly by the server, or should have signed the certificate used by
		;              the server.
		;
		; Returns:
		; Unspecified
		;
		; This function will set up TLS on sock, verify that the peer is authenticated by
		; certificate, and send some messages. It expects each message to be echoed back and
		; will block until it hears the echo (newline-delimited).

		run-echo-server
		; Signature: (run-echo-server sock certificate key)
		;
		; Arguments:
		; sock:        an IP/TCP socket that will be used underneath TLS
		; certificate: a public certificate that will be presented to the peer for
		;              authentication
		; key:         the private key corresponding to certificate
		;
		; Returns:
		; Unspecified
		;
		; This function will set up TLS on sock, authenticate itself to the peer using
		; certificate and key, and echo any messages it hears back to the peer. It will exit
		; once the peer sends the text "exit" (exactly) or the socket returns an eof object.
))

(read-set! keywords 'postfix)

; Set the "priorities", which are used to determine security parameters. See the GNUTLS
; manual section on Priority String for more info.
(define priorities
	(apply string-append (interweave ":" (list
		"NORMAL"         ; start with default settings
		"-KX-ALL"        ; disallow all key exchange algorithms
		"+KX-RSA"        ; allow RSA key exchange (force using this only)
		"-CTYPE-CLI-ALL" ; disallow all certificate types
		"+CTYPE-X509"    ; allow x509 certificates (force using this only)
		"-VERS-ALL"      ; disallow all TLS versions
		"+VERS-TLS1.3"   ; allow TLS 1.3 (force using this only)
))))

(define (run-echo-server sock certificate key)
	(format #t "SERVER: Starting~%")
	(let ((server     (tls.make-session tls.connection-end/server))
		    (cred       (tls.make-certificate-credentials)))
		; See the comments on the definition of priorities, above
		(tls.set-session-priorities! server priorities)

		; Tell TLS to use the provided socket
		(tls.set-session-transport-fd! server (fileno sock))

		; Use the given certificate & private key for authentication
		(tls.set-certificate-credentials-x509-keys! cred (list certificate) key)
		(tls.set-session-credentials!               server cred)

		; This refers to client authentication, this example does not use it. If it is
		; required, then tls.certificate-request/required should be used (and more updates
		; to the below code would be needed, presumably).
		(tls.set-server-session-certificate-request! server tls.certificate-request/request)

		; Set up TLS with the peer
		(format #t "SERVER: Handshaking~%")
		(tls.handshake server)

		; Echo logic, not specific to TLS. Once it's set up, the TLS port is used just like
		; any other port.
		(let echo ((message (read (tls.session-record-port server))))
			(unless (or (eof-object? message) (string=? "exit" message))
				(format #t "SERVER: Received message: ~a~%" message)
				(write message (tls.session-record-port server))
				(echo (read (tls.session-record-port server)))))

		; Close the connection cleanly
		(tls.bye server tls.close-request/rdwr)))

(define (run-echo-client sock certificate)
	(format #t "CLIENT: Starting client~%")
	(let ((client (tls.make-session tls.connection-end/client))
	      (credentials (tls.make-certificate-credentials)))
		; See the comments on the definition of priorities, above
		(tls.set-session-priorities! client priorities)

		; Tell TLS to use the provided socket
		(tls.set-session-transport-fd! client (fileno sock))

		; Tell TLS that the given certificate is the (only) one we trust.
		(tls.set-certificate-credentials-x509-trust-data!
			credentials
			(tls.export-x509-certificate certificate tls.x509-certificate-format/pem)
			tls.x509-certificate-format/pem)
		(tls.set-session-credentials! client credentials)

		; Set up TLS with the peer
		(format #t "CLIENT: Handshaking~%")
		(tls.handshake client)

		; WARNING: Here the peer status is being checked because it is NOT a fatal error for
		;          the peer to send an invalid certificate. The port will hapily send and
		;          receieve data to an untrusted peer if you do not check the status.
		(if (nil? (tls.peer-certificate-status client))
			(begin ; certificate is valid
				(write "Hello, world!" (tls.session-record-port client))
				(format #t "CLIENT: Echo: ~a~%" (read (tls.session-record-port client)))
				(write "Wait... we're only supposed to have one thing to say!"
				       (tls.session-record-port client))
				(format #t "CLIENT: Echo: ~a~%" (read (tls.session-record-port client)))
				(write "Oh noes!" (tls.session-record-port client))
				(format #t "CLIENT: Echo: ~a~%" (read (tls.session-record-port client)))
				(write "exit" (tls.session-record-port client)))

		(begin ; certificate is invalid
			(format #t "CLIENT ERROR: Server certificate not acceptable! ~A~%"
			           (tls.peer-certificate-status client))))

		(tls.bye client tls.close-request/rdwr)))

(define* (main #:key (log-level 0) (log-port (current-output-port)))
	(tls.set-log-level! log-level)
	(tls.set-log-procedure! (lambda (level message)
		(format log-port "~A: ~A~%" level message)))

	(match-let* ((authority (make-x509-authority-pair  "authority"))
	             ((certificate . key)
	              ; to see what happens when the certificate is not trusted, remove the
	              ; change the value of authority: to #f
	              (make-x509-server-pair "127.0.0.1" authority: authority))
	             (sockets (socketpair PF_UNIX SOCK_STREAM 0))
	             (server-thread (make-thread run-echo-server (car sockets) certificate key))
	             (client-thread (make-thread run-echo-client (cdr sockets) (car authority)))
	            )
		(join-thread server-thread)
		(join-thread client-thread)))
