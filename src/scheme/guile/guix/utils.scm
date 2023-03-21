(define-module (skyler guix utils)
	#:use-module (ice-9 optargs)

	#:use-module ((guix build-system trivial) #:prefix guix:)
	#:use-module ((guix gexp)                 #:prefix guix:)
	#:use-module ((guix packages)             #:prefix guix:)
	#:use-module ((gnu packages haskell-xyz)  #:prefix guix:)
	#:use-module ((gnu packages tex)          #:prefix guix:)

	#:export (local-package)
)

(define* (local-package #:key
                        name
                        builder

                        (version       "0")
                        (local-files   '())
                        (native-inputs '())
                        (inputs        '())
                        (synopsis      "")
                        (description   "")
                        (license       #f)
                        (home-page     "")
                )
	(guix:package
		(name        name)
		(version     version)
		(source      #f)
		(synopsis    synopsis)
		(description description)
		(license     license)
		(home-page   home-page)

		(build-system guix:trivial-build-system)
		(native-inputs `(
			,@(map (lambda (filename) (list filename (guix:local-file filename))) local-files)
			,@native-inputs
		))
		(inputs inputs)
		(arguments `(
			#:modules ((gcrypt hash)
			           (gcrypt internal)
			           (gcrypt package-config)
			           (gcrypt utils)
			           (guix base16)
			           (guix base32)
			           (guix elf)
			           (guix build gnu-build-system)
			           (guix build gremlin)
			           (guix build syscalls)
			           (guix build utils)
			           (guix colors)
			           (guix combinators)
			           (guix config)
			           (guix deprecation)
			           (guix derivations)
			           (guix diagnostics)
			           (guix gexp)
			           (guix i18n)
			           (guix memoization)
			           (guix monads)
			           (guix profiling)
			           (guix records)
			           (guix serialization)
			           (guix sets)
			           (guix store)
			           (guix utils)
			)
			#:builder (begin
				(use-modules (guix build utils) (guix gexp))
				,builder
				((@@ (guix build gnu-build-system) patch-shebangs)
					#:inputs %build-inputs
					#:outputs %outputs))
		))))
