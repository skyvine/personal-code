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

(read-set! keywords #f)

(define-module (skyler guix utils)
	#:use-module (ice-9 optargs)

	#:use-module ((guix build-system trivial) #:prefix guix.)
	#:use-module ((guix gexp)                 #:prefix guix.)
	#:use-module ((guix packages)             #:prefix guix.)
	#:use-module ((gnu packages haskell-xyz)  #:prefix guix.)

	#:export (local-package)
)
(read-set! keywords 'postfix)

(use-modules (skyler standard))

(define* (local-package key:
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
	(guix.package
		(name        name)
		(version     version)
		(source      #f)
		(synopsis    synopsis)
		(description description)
		(license     license)
		(home-page   home-page)

		(build-system guix.trivial-build-system)
		(native-inputs `(
			,@(map (lambda (filename) (list filename (guix.local-file filename))) local-files)
			,@native-inputs
		))
		(inputs inputs)
		(arguments `(
			modules: ((gcrypt hash)
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
			builder: (begin
				(use-modules (guix build utils) (guix gexp))
				,builder
				((@@ (guix build gnu-build-system) patch-shebangs)
					inputs: %build-inputs
					outputs: %outputs))
		))))
