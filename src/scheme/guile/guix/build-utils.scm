(read-set! keywords #f)

(define-module (skyler guix build-utils)
	#:use-module (guix gexp)
	#:use-module ((gnu packages base)         #:prefix guix.)
	#:use-module ((guix build-system trivial) #:prefix guix.)
	#:use-module ((guix packages)             #:prefix guix.)
	#:use-module ((guix search-paths)         #:prefix guix.)

	#:use-module (srfi srfi-1)

	#:export (
		inject-store-paths
		; Variable containing a quoted lisp expression.
		;
		; This is a build phase which replaces expressions quoted with double-% signs with
		; the absolute store path in the requested package. For example the following form:
		;
		; %%guile /bin/guile%%
		;
		; Would be replaced with:
		;
		; /gnu/store/<a-very-long-hash>-guile-<version>/bin/guile
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

		meta-package
		; Signature: (meta-package name
		;                           contained-packages
		;                           key: (version "0.0")
		;                                (description
		;                                  "Meta-package; see output file for contained packages.")
		;                                home-page)
		;
		; Arguments:
		; name:               A string representing thename of the meta-package.
		; contained-packages: A list of package objects.
		; version:            The version of the meta-package itself, which may or may not be
		;                     derived from the versions of the contained packages.
		; home-page:          The home-page for the meta-package.
		;
		; Returns:
		; A package object which propogates all of the packages in contained-packages. The
		; meta-package itself creates a single file in its output directory, the contents of
		; which are a list of the store paths representing contained-packages.
))

(read-set! keywords 'postfix)

(define inject-store-paths
	#~(lambda* (key: inputs #:allow-other-keys)

		; Need to set the locale for characters used in flow charts
		(setenv "GUIX_LOCPATH" #$(file-append guix.glibc-locales "/lib/locale"))
		(setlocale LC_ALL "en_US.utf8")

		(substitute* (find-files ".")
			(("%%([a-z0-9_-]*) (.*)%%" unused name path)
			 (if (assoc-ref inputs name)
			 	(string-append (assoc-ref inputs name) "/" path)
			 	(error (format #f "Input ~s not found!" name))))
)))

(define no-tests-error-message
	`(format #f
		,(string-append "The test module ~a does not define the all-tests variable. This "
		                "should be a list of functions as created by define-test or "
		                "make-test, from the (skyler r7rs test utils) module.")
		module-name))

; This contains the bulk of the check function's implementation, and operates on exactly
; one of the given modules. It sets the load path to include the current directory 
(define check-runner
	`(let ((test-module (resolve-module module-name #:ensure #f)))
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
			(error (format #f "Tests did not pass for module ~s" module-name)))))

(define (check module-names)
	`(lambda* (key: inputs #:allow-other-keys)
		(use-modules (ice-9 threads) (srfi srfi-1))

		(let* ((input-load-paths (map (lambda (input)
		                              	(string-append (cdr input) "/share/guile/site/3.0"))
		                              inputs))
		       (load-path-args (fold (lambda (dir lst) (cons* "-L" dir lst))
		                             '()
		                             (cons (getcwd) input-load-paths)))
		       (runner-args (lambda (module-name)
		       	(list "-c" (format #f "(let ((module-name '~s)) ~s)"
		       	                      module-name ',check-runner))))
		       (results (par-map (lambda (module-name)
		       	(cons module-name (status:exit-val
		       		(apply system* "guile" (append load-path-args (runner-args module-name))))))
		       	',module-names))
		       (failing-modules (remove (lambda (pair) (= (cdr pair) 0)) results))
		      )
				(if (= (length failing-modules) 0)
					#t
					(error (format #f "The following modules have failing tests: ~a"
					               (map car failing-modules)))))))

(define* (meta-package name
                       contained-packages
                       key: (version "0.0")
                            (description
                              "Meta-package; see output file for contained packages.")
                            home-page)
	(guix.package
		(name        name)
		(source      #f)
		(version     version)
		(description description)
		(synopsis    description)
		(home-page   home-page)
		; #f is a valid package license, but a list containing #f is not
		(license     (filter identity
		                    (apply lset-union
		                           equal?
		                           (map (lambda (package)
		                                  (if (list? (guix.package-license package))
		                                    (guix.package-license package)
		                                    (list (guix.package-license package))))
		                                contained-packages))))

		(build-system guix.trivial-build-system)
		(propagated-inputs contained-packages)
		(arguments (list
			modules: '((guix build utils))
			builder: #~(begin
			             (use-modules (guix build utils))
			             (mkdir-p %output)
			             (call-with-output-file (string-append %output "/packages")
			             	(lambda (port)
			             		(format port
			             		        "This meta-package contains the following packages:~%")
			             		(map (lambda (package)
			             		     	(format port "    ~a~%" package))
			             		     '#$contained-packages))))))))

