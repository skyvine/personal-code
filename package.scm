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

; This file is heavily dependent on GNU Guix. If you are not familiar with that project,
; it will not make much sense.

; # Documentation
; This file defines the set of packages which provide the code in this repository. This
; file needs to be installed imperatively, because the repository contains the
; operating-system and home definitions which would otherwise use the packages defined in
; this file. To avoid this problem, this file is used to "bootstrap" a new system with
; the definitions and dependencies. The other option would be to keep a separate
; repository as a channel, and this was tried first, but it added additional complexity
; without a clear benefit because there was still a bootstrapping step. It additionally
; cause an issue because upgrading the packages in this repository through `guix pull`
; also fetches updates from Guix (and any other channels such as RDE), which is rude when
; this is in active development and needs to be upgraded multiple times in a single day.

(define-module (bootstrap)
	#:use-module (guix gexp)
	#:use-module (ice-9 match)
	#:use-module (srfi srfi-1)

	#:use-module ((guix build-system channel)       #:prefix guix.)
	#:use-module ((guix build-system copy)          #:prefix guix.)
	#:use-module ((guix build-system gnu)           #:prefix guix.)
	#:use-module ((guix build-system guile)         #:prefix guix.)
	#:use-module ((guix build-system trivial)       #:prefix guix.)
	#:use-module ((guix channels)                   #:prefix guix.)
	#:use-module ((guix describe)                   #:prefix guix.)
	#:use-module ((guix gexp)                       #:prefix guix.)
	#:use-module ((guix packages)                   #:prefix guix.)
	#:use-module ((gnu packages base)               #:prefix guix.)
	#:use-module ((gnu packages gnupg)              #:prefix guix.)
	#:use-module ((gnu packages guile)              #:prefix guix.)
	#:use-module ((gnu packages guile-xyz)          #:prefix guix.)
	#:use-module ((gnu packages package-management) #:prefix guix.)

	#:export (
		inject-store-paths
		; Variable containing a quoted lisp expression.
		;
		; This is a build phase which replaces expressions of the form `%%package path%%` with
		; the absolute store path in the requested package. For example the following form:
		;
		; %%bash /bin/sh%%
		;
		; Would be replaced with:
		;
		; /gnu/store/<a-very-long-hash>-bash-<version>/bin/sh
		;
		; The requested package must be declared in the inputs of the package using this
		; phase. This creates an implicit dependency on glibc-locales, to ensure that files
		; containing non-ascii characters will be processed without error.

		check
		; Signature: (check module-names)
		;
		; Arguments:
		; module-names: A list of module names which contain the magic submodule `test`, which
		;               itself contains the magic variable `all-tests`. The variable must
		;               contain a list of thunks which run the relevant tests.
		;
		; WARNING: Do NOT modify the load-path from inside of tests or functions called by the
		; tests. Doing so will further corrupt the purity of the build process.
		;
		; Returns:
		; A build phase which runs the tests of all of the modules. The build phase assumes
		; that it is running in the guile-build-system provided by GNU Guix, immediately after
		; the install-documentation phase. Other build systems or phase orderings might work
		; by coincidence.

		patches
		; A package containing the patches that I use on packages defined elsewhere.

		base-guile-code
		; A package containing all of the code in the "base" projects. This code is intended
		; to be re-usable across multiple projects and keeping it in a separate project keeps
		; the dependency footprint smaller.

		guix-code
		; A package containing all of my guix configuration, including helpers for defining
		; machines for specific uses, packages, and everything else that depends on guix.

		haunt-code
		; A package contaning the helper functions I use for generating web pages with Haunt.

		personal-code
		; A meta-package which includes the other packages defined in this file as propagated
		; inputs.
))

(use-modules (srfi srfi-88))

(define version "0.0")

(define inject-store-paths
	#~(lambda* (key: inputs #:allow-other-keys)

		; Need to set the locale for characters used in flow charts
		(setenv "GUIX_LOCPATH" #$(file-append guix.glibc-locales "/lib/locale"))
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
		                "make-test the (skyler r7rs test utils) module.")
		module-name))

; This contains the bulk of the check function's implementation, and operates on exactly
; one of the given modules. It sets the load path to include the current directory 
(define check-runner 
	`(lambda (module-name) (save-module-excursion (lambda ()
		(let ((test-module (resolve-module module-name #:ensure #f)))
			(unless test-module
				(error (format #f "The test module ~a does not exist." module-name)))

			(unless (module-variable test-module 'all-tests)
				(error ,no-tests-error-message))

			; Set the current module to make sure we have dependencies. This is particularly
			; relevant for the serialization tests, since serialization uses eval.
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
				(error (format #f "Tests did not pass for module ~s" module-name))))))))

(define (check module-names)
	`(lambda* (key: inputs #:allow-other-keys)
		(use-modules (srfi srfi-1))

		(let ((input-load-paths (map (lambda (input)
		                             	(string-append (cdr input) "/share/guile/site/3.0"))
		                             inputs)))
			; set! the %load-path manually instead of using add-to-load-path in order to make
			; sure the code at the end which undoes the modification works correctly. Also, the
			; manual recommends using add-to-load-path so that it is modified at compile-time,
			; but this will not be compiled before running (note that we are in a quasiquote),
			; and we're depending on the environment (shudders) here anyway, so we don't want it
			; to take effect at compile-time even if it was compiled. Module introspection is
			; fun.
			(set! %load-path (append (cons (getcwd) input-load-paths) %load-path))
			(for-each ,check-runner ',module-names)
			(set! %load-path (drop %load-path (+ (length input-load-paths) 1))))))

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
			(native-inputs       (list guix.guile-3.0-latest patches))

			(propagated-inputs (list
				guix.guile-gcrypt
				base-guile-code
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

(define haunt-code
	(let ((haunt-code (guix.local-file "src/scheme/guile/haunt" recursive?: #t)))
		(guix.package
			(name        "haunt-code")
			(version     version)
			(source      #f)
			(description #f)
			(synopsis    #f)
			(home-page   #f)
			(license     #f)

			(build-system        guix.guile-build-system)
			(native-search-paths guile-search-paths)
			(native-inputs       (list guix.guile-3.0-latest patches))

			(propagated-inputs (list
				base-guile-code
				guix.guix
				guix.gnupg
				guix.haunt
			))

			(arguments (list
				phases: #~(modify-phases (@ (guix build guile-build-system) %standard-phases)
					(delete 'unpack)
					(add-before 'set-locale-path 'fix-paths
						; Paths in the filesystem are sensible for editing, but not a useful
						; module structure inside an actual implementation
						(lambda* (key: inputs #:allow-other-keys)
							(use-modules (guix build utils))
							(copy-recursively #$haunt-code "./skyler/haunt")))

					(add-after 'fix-paths 'inject-store-paths #$inject-store-paths)))))))

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
	(propagated-inputs   (list base-guile-code guix-code haunt-code))
	(arguments           `(builder: (begin (mkdir (assoc-ref %outputs "out")))))))

personal-code
