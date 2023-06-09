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

; # Documentation
; Contains the home configuration I prefer to use.

(read-set! keywords #f)

(define-module (skyler guix home)
							 #:use-module (guix gexp)
							 #:use-module (gnu packages music)

	#:use-module ((gnu)                      #:prefix guix.)
	#:use-module ((gnu home)                 #:prefix guix.)
	#:use-module ((gnu home services)        #:prefix guix.)
	#:use-module ((gnu services)             #:prefix guix.)
	#:use-module ((guix packages)            #:prefix guix.)

	#:use-module ((gnu home services shells) #:prefix guix.)

	#:use-module ((gnu packages shells)      #:prefix guix.)
	#:use-module ((gnu packages code)        #:prefix guix.)
	#:use-module ((gnu packages admin)       #:prefix guix.)

	#:export (
		home
		; A home-environment conaining my preferred configuration
))

(use-modules
	(skyler standard)
	((skyler guix utils)        #:prefix sky.)
	((skyler guix packages)     #:prefix sky.)
	((skyler guix collections)  #:prefix sky.))

(read-set! keywords 'postfix)

(define (path-append name . paths)
	(cons name (format #f "${~a:+$~a:}~a"
	                      name
	                      name
	                      (reduce (lambda (next current) (string-append current ":" next))
	                              (first paths)
	                              paths))))

(define home
	(guix.home-environment
		(packages sky.essential-packages)
		(services (list
			(guix.service guix.home-bash-service-type
				(guix.home-bash-configuration (guix-defaults? #t)))
			(guix.service guix.home-fish-service-type
				(guix.home-fish-configuration))
			(guix.simple-service 'custom-env-vars
				guix.home-environment-variables-service-type
				(list (cons "EDITOR" "nvim")

				      (path-append "PATH"            "$HOME/.local/bin")
				      (path-append "GUILE_LOAD_PATH" "$HOME/.guix-profile/share/guile/site/3.0")

				      (path-append "GUILE_LOAD_COMPILED_PATH"
				                   "$HOME/.guix-profile/lib/guile/3.0/site-ccache")))))))

home
