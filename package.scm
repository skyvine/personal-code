(define-module (skyler guix meta)
	#:use-module (guix gexp)
	#:use-module (ice-9 match)
	#:use-module (srfi srfi-1)

	#:use-module ((guix build-system channel)       #:prefix guix:)
	#:use-module ((guix build-system gnu)           #:prefix guix:)
	#:use-module ((guix build-system guile)         #:prefix guix:)
	#:use-module ((guix build-system trivial)       #:prefix guix:)
	#:use-module ((guix channels)                   #:prefix guix:)
	#:use-module ((guix describe)                   #:prefix guix:)
	#:use-module ((guix gexp)                       #:prefix guix:)
	#:use-module ((guix packages)                   #:prefix guix:)
	#:use-module ((gnu packages gnupg)              #:prefix guix:)
	#:use-module ((gnu packages guile)              #:prefix guix:)
	#:use-module ((gnu packages package-management) #:prefix guix:)
	#:use-module ((rde packages)                    #:prefix rde:)

	#:export (version guile-code personal-code)
)

(define version "0.0")

(define guile-code (guix:package
	(name        "guile-code")
	(version     version)
	(source      #f)
	(description #f)
	(synopsis    #f)
	(home-page   #f)
	(license     #f)

	(build-system guix:guile-build-system)

	(native-inputs (list
		guix:guile-3.0-latest
		guix:guile-gcrypt
	))

	(arguments `(
		#:not-compiled-file-regexp "(guix/.*.scm|make.scm)"

		#:modules ((guix build utils) ,@guix:%guile-build-system-modules)

		#:phases (modify-phases (@ (guix build guile-build-system) %standard-phases)
			(delete 'unpack)
			(add-before 'set-locale-path 'fix-paths
				; Paths in the filesystem are sensible for editing, but not a useful
				; module structure inside an actual implementation
				(lambda* (#:key inputs #:allow-other-keys)
					(use-modules (guix build utils))
					(let ((guile-src ,(guix:local-file "src/scheme/guile" #:recursive? #t))
					      (r7rs-src ,(guix:local-file "src/scheme/r7rs" #:recursive? #t))
					     )
						(format #t "~A~%" guile-src)
						(format #t "~A~%" r7rs-src)

						(copy-recursively guile-src "./skyler")
						(mkdir-p "./skyler/r7rs")
						(copy-recursively r7rs-src "./skyler/r7rs")
			)))
		)
	))
))

(define personal-code (guix:package
	(name              "personal-code")
	(version           version)
	(description       #f)
	(synopsis          #f)
	(home-page         #f)
	(license           #f)

	(build-system      guix:trivial-build-system)
	(source            #f)
	(propagated-inputs (list guile-code ))
	(arguments         `(#:builder (begin (mkdir (assoc-ref %outputs "out")))))))

personal-code
