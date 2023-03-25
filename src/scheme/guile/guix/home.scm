(define-module (skyler guix home)
	#:use-module (skyler r7rs standard)

	#:use-module ((gnu)                      #:prefix guix:)
	#:use-module ((gnu home)                 #:prefix guix:)
	#:use-module ((gnu home services)        #:prefix guix:)
	#:use-module ((gnu services)             #:prefix guix:)
	#:use-module ((guix packages)            #:prefix guix:)

	#:use-module ((gnu home services shells) #:prefix guix:)
	#:use-module ((gnu home-services emacs)  #:prefix rde:)
	#:use-module ((gnu home-services-utils)  #:prefix rde:)

	#:use-module ((gnu packages emacs)       #:prefix guix:)
	#:use-module ((skyler guix utils)        #:prefix sky:)
	#:use-module ((skyler guix collections)  #:prefix sky:)

	#:export (home)
	)

(define (path-append name . paths)
	(cons name (format #f "${~a:+$~a:}~a"
	                      name
	                      name
	                      (reduce (lambda (next current) (string-append current ":" next))
	                              (first paths)
	                              paths))))

(define home
	(guix:home-environment
		(packages (append sky:luxury-packages))
		(services (list
			(guix:service guix:home-bash-service-type
				(guix:home-bash-configuration (guix-defaults? #t)))
			(guix:service guix:home-fish-service-type
				(guix:home-fish-configuration))
			(guix:simple-service 'custom-env-vars
				guix:home-environment-variables-service-type
				(list (cons "EDITOR" "nvim")

				      (path-append "PATH"            "$HOME/.local/bin")
				      (path-append "GUILE_LOAD_PATH" "$HOME/.guix-profile/share/guile/site/3.0")

				      (path-append "GUILE_LOAD_COMPILED_PATH"
				                   "$HOME/.guix-profile/lib/guile/3.0/site-ccache")
			))
))))
