(read-set! keywords #f)

(define-module (skyler web x509)
	#:use-module (ice-9 binary-ports)
	#:use-module (ice-9 textual-ports)
	#:use-module (ice-9 popen)
	#:use-module (rnrs bytevectors)
	#:use-module (srfi srfi-11)
	#:use-module (skyler standard)

	#:use-module ((gnutls) #:prefix tls.)

	#:export (
		make-x509-pair
		; Signature: make-x509-pair common-name
		;                           key: (subj-extra '(("C" . "XX")
		;                                              ("L" . "Default City")
		;                                              ("O" . "Default Company Ltd")))
		;                                (algorithm  "rsa:4096")
		;                                (days-valid "1")
		;                                (extensions  #f)
		;                                (authority   #f))
		;
		; Arguments:
		; common-name: The value to use for CN= in the subject line. Should be the IP address
		;              or domain name of the site that the server represents.
		;
		; subj-extra:  Other subject values to add. The default values represent the defaults
		;              used by openssl at time of writing.
		;
		; algorithm:   The key algorithm to use; lots of people seem to like eliptical curves,
		;              not sure if there is a good reason to make them the default but there
		;              might be.
		;
		; days-valid:  The number of days for which the key is valid; MUST be a string, NOT a
		;              number
		;
		; extensions:  A list of strings specifying the x509 extension to use in the standard
		;              format. See make-x509-authority-pair and make-x509-security-pair for
		;              examples.
		;
		; authority:   A pair `(certificate . private-key)` to sign the key with. Clients
		;              which trust the certificate given in this argument will trust the
		;              certificate returned by this function.
		;
		; Returns:
		; A pair `(certificate . key)` where `key` is the private key corresponding to the
		; public certificate `certificate`.

		make-x509-authority-pair
		; Signature: make-x509-authority-pair common-name
		;
		; This is equvalent to:
		;
		; (make-x509-pair common-name extensions: '("keyUsage = keyCertSign"))
		;
		; The value returned by thys function can be passed to the #:authority argument of
		; make-x509-pair or make-x509-server-pair.
		;

		make-x509-server-pair
		; Signature: make-x509-server-pair common-name key: (authority #f)
		;
		; Arguments:
		; This is equvalent to:
		;
		; (make-x509-pair common-name
		;                 authority:  authority
		;                 extensions: '("extendedKeyUsage = serverAuth, clientAuth"))

		pem-filename->x509-certificate
		; Signature: pem-filename->x509-certificate filename
		;
		; Arguments:
		; filename: The name of an existing file which contains a PEM-formatted x509
		;           certificate.
		;
		; Returns:
		; The certificate contained within the file represented as a gnutls data structure.

		x509-certificate->pem-filename
		; Signature: x509-certificate->pem-filename certificate key: (filename /tmp/<random>)
		;
		; Arguments:
		; certificate: The certificate to write
		;
		; filename:    The name of the file to write to. If omitted, the filename will be
		;              randomly generated in some way and written to /tmp. There are no
		;              guarantees about the format of the filename, only that it consists
		;              of characters that are randomly generated.
		;
		; Returns:
		; The value of the filename argument
))

(read-set! keywords 'postfix)

; Private Helpers

(define openssl "%%openssl /bin/openssl%%")
(define fmt/pem tls.x509-certificate-format/pem)

(define (random-digits)
	(apply string-append (map number->string
		; note: The password is more than 12 digits long, it is 12 values long where each
		;       value fits into a byte.
		(bytevector->u8-list (tls.gnutls-random tls.random-level/key 12)))))

(define* (get-command-output cmdline key: (read get-bytevector-all)
                                          (write put-bytevector)
                                          (input #f)
         )
	(let-values (((read-port write-port pid)
	              (apply (@@ (ice-9 popen) open-process) (if input OPEN_BOTH OPEN_READ)
	                                                     cmdline)))
		(when input
			(write write-port input)
			(close-port write-port))
		(let ((ret (read read-port)))
			(close-port read-port)
			ret)))

(define (alist->subj-string alist)
	(define (pair->subj-element pair) (string-append (car pair) "=" (cdr pair)))

	(string-append "/"
	               (apply string-append (interweave "/" (map pair->subj-element alist)))
	               "/"))

; Public API

(define (pem-filename->x509-certificate filename)
	(let ((bytes (call-with-input-file filename get-bytevector-all)))
		(tls.import-x509-certificate bytes fmt/pem)))

(define* (x509-certificate->pem-filename certificate
                                  key: (filename (string-append "/tmp/" (random-digits))))
	(call-with-output-file filename
		(lambda (port)
			(put-bytevector port (tls.export-x509-certificate certificate fmt/pem)))
		binary: #t)
	filename)

(define* (make-x509-pair common-name
                         #:key (subj-extra  '(("C" . "XX")
                                              ("L" . "Default City")
                                              ("O" . "Default Company Ltd")))
                               (algorithm   "rsa:4096")
                               (days-valid  "1")
                               (extensions  '())
                               (authority   #f))
	(let* ((full-subj-alist    (cons `("CN" . ,common-name) subj-extra))
	       (subj-str           (alist->subj-string full-subj-alist))
	       (ca-file            (if authority
	                           	(x509-certificate->pem-filename (car authority))
	                           	#f))

	       (openssl-bytes (get-command-output
	       	`(,openssl "req" "-nodes" "-x509"
	       	           "-newkey"  ,algorithm
	       	           "-subj"    ,subj-str
	       	           "-days"    ,days-valid
	       	           "-out"     "/proc/self/fd/1"
	       	           "-keyout"  "/proc/self/fd/1"
	       	           ,@(if authority
	       	           	(list "-CA"    ca-file
	       	           	      "-CAkey" "/proc/self/fd/0")
	       	           	'())
	       	           ,@(if (nil? extensions)
	       	           	'()
	       	           	(apply append (map
	       	           		(lambda (ext) (list "-addext" ext))
	       	           		extensions))))
	       	input: (if authority
	       	       	(tls.export-x509-private-key (cdr authority) fmt/pem)
	       	       	#f)))

	       (certificate (tls.import-x509-certificate openssl-bytes fmt/pem))
	       (key         (tls.import-x509-private-key openssl-bytes fmt/pem)))

		(when ca-file (delete-file ca-file))
		(cons certificate key)))

(define (make-x509-authority-pair common-name)
	(make-x509-pair common-name extensions: '("keyUsage = keyCertSign")))

(define* (make-x509-server-pair common-name key: (authority #f))
	(make-x509-pair common-name extensions: '("extendedKeyUsage = serverAuth, clientAuth")
	                            authority:  authority))

; TODO: Pure gnutls implementation
; I really don't like the external calls to the openssl command-line utility. Nothing
; against the project, it's just that I would prefer to do everything in-process and the
; guile-gnutls bindings already exist. But the API is oriented towards lower-level actions
; than the openssl cli is (as one would expect), and I don't know enough about x509
; internals to do this correctly in a timely manner. Getting this implementation to work
; would be ideal, but I was able to get everything above to work without ever writing a
; private key to the filesystem, so it will suffice for now.

(define (reimport certificate)
	(tls.import-x509-certificate (tls.export-x509-certificate certificate fmt/pem) fmt/pem))

(define (broken/sign-certificate unsigned-certificate authority-certificate authority-key)
			; FIXME: signing the key doesn't actually sign the key...
			;
			; Not sure if checking certificate-authority-id is actually the right thing, this
			; has a value even for a freshly generated key. It is a different value than the
			; key itself, so it's not being self-signed somehow. I'm not sure what all openssl
			; does under the hood, if I was then the gnutls version would probably work. =D
			;
			; RFC 5280 chapter 4 probably has the info I'm looking for.
	(when authority
		(format #t "Self ID:          ~A~%" (tls.x509-certificate-key-id cert))
		(format #t "Before signing:   ~A~%" (tls.x509-certificate-authority-key-id cert))
		(tls.sign-x509-certificate! cert (car authority) (cdr authority))
		; from the GNUTLS manual regarding gnutls_x509_crt_privkey_sign:
		; "A known limitation of this function is, that a newly-signed certificate will
		;  not be fully-functional (eg, for signature verification), until it is exported
		;  and re-imported."
		(format #t "Before importing: ~A~%" (tls.x509-certificate-authority-key-id cert))
		(set! cert (reimport cert))

		(let ((expected (tls.x509-certificate-key-id (car authority)))
					(actual   (tls.x509-certificate-authority-key-id cert)))
			(format #t "Expected key id:  ~A~%" expected)
			(format #t "Authority key id: ~A~%" actual)
			(unless (eq? expected actual)
				(error "Signing failed!")))))

(define (broken/make-x509-pair)
	; TODO: Generate the certificate/privkey in-process with gnutls functions, so that the
	;       private key does not need to be written to the disk, and the technically
	;       unnecessary dependence on openssl can be removed.
	;
	; Gives an error that some value is not found, but doesn't specify which value it's
	; looking for. RFC 5280. 4.1 lists the basic fields, these are probably required to do
	; anything (some are listed as optional but also version-dependent, so maybe they need
	; to be set for v3 even if they are set to empty/null/whatever).
	(let ((private-key (tls.generate-x509-private-key tls.pk-algorithm/rsa 4096 '()))
	      (certificate (tls.make-x509-certificate)))
		(tls.set-x509-certificate-key!             certificate private-key)
		(tls.set-x509-certificate-subject-key-id!  certificate )
		(tls.set-x509-certificate-version!         certificate 3)
		(tls.set-x509-certificate-ca-status!       certificate #t)
		(tls.set-x509-certificate-activation-time! certificate (current-time))

		(tls.set-x509-certificate-dn-by-oid! certificate tls.oid/x520-common-name common-name)

		(tls.set-x509-certificate-serial! certificate
		                                  (tls.x509-certificate-fingerprint
		                                  	certificate
		                                  	tls.digest/sha256))
		(cons certificate private-key)))
