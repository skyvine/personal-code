(define-module (skyler guix collections)

	#:use-module (ice-9 optargs)
	#:use-module (skyler standard)

	;#:use-module ((skyler guix meta)                #:prefix sky:)
	#:use-module ((skyler guix packages)            #:prefix sky:)

	#:use-module ((gnu packages)                    #:prefix guix:)
	#:use-module ((gnu services)                    #:prefix guix:)
	#:use-module ((gnu system file-systems)         #:prefix guix:)
	#:use-module ((guix channels)                   #:prefix guix:)
	#:use-module ((guix config)                     #:prefix guix:)
	#:use-module ((guix profiles)                   #:prefix guix:)
	#:use-module ((guix gexp)                       #:prefix guix:)
	#:use-module ((guix transformations)            #:prefix guix:)
	#:use-module ((rde gexp)                        #:prefix rde:)

; package & service modules come last
	#:use-module ((gnu packages admin)              #:prefix guix:)
	#:use-module ((gnu packages aspell)             #:prefix guix:)
	#:use-module ((gnu packages base)               #:prefix guix:)
	#:use-module ((gnu packages certs)              #:prefix guix:)
	#:use-module ((gnu packages code)               #:prefix guix:)
	#:use-module ((gnu packages commencement)       #:prefix guix:)
	#:use-module ((gnu packages compression)        #:prefix guix:)
	#:use-module ((gnu packages cryptsetup)         #:prefix guix:)
	#:use-module ((gnu packages education)          #:prefix guix:)
	#:use-module ((gnu packages emacs)              #:prefix guix:)
	#:use-module ((gnu packages emacs-xyz)          #:prefix guix:)
	#:use-module ((gnu packages freedesktop)        #:prefix guix:)
	#:use-module ((gnu packages glib)               #:prefix guix:)
	#:use-module ((gnu packages gtk)                #:prefix guix:)
	#:use-module ((gnu packages gnome)              #:prefix guix:)
	#:use-module ((gnu packages gnome-xyz)          #:prefix guix:)
	#:use-module ((gnu packages gnuzilla)           #:prefix guix:)
	#:use-module ((gnu packages guile)              #:prefix guix:)
	#:use-module ((gnu packages guile-xyz)          #:prefix guix:)
	#:use-module ((gnu packages kde-systemtools)    #:prefix guix:)
	#:use-module ((gnu packages less)               #:prefix guix:)
	#:use-module ((gnu packages libreoffice)        #:prefix guix:)
	#:use-module ((gnu packages libusb)             #:prefix guix:)
	#:use-module ((gnu packages linux)              #:prefix guix:)
	#:use-module ((gnu packages man)                #:prefix guix:)
	#:use-module ((gnu packages ncurses)            #:prefix guix:)
	#:use-module ((gnu packages package-management) #:prefix guix:)
	#:use-module ((gnu packages pciutils)           #:prefix guix:)
	#:use-module ((gnu packages python)             #:prefix guix:)
	#:use-module ((gnu packages rust)               #:prefix guix:)
	#:use-module ((gnu packages rust-apps)          #:prefix guix:)
	#:use-module ((gnu packages shells)             #:prefix guix:)
	#:use-module ((gnu packages texinfo)            #:prefix guix:)
	#:use-module ((gnu packages tmux)               #:prefix guix:)
	#:use-module ((gnu packages vim)                #:prefix guix:)
	#:use-module ((gnu packages version-control)    #:prefix guix:)
	#:use-module ((gnu packages w3m)                #:prefix guix:)
	#:use-module ((gnu packages wget)               #:prefix guix:)

	#:use-module ((gnu services avahi)      #:prefix guix:)
	#:use-module ((gnu services base)       #:prefix guix:)
	#:use-module ((gnu services dbus)       #:prefix guix:)
	#:use-module ((gnu services desktop)    #:prefix guix:)
	#:use-module ((gnu services networking) #:prefix guix:)
	#:use-module ((gnu services shepherd)   #:prefix guix:)
	#:use-module ((gnu services sound)      #:prefix guix:)
	#:use-module ((gnu services sysctl)     #:prefix guix:)
	#:use-module ((gnu services xorg)       #:prefix guix:)

	#:export (
		essential-packages
		luxury-packages
	
		global-services
		minimal-services
		luxury-services
	
		normal-networking-services
		qubes-networking-services
	
		essential-file-systems
	)
)

; Package Collections
(define essential-packages
	;; Generally, I want everything on my machine to be hand-picked by me. I want to replace
	;; tools that are not harmonious with the essential components of my system. However, I will
	;; for the time being consider the kernel to be exempt, due to my lack of expertise and the
	;; difficulty of the material.

	;; Essential components are guile and/or rust. Both of these languages speak to me, but they
	;; are not harmonized with each other. Harmonization seems difficult because guile is
	;; closely married to c already, but would minimize duplicate work. In favor of guile alone
	;; is all the work that has gone into the VM, the existence of guix, the beginning of a scsh
	;; implementation, deep integration with unix, and commitment to *free* software. In favor
	;; of rust alone is the shockingly effective integration of high-level concepts into a
	;; systems language without sacrificing the raw power of c and the macro system that
	;; actually just lets you program the compiler which is the objectively correct way to do
	;; macros (the convenience forms of macros, eg macro_rules!, are fine as an addition).

	;; Note: find that thesis from Brown about extensibility of IDEs, seems generalizable
	(list
		; Acceptable for Inclusion
		guix:guile-3.0-latest
		guix:guile-colorized
		guix:guile-readline

		;; kernel stuff
		guix:eudev ; sets up /dev directory; eudev is the gentoo fork of plain udev
		guix:kmod ; kernel module utils: modprobe, etc

		; Harmonization Needed
		guix:cryptsetup
		guix:info-reader
		(list guix:glib "bin") ; gio

		; emacs is dope but context switching between lisp dialects is paaaaaiiinful
		guix:neovim
		sky:vim-solarized8

		;; I'm not sure if we have enough compression algorithms yet
		guix:tar ; reducing inode usage could technically be considered compression :P
		guix:gzip
		guix:bzip2
		guix:lzip
		guix:xz
		guix:zip

		; New Versions Needed (possibly promote to harmonization)
		guix:atool
		guix:coreutils
		guix:diffutils
		guix:e2fsprogs

		guix:inetutils ; server & client, but also ping & traceroute
		guix:iproute
		guix:isc-dhcp ; dhcp client
		guix:ncurses ; required to clear the screen
		guix:network-manager
		guix:procps ; ps command
		guix:tmux
		guix:wget
		guix:which

		;;; contains fuser which IIUC has been critical in the rare instances where some
		;;; hardware locked up resource is
		guix:psmisc 

		;;; contains a boatload of things you expect (fdisk, su, kill, mount, etc)
		;;; the +udev adds eudev as a dependency to util-linux
		guix:util-linux+udev

		; Deprecation
		guix:iw ; iw command, maybe replacable by network-manager?
		guix:wireless-tools ; deprecated wireless commands, maybe replacable by network-manager?

		; Need Consideration
		guix:shadow-with-man-pages

		;; from %base-packages-linux
		guix:pciutils ; pci is the port for peripherals like gfx card
		guix:usbutils

		;; misc stuff I've accrued over the years
		guix:git
		guix:glibc-locales
		guix:ispell
		guix:kbd ; keyboard tools
		guix:less
		guix:man-pages ; linux & c man pages
		guix:nss-certs ; required for https
		guix:sudo
		guix:the-silver-searcher
		guix:tree
		guix:w3m
		))

(define luxury-packages (list
	guix:emacs
	guix:gnome-tweaks
	guix:guile-wisp
	guix:gwl
	guix:haunt
	guix:icecat
	guix:konsole
	guix:libreoffice
))

; Service Collections
(define global-services (list
	(guix:service guix:sysctl-service-type) ; kernel parameter config, different than systemctl
	(guix:service guix:avahi-service-type) ; DNS discovery
	(guix:service guix:syslog-service-type (guix:syslog-configuration))
	(guix:service guix:static-networking-service-type (list guix:%loopback-static-networking))
	(guix:service guix:gpm-service-type) ; mouse support in raw ttys
	(guix:service guix:urandom-seed-service-type)
	(guix:service guix:nscd-service-type) ; name service cache daemon, for passwords, groups, and hosts
	(guix:simple-service 'mtp guix:udev-service-type (list guix:libmtp)) ; Media Transfer Protocol
	(guix:service guix:upower-service-type) ; power monitoring, inc. battery status
	(guix:service guix:elogind-service-type) ; power mgmt: suspend, reboot, etc; also info about active user sessions
	(guix:service guix:ntp-service-type) ; Network Time Protocol

	(guix:service guix:special-files-service-type
		`(("/bin/sh" ,(guix:file-append guix:dash "/bin/dash"))
		  ("/usr/bin/env",(guix:file-append guix:coreutils "/bin/env"))
	))

	; IPC mechanisms for processes that need to communicate without being aware of each
	; other at development time. For example, a message that a call has started needs to
	; be sent to any and all processes which might be playing audio.
	(guix:service guix:dbus-root-service-type)

	; permissions management
	(guix:service guix:polkit-service-type)
	guix:polkit-wheel-service ; enables the wheel group

	; audio management
	(guix:service guix:pulseaudio-service-type)
	(guix:service guix:alsa-service-type)

	; all store services: garbage collector, builder, etc
	(guix:service guix:guix-service-type
		(guix:guix-configuration
		(authorize-key? #t)
		(guix (guix:current-guix))))

	(guix:service guix:udev-service-type ; sets up /dev
		(guix:udev-configuration (rules (list
			; for creating the mapper entries
			guix:lvm2

			; Filesystem in USErspace, for non-privileged filesystem creation and editing
			guix:fuse

			; Advanced Linux Sound Architecture
			guix:alsa-utils

			; helps regulatory compliance for wireless signals
			guix:crda
	))))
))

(define minimal-services (list
	(guix:service guix:login-service-type
		(guix:login-configuration (allow-empty-passwords? #t)))
	(guix:service guix:kmscon-service-type
		(guix:kmscon-configuration
			(virtual-terminal "tty1")
			(login-program (guix:file-append guix:shadow "/bin/login"))))
))

(define (luxury-services keyboard-layout) (list
	; for use on, for example, a full install to a laptop
	(guix:service guix:gdm-service-type)
	(guix:service guix:gnome-desktop-service-type)
	(guix:set-xorg-configuration
		(guix:xorg-configuration (keyboard-layout keyboard-layout)))
	guix:gdm-file-system-service ; enhances Gnome Display Manager performance w/ cache
	guix:fontconfig-file-system-service ; compatibility service for fontconfig on guix

	; Scanners Are Now Easy, visual scanning ranging from external cameras to screenshots
	(guix:service guix:sane-service-type)

	; Gnome uses this for some session management tasks, it allows unprivileged access to
	; some pieces of user information (list of accounts, associated metadata)
	(guix:service guix:accountsservice-service-type)

	; printer privileges
	(guix:service guix:cups-pk-helper-service-type)

	; adjusts colors based on device differences (inter-computer and image captures)
	(guix:service guix:colord-service-type)

	guix:x11-socket-directory-service ; compat between wayland and X11
))

(define normal-networking-services (list
	; wpa-supplicant IS an external NetworkManager dependency
	(guix:service guix:wpa-supplicant-service-type)
	(guix:service guix:network-manager-service-type)
))

;; WARNING: Even with this config, networking is finnicky. If you need to change
;; networks, you might need to reboot guix. It also doesn't seem to work when the network
;; is provided by whonix.
(define* (qubes-networking-services #:key ip virtual-dns) (list
	(guix:service guix:static-networking-service-type
		(list
			(guix:static-networking
				(addresses (list (guix:network-address (device "eth0")
				                                       (value ip))))
				(routes (list (guix:network-route
				               (destination "default")
				               (device "eth0"))))
				(name-servers virtual-dns))
))))

; File System Collections
(define essential-file-systems (cons
	(guix:file-system
		(device "tmpfs")
		(mount-point "/tmp")
		(type "tmpfs")
		(check? #f)
		(options "mode=0777")
		(create-mount-point? #t))
	guix:%base-file-systems))
