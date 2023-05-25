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

(use-modules
	(guix gexp)
	(ice-9 match)
	(srfi srfi-1)
	(srfi srfi-88)

	((guix build-system channel)       #:prefix guix.)
	((guix build-system copy)          #:prefix guix.)
	((guix build-system gnu)           #:prefix guix.)
	((guix build-system guile)         #:prefix guix.)
	((guix build-system trivial)       #:prefix guix.)
	((guix channels)                   #:prefix guix.)
	((guix describe)                   #:prefix guix.)
	((guix gexp)                       #:prefix guix.)
	((guix packages)                   #:prefix guix.)
	((gnu packages base)               #:prefix guix.)
	((gnu packages gnupg)              #:prefix guix.)
	((gnu packages guile)              #:prefix guix.)
	((gnu packages package-management) #:prefix guix.)
)

(define version "0.0")

(define inject-store-paths
	'(lambda* (key: inputs #:allow-other-keys)
		; TODO: don't make users manually add this... seriously...
		(unless (assoc-ref inputs "glibc-locales")
			(error "The inject-store-paths phase requires glibc-locales as an input."))

		; Need to set the locale for characters used in flow charts
		(setenv "GUIX_LOCPATH"
		        (string-append (assoc-ref inputs "glibc-locales") "/lib/locale"))
		(setlocale LC_ALL "en_US.utf8")

		(substitute* (find-files ".")
			(("%%([a-z0-9_-]*) (.*)%%" _ name path)
			 (if (assoc-ref inputs name)
			 	(string-append (assoc-ref inputs name) "/" path)
			 	(error (format #f "Input ~s not found!" name))))
)))

(define no-tests-error-message
	`(format #f
		,(string-append "The test module ~a does not define the all-tests variable. This "
		               "should be a list of functions as created by define-test or , from "
		               "make-testthe (skyler r7rs test utils) module.")
		module-name))

(define check-runner 
	`(lambda (module-name) (save-module-excursion (lambda ()
		; set! the %load-path manually instead of using add-to-load-path in order to make sure
		; the code at the end which undoes the modification works correctly. Also, the manual
		; recommends using add-to-load-path so that it is modified at compile-time, but this
		; will not be compiled before running (note that we are in a quasiquote), and we're
		; depending on the environment (shudders) here anyway, so we don't want it to take
		; effect at compile-time even if it was compiled. Module introspection is fun. =]
		(set! %load-path (cons (getcwd) %load-path))
		(let ((test-module (resolve-module module-name #:ensure #f)))
			(unless test-module
				(error (format #f "The test module ~a does not exist." module-name)))

			(unless (module-variable test-module 'all-tests)
				(error ,no-tests-error-message))

			; Set the current module to make sure we have
			; dependencies. This is particularly relevant for the
			; serialization tests, since serialization uses eval.
			(set-current-module test-module)

			; Don't import the util module so we don't pollute the environment. all-tests is a 
			; magic symbol that test modules must provide.
			; Also: There is a strange issue where referencing all-tests directly here results
			; in an undefined variable error, even though the module has been set. The error
			; message indicates that guile is trying to resolve the variable inside the
			; guile-user module instead of the one we just set to be current. Printing off the
			; the value of (current-module) shows that the module was successfully set. My best
			; guess is that this is some sandboxing feature for security because eval is so
			; dangerous, although why it would silently fail *and* lie to me about what module
			; I'm in is unclear. Either way, using module-ref here resolves the issue, and the
			; serialization tests still work in spite of using eval in deserialize, because the
			; deserialize macro explicitly uses the module of the calling site, and the calling
			; site is the serialization test module, not this module, because that is where the
			; test function is defined. This issue caused some frustration, but now I am proud
			; of the robustness of the serialization module.
			(unless ((@ (skyler test util) run-tests) (module-ref test-module 'all-tests))
				(error (format #f "Tests did not pass for module ~s" module-name))))
			(set! %load-path (cdr %load-path))))))

(define (check module-names)
	`(lambda* (key: inputs #:allow-other-keys)
		(for-each ,check-runner ',module-names)))

(define guile-search-paths (list
	(guix.search-path-specification (variable "GUILE_LOAD_PATH")
	                                (files (list "share/guile/site/3.0")))
	(guix.search-path-specification (variable "GUILE_LOAD_COMPILED_PATH")
	                                (files (list "share/guile/3.0/site-ccache")))))

(define patches (let ((patches-dir (guix.local-file "patches" recursive?: #t)))
	(guix.package
		(name        "patches")
		(version     version)
		(source      #f)
		(description #f)
		(synopsis    #f)
		(home-page   #f)
		(license     #f)

		(build-system guix.copy-build-system)
		(arguments (list
			phases: '(modify-phases (@ (guix build copy-build-system) %standard-phases)
			        	(delete 'unpack))
			install-plan: #~(list (list #$patches-dir "share/patches")))))))

(define base-guile-code
	(let ((guile-src (guix.local-file "src/scheme/guile/base" recursive?: #t))
	      (r7rs-src  (guix.local-file "src/scheme/r7rs/base" recursive?: #t)))
		(guix.package
			(name        "base-guile-code")
			(version     version)
			(source      #f)
			(description #f)
			(synopsis    #f)
			(home-page   #f)
			(license     #f)

			(build-system guix.guile-build-system)
			(native-search-paths guile-search-paths)

			(native-inputs (list guix.guile-3.0-latest guile-src r7rs-src))

			(arguments (list
				not-compiled-file-regexp: "(guix/.*.scm|make.scm)"

				modules: `((guix build utils) ,@guix.%guile-build-system-modules)

				phases: #~(modify-phases (@ (guix build guile-build-system) %standard-phases)
					(delete 'unpack)
					(add-before 'set-locale-path 'fix-paths
						; Paths in the filesystem are sensible for editing, but not a useful
						; module structure inside an actual implementation
						(lambda* (key: inputs #:allow-other-keys)
							(use-modules (guix build utils))
							(copy-recursively #$guile-src "./skyler")
							(copy-recursively #$r7rs-src "./skyler/r7rs")))

					(add-after 'install-documentation 'check
						#$(check '((skyler r7rs test)
						           (skyler serialization test)
					)))
))))))

(define guix-code
	(let ((guix-code (guix.local-file "src/scheme/guile/guix" recursive?: #t)))
		(guix.package
			(name        "guix-code")
			(version     version)
			(source      #f)
			(description #f)
			(synopsis    #f)
			(home-page   #f)
			(license     #f)

			(build-system        guix.guile-build-system)
			(native-search-paths guile-search-paths)
			(native-inputs       (list guix.guile-3.0-latest guix.glibc-locales))

			; need to propagate because we're not compiling, see also the note on the
			; not-compiled-file-regexp: argument
			(propagated-inputs (list
				guix.guile-gcrypt
				base-guile-code
				patches
			))

			(arguments (list
				; don't compile anything, we always want to use the system's guix, not some snapshot
				not-compiled-file-regexp: ".*"

				phases: #~(modify-phases (@ (guix build guile-build-system) %standard-phases)
					(delete 'unpack)
					(add-before 'set-locale-path 'fix-paths
						; Paths in the filesystem are sensible for editing, but not a useful
						; module structure inside an actual implementation
						(lambda* (key: inputs #:allow-other-keys)
							(use-modules (guix build utils))
							(copy-recursively #$guix-code "./skyler/guix")))

					(add-after 'fix-paths 'inject-store-paths #$inject-store-paths)))))))


(define make.scm
	(let ((src (local-file "src/bin/make.scm")))
		(guix.package
			(name        "make.scm")
			(version     "0.1")
			(home-page   #f)
			(synopsis    #f)
			(description #f)
			(license     #f)

			(build-system        guix.gnu-build-system)
			(native-search-paths guile-search-paths)
			(source              #f)
			(native-inputs       (list guix.guile-3.0-latest (local-file "src/bin/make.scm")))

			(arguments (list
				phases:
				#~(modify-phases (@ (guix build gnu-build-system) %standard-phases)
					(delete  'unpack)
					(delete  'configure)
					(delete  'build)
					(delete  'check)
					(replace 'install
						(lambda* (key: outputs #:allow-other-keys)
							(let ((bin-dir (string-append (assoc-ref outputs "out")
							                              "/bin"))
							      (make.scm #$(local-file "src/bin/make.scm")))
								(use-modules (guix build utils))
								(mkdir-p bin-dir)
								(copy-recursively make.scm
								                  (string-append bin-dir "/make.scm")))))))))))

(define personal-code (guix.package
	(name              "personal-code")
	(version           version)
	(description       #f)
	(synopsis          #f)
	(home-page         #f)
	(license           #f)

	(build-system        guix.trivial-build-system)
	(native-search-paths guile-search-paths)
	(source              #f)
	(propagated-inputs   (list base-guile-code guix-code make.scm))
	(arguments           `(builder: (begin (mkdir (assoc-ref %outputs "out")))))))

personal-code
