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
		; A home-environment
))

(read-set! keywords 'postfix)

(define home
	(guix.home-environment
		(services (list
			(guix.service guix.home-bash-service-type
				(guix.home-bash-configuration
					(aliases '(
						("ls" . "ls --color=auto")
						("authenticate-guix-checkout" .
						 "guix git authenticate 9edb3f66fd807b096b48283debdcddccfea34bad 'BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA'")
					))
					(guix-defaults? #t)))
			(guix.simple-service 'custom-env-vars
				guix.home-environment-variables-service-type
				'(("EDITOR" . "nvim")))))))

home
