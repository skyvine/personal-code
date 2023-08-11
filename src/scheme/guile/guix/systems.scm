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
; Contains helpers for creating operating-system definitions based on use-case.

(read-set! keywords #f)

(define-module (skyler guix systems)
	#:use-module (oop goops)
	#:use-module (skyler standard)

	#:use-module (skyler guix collections)
	#:use-module (skyler guix os-fragment)

	#:use-module ((gnu bootloader)          #:prefix guix.)
	#:use-module ((gnu bootloader grub)     #:prefix guix.)
	#:use-module ((gnu packages ssh)        #:prefix guix.)
	#:use-module ((gnu services)            #:prefix guix.)
	#:use-module ((gnu services base)       #:prefix guix.)
	#:use-module ((gnu services ssh)        #:prefix guix.)
	#:use-module ((gnu system)              #:prefix guix.)
	#:use-module ((gnu system accounts)     #:prefix guix.)
	#:use-module ((gnu system file-systems) #:prefix guix.)
	#:use-module ((gnu system keyboard)     #:prefix guix.)
	#:use-module ((gnu system shadow)       #:prefix guix.)
	#:use-module ((guix gexp)               #:prefix guix.)
	#:use-module ((guix gexp)               #:select (gexp))

	#:use-module ((gnu packages guile)  #:prefix guix.) ; for setting my default "shell"
	#:use-module ((gnu packages shells) #:prefix guix.) ; for setting my default shell

	#:export (
		guix-machine
		; Signature: (guix-machine ip)
		;
		; Arguments:
		; ip: As in the `qubes-guest` function in the (skyler guix collections) module.
		;
		; Returns:
		; My primary guix machine

		utility
		; An operating-system suitable for use on a portable drive. This is inspired by the
		; Arch installer ISO, which is my default go-to for "my computer is completely bungled
		; up, I have no idea why, and I need to fix it". It has a lot of useful utilities.
		; This image is not yet as useful as that one.
))

(read-set! keywords 'postfix)

(define (guix-machine ip)
	(let* ((username        "user")
	       (users           (cons (guix.user-account (name  username)
	                                                 (uid   1000)
	                                                 (group username)
	                                                 (supplementary-groups
	                                                 	'("wheel" "audio" "video")))
	                              guix.%base-user-accounts))
	       (groups          (cons (guix.user-group (name username) (id 1000))
	                              guix.%base-groups))
	       (keyboard-layout (guix.keyboard-layout "us" "dvp" options: '("caps:escape"))))
		(compose-os
			include-defaults?: #f

			host-name: "nest"
			timezone:  "US/Pacific"
			locale:    "en_US.utf8"

			bootloader: (guix.bootloader-configuration (bootloader guix.grub-bootloader)
			                                           (targets '("/dev/xvda")))

			fragments: (list
				(make <os-fragment> users:  users
				                    groups: groups

				                    file-systems: (list (guix.file-system
				                    	(device (guix.file-system-label "GUIX_ROOT"))
				                    	(mount-point "/")
				                    	(type "ext4")))

				                    services: (list
				                    	(guix.service guix.openssh-service-type
				                    		(guix.openssh-configuration
				                    			(openssh                            guix.openssh-sans-x)
				                    			(password-authentication?           #f)
				                    			(challenge-response-authentication? #f)
				                    			(use-pam?                           #f))))

				                    kernel-arguments: (cons "video=1920x1080"
				                                            guix.%default-kernel-arguments))
				; Foundation
				(qubes-guest ip)

				; Presentation
				(tty keyboard-layout users groups)

				; Application
				compression
				development
				terminal-utils))))

(define utility
	(let ((users (cons (guix.user-account (name "raven")
	                                        (uid 1000)
	                                        (group name)
	                                        (supplementary-groups '("wheel" "audio" "video"))
	                                        (password "")
	                                        )
	                   guix.%base-user-accounts))
	      (groups (cons (guix.user-group (name "raven") (id 1000))
	                    guix.%base-groups))
	      (keyboard-layout (guix.keyboard-layout "us" "dvp" options: '("caps:escape")))
	      (file-systems (list (guix.file-system (mount-point "/")
	                          (device (guix.file-system-label "Guix_image"))
	                          (type "ext4")))))
		(compose-os
			include-defaults?: #f

			host-name: "roost"
			timezone:  "US/Pacific"
			locale:    "en_US.utf8"

			; this is the bootloader that the installation OS uses, probably what I want?
			bootloader: (guix.bootloader-configuration (bootloader guix.grub-bootloader)
			                                           (targets '("/dev/sda")))

			keyboard-layout: keyboard-layout

			fragments: (list
				(make <os-fragment> users:        users
				                    groups:       groups
				                    file-systems: file-systems
				)
				; Foundation
				bare-metal

				; Presentation
				(tty keyboard-layout users groups)

				; Application
				compression
				terminal-utils))))
