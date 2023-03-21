(define-module (skyler guix systems)
	#:use-module ((gnu bootloader)          #:prefix guix:)
	#:use-module ((gnu bootloader grub)     #:prefix guix:)
	#:use-module ((gnu services)            #:prefix guix:)
	#:use-module ((gnu system)              #:prefix guix:)
	#:use-module ((gnu system accounts)     #:prefix guix:)
	#:use-module ((gnu system file-systems) #:prefix guix:)
	#:use-module ((gnu system keyboard)     #:prefix guix:)
	#:use-module ((gnu system shadow)       #:prefix guix:)
	#:use-module ((guix gexp)               #:prefix guix:)
	#:use-module ((skyler guix collections) #:prefix sky:)

	#:use-module ((gnu packages guile)  #:prefix guix:) ; for setting my default "shell"
	#:use-module ((gnu packages shells) #:prefix guix:) ; for setting my default shell

	#:export (guix-system portable-system)
)

(define (guix-system ip virtual-dns)
	(guix:operating-system
		(host-name "urithiru")
		(timezone "US/Pacific")
		(locale "en_US.utf8")

		(bootloader (guix:bootloader-configuration (bootloader guix:grub-bootloader)
		                                           (targets '("/dev/xvda"))))

		(file-systems (cons (guix:file-system
		                      (device "/dev/xvda2")
		                      (mount-point "/")
		                      (type "ext4"))
		                    sky:essential-file-systems))

		(keyboard-layout (guix:keyboard-layout "us" "dvp" #:options '("caps:escape")))
		(users (cons
		        (guix:user-account (name "skyler")
		                           (group "users")
		                           (supplementary-groups '("wheel"
		                                                   "audio"
		                                                   "video"))
		                           (shell (guix:file-append guix:fish "/bin/fish")))
		        guix:%base-user-accounts))

		(packages (append sky:essential-packages sky:luxury-packages))

		(services (append sky:global-services (sky:luxury-services keyboard-layout)
		                  (sky:qubes-networking-services #:ip ip
		                                                 #:virtual-dns virtual-dns)))))

(define portable-system (guix:operating-system
	(host-name "raccoon")
	(timezone "US/Pacific")
	(locale "en_US.utf8")

	; this is the bootloader that the installation OS uses, probably what I want?
	(bootloader (guix:bootloader-configuration (bootloader guix:grub-bootloader)
	                                           (targets '("/dev/sda"))))

	(file-systems (cons*
		(guix:file-system (mount-point "/")
		                  (device (guix:file-system-label "Guix_image"))
		                  (type "ext4"))
		sky:essential-file-systems))

	(users (list
		(guix:user-account
			(name "sly-cooper")
			(group "users")
			(supplementary-groups '("wheel" "audio" "video"))
			(password "")
			(shell (guix:file-append guix:guile-3.0-latest "/bin/guile")))))

	(services (append
		(guix:modify-services sky:global-services
			(guix:nscd-service-type unused =>
				; this configuration is allegedly better for running on USBs
				(guix:nscd-configuration (caches (@@ (gnu system install) %nscd-minimal-caches)))))
		sky:minimal-services
		sky:normal-networking-services
	))

	(packages sky:essential-packages)))

portable-system
