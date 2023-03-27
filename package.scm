(use-modules
	(guix gexp)
	(ice-9 match)
	(srfi srfi-1)

	((guix build-system channel)       #:prefix guix:)
	((guix build-system gnu)           #:prefix guix:)
	((guix build-system guile)         #:prefix guix:)
	((guix build-system trivial)       #:prefix guix:)
	((guix channels)                   #:prefix guix:)
	((guix describe)                   #:prefix guix:)
	((guix gexp)                       #:prefix guix:)
	((guix packages)                   #:prefix guix:)
	((gnu packages gnupg)              #:prefix guix:)
	((gnu packages guile)              #:prefix guix:)
	((gnu packages package-management) #:prefix guix:)
	((rde packages)                    #:prefix rde:)
)

(define version "0.0")

(define base-guile-code
	(let ((guile-src (guix:local-file "src/scheme/guile/base" #:recursive? #t))
	      (r7rs-src  (guix:local-file "src/scheme/r7rs/base" #:recursive? #t)))
		(guix:package
			(name        "base-guile-code")
			(version     version)
			(source      #f)
			(description #f)
			(synopsis    #f)
			(home-page   #f)
			(license     #f)

			(build-system guix:guile-build-system)

			(native-inputs (list guix:guile-3.0-latest guile-src r7rs-src))

			(arguments (list
				#:not-compiled-file-regexp "(guix/.*.scm|make.scm)"

				#:modules `((guix build utils) ,@guix:%guile-build-system-modules)

				#:phases #~(modify-phases (@ (guix build guile-build-system) %standard-phases)
					(delete 'unpack)
					(add-before 'set-locale-path 'fix-paths
						; Paths in the filesystem are sensible for editing, but not a useful
						; module structure inside an actual implementation
						(lambda* (#:key inputs #:allow-other-keys)
							(use-modules (guix build utils))
							(copy-recursively #$guile-src "./skyler")
							(copy-recursively #$r7rs-src "./skyler/r7rs")))))))))

(define guix-code
	(let ((guix-code (guix:local-file "src/scheme/guile/guix" #:recursive? #t)))
		(guix:package
			(name        "guix-code")
			(version     version)
			(source      #f)
			(description #f)
			(synopsis    #f)
			(home-page   #f)
			(license     #f)

			(build-system guix:guile-build-system)

			(native-inputs (list guix:guile-3.0-latest))

			; need to propagate because we're not compiling, see also the note on the
			; #:not-compiled-file-regexp argument
			(propagated-inputs (list
				guix:guile-gcrypt
				base-guile-code
			))

			(arguments (list
				; don't compile anything, we always want to use the system's guix, not some snapshot
				#:not-compiled-file-regexp ".*"

				#:phases #~(modify-phases (@ (guix build guile-build-system) %standard-phases)
					(delete 'unpack)
					(add-before 'set-locale-path 'fix-paths
						; Paths in the filesystem are sensible for editing, but not a useful
						; module structure inside an actual implementation
						(lambda* (#:key inputs #:allow-other-keys)
							(use-modules (guix build utils))
							(copy-recursively #$guix-code "./skyler/guix")))))))))

(define make.scm
	(let ((src (local-file "src/bin/make.scm")))
		(guix:package
			(name        "make.scm")
			(version     "0.1")
			(home-page   #f)
			(synopsis    #f)
			(description #f)
			(license     #f)

			(build-system  guix:gnu-build-system)
			(source        #f)
			(native-inputs (list guix:guile-3.0-latest (local-file "src/bin/make.scm")))

			(arguments (list
				#:phases
				#~(modify-phases (@ (guix build gnu-build-system) %standard-phases)
					(delete  'unpack)
					(delete  'configure)
					(delete  'build)
					(delete  'check)
					(replace 'install
						(lambda* (#:key outputs #:allow-other-keys)
							(let ((bin-dir (string-append (assoc-ref outputs "out")
							                              "/bin"))
							      (make.scm #$(local-file "src/bin/make.scm")))
								(use-modules (guix build utils))
								(mkdir-p bin-dir)
								(copy-recursively make.scm
								                  (string-append bin-dir "/make.scm")))))))))))

(define personal-code (guix:package
	(name              "personal-code")
	(version           version)
	(description       #f)
	(synopsis          #f)
	(home-page         #f)
	(license           #f)

	(build-system      guix:trivial-build-system)
	(source            #f)
	(propagated-inputs (list base-guile-code guix-code make.scm))
	(arguments         `(#:builder (begin (mkdir (assoc-ref %outputs "out")))))))

personal-code
