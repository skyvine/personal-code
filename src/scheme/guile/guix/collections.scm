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
; This module defines groups of packages, services, and other operating-system inputs
; make it easier to sync common changes between different types of systems. I do not
; directly rely on any of the collections define in guix (for example, %base-services)
; because the process of stripping down the system to a bare minimum, converting it into
; a lisp machine, and rebuilding it as a lisp machine will require that I examine each
; member in detail anway. So in addition to keeping changes synced, this file serves as
; a todo list.
;
; # Ramblings about reasoning & intentions for lisp machine
; Essential components are guile and/or rust. Both of these languages speak to me, but
; they are not harmonized with each other. Harmonization seems difficult because guile is
; closely married to c already, but would minimize duplicate work. In favor of guile alone
; is all the work that has gone into the VM, the existence of guix, the beginning of a
; scsh implementation, deep integration with unix, and commitment to *free* software. In
; favor of rust alone is the shockingly effective integration of high-level concepts into
; a systems language without sacrificing the raw power of c and the macro system that
; actually just lets you program the compiler which is the objectively correct way to do
; macros (the convenience forms of macros, eg macro_rules!, are fine as an addition).

(read-set! keywords #f)

(define-module (skyler guix collections)

	#:use-module (ice-9 optargs)

	#:use-module ((gnu packages)                    #:prefix guix.)
	#:use-module ((gnu services)                    #:prefix guix.)
	#:use-module ((gnu system accounts)             #:prefix guix.)
	#:use-module ((gnu system file-systems)         #:prefix guix.)
	#:use-module ((guix channels)                   #:prefix guix.)
	#:use-module ((guix config)                     #:prefix guix.)
	#:use-module ((guix profiles)                   #:prefix guix.)
	#:use-module ((guix gexp)                       #:prefix guix.)
	#:use-module ((guix transformations)            #:prefix guix.)

; package & service modules come last
	#:use-module ((gnu packages admin)              #:prefix guix.)
	#:use-module ((gnu packages aspell)             #:prefix guix.)
	#:use-module ((gnu packages base)               #:prefix guix.)
	#:use-module ((gnu packages certs)              #:prefix guix.)
	#:use-module ((gnu packages code)               #:prefix guix.)
	#:use-module ((gnu packages commencement)       #:prefix guix.)
	#:use-module ((gnu packages compression)        #:prefix guix.)
	#:use-module ((gnu packages cryptsetup)         #:prefix guix.)
	#:use-module ((gnu packages education)          #:prefix guix.)
	#:use-module ((gnu packages emacs)              #:prefix guix.)
	#:use-module ((gnu packages emacs-xyz)          #:prefix guix.)
	#:use-module ((gnu packages freedesktop)        #:prefix guix.)
	#:use-module ((gnu packages glib)               #:prefix guix.)
	#:use-module ((gnu packages gtk)                #:prefix guix.)
	#:use-module ((gnu packages gnome)              #:prefix guix.)
	#:use-module ((gnu packages gnome-xyz)          #:prefix guix.)
	#:use-module ((gnu packages gnuzilla)           #:prefix guix.)
	#:use-module ((gnu packages guile)              #:prefix guix.)
	#:use-module ((gnu packages guile-xyz)          #:prefix guix.)
	#:use-module ((gnu packages kde-systemtools)    #:prefix guix.)
	#:use-module ((gnu packages less)               #:prefix guix.)
	#:use-module ((gnu packages libreoffice)        #:prefix guix.)
	#:use-module ((gnu packages libusb)             #:prefix guix.)
	#:use-module ((gnu packages linux)              #:prefix guix.)
	#:use-module ((gnu packages man)                #:prefix guix.)
	#:use-module ((gnu packages ncurses)            #:prefix guix.)
	#:use-module ((gnu packages package-management) #:prefix guix.)
	#:use-module ((gnu packages pciutils)           #:prefix guix.)
	#:use-module ((gnu packages python)             #:prefix guix.)
	#:use-module ((gnu packages rust)               #:prefix guix.)
	#:use-module ((gnu packages rust-apps)          #:prefix guix.)
	#:use-module ((gnu packages shells)             #:prefix guix.)
	#:use-module ((gnu packages terminals)          #:prefix guix.)
	#:use-module ((gnu packages texinfo)            #:prefix guix.)
	#:use-module ((gnu packages tmux)               #:prefix guix.)
	#:use-module ((gnu packages vim)                #:prefix guix.)
	#:use-module ((gnu packages version-control)    #:prefix guix.)
	#:use-module ((gnu packages w3m)                #:prefix guix.)
	#:use-module ((gnu packages wget)               #:prefix guix.)

	#:use-module ((gnu services avahi)      #:prefix guix.)
	#:use-module ((gnu services base)       #:prefix guix.)
	#:use-module ((gnu services dbus)       #:prefix guix.)
	#:use-module ((gnu services desktop)    #:prefix guix.)
	#:use-module ((gnu services networking) #:prefix guix.)
	#:use-module ((gnu services shepherd)   #:prefix guix.)
	#:use-module ((gnu services sound)      #:prefix guix.)
	#:use-module ((gnu services sysctl)     #:prefix guix.)
	#:use-module ((gnu services xorg)       #:prefix guix.)

	#:export (
		essential-packages
		; A list of packages which should exist on every machine, including hyper-minimal
		; machines such as routers.

		system-packages
		; A list of packages which should be included in the operating-system definition and
		; excluded from any home definitions for correct functioning. For example, the shadow
		; package contains the `su` binary and it will (thankfully) not work properly if it
		; is installed as a user package.

		luxury-packages
		; A list of packages which does not conform to lisp machine expectations, but are
		; practical for doing things at the moment.

		global-services
		; A list of services which should exist on every machine, including hyper-minimal
		; machines such as routers.

		minimal-services
		; Signature (minimal-services keyboard-layout)
		;
		; Arguments:
		; keyboard-layout: The layout that is used by default on the system.
		;
		; Returns:
		; A list of services which are used on minimalist machines intended for interactive
		; use.

		luxury-services
		; Signature (luxury-services keyboard-layout)
		;
		; Arguments:
		; keyboard-layout: The layout that is used by default on the system.
		;
		; Returns:
		; A list of services which are used on traditional interactive machines.

		normal-networking-services
		; A list of networking services that enable networking in traditional environments.

		qubes-networking-services
		; Signature: (qubes-networking-services ip virtual-dns)
		;
		; Arguments:
		; ip: A string containing the IP address assigned to the Qube by Guix. Must contain
		;     the netmask using slash notation.
		;
		; virtual-dns: A list of IP addresses that are used as DNS servers. Please use the
		;              ones listed in the Qubes settings, not external DNS servers.

		essential-file-systems
		; Signature: (essential-file-systems users groups)
		;
		; Arguments:
		; users: The list of users installed on the target operating-system
		;
		; groups: The list of groups installed on the target operating-system
		;
		; Returns:
		; A list of filesystems that should be included in an operating system definition.
		; This exists mostly because XDG_RUNTIME_DIR is typically created by some init script
		; in a desktop environment, and guix can run into problems if this directory does
		; not exist. This need is why the users and groups must be passed in, and
		; unfortunately this implementation which declares the directories instead of creating
		; them imperatively imposes the requirement that UIDs and GIDs are declared explicitly
		; (if they are not explicitly declared, then these are also created imperatively).
))

(use-modules (skyler standard)
             ((skyler guix packages) #:prefix sky.)
             ((skyler guix services) #:prefix sky.))

(read-set! keywords 'postfix)

; Package Collections
(define essential-packages
	(list
		; Acceptable for Inclusion
		guix.guile-3.0-latest
		guix.guile-colorized
		guix.guile-readline

		;; kernel stuff
		guix.eudev ; sets up /dev directory; eudev is the gentoo fork of plain udev
		guix.kmod ; kernel module utils: modprobe, etc

		; Harmonization Needed
		guix.cryptsetup
		guix.info-reader
		(list guix.glib "bin") ; gio

		; emacs is dope but context switching between lisp dialects is paaaaaiiinful
		; FIXME: stop using absolute paths local to your system you monster!
		((guix.options->transformation
			'((with-patch . "neovim=%%patches share/patches/neovim-fixed-width-tabs.patch%%")))
			guix.neovim)

		sky.neovim-solarized8

		;; I'm not sure if we have enough compression algorithms yet
		guix.tar ; reducing inode usage could technically be considered compression :P
		guix.gzip
		guix.bzip2
		guix.lzip
		guix.xz
		guix.zip

		; New Versions Needed (possibly promote to harmonization)
		guix.atool
		guix.coreutils
		guix.diffutils
		guix.tmux
		guix.wget

		;;; contains fuser which IIUC has been critical in the rare instances where some
		;;; hardware locked up resource is
		guix.psmisc 

		;;; contains a boatload of things you expect (fdisk, su, kill, mount, etc)
		;;; the +udev adds eudev as a dependency to util-linux
		guix.util-linux+udev

		; Need Consideration
		;; misc stuff I've accrued over the years
		guix.git
		guix.ispell
		guix.kbd ; keyboard tools
		guix.less
		guix.man-pages ; linux & c man pages
		guix.nss-certs ; required for https
		guix.the-silver-searcher
		guix.tree
		guix.w3m
		))

(define system-packages (list
		guix.glibc-locales

		; Acceptable for Inclusion
		;; kernel stuff
		guix.eudev ; sets up /dev directory; eudev is the gentoo fork of plain udev
		guix.kmod ; kernel module utils: modprobe, etc

		; New Versions Needed (possibly promote to harmonization)
		guix.e2fsprogs

		guix.inetutils ; server & client, but also ping & traceroute
		guix.iproute
		guix.isc-dhcp ; dhcp client
		guix.ncurses ; required to clear the screen
		guix.network-manager
		guix.procps ; ps command
		guix.which

		; Deprecation
		guix.iw ; iw command, maybe replacable by network-manager?
		guix.wireless-tools ; deprecated wireless commands, maybe replacable by network-manager?

		; Need Consideration
		guix.shadow
		guix.sudo

		;; from %base-packages-linux
		guix.pciutils ; pci is the port for peripherals like gfx card
		guix.usbutils

))

(define luxury-packages (list
	guix.emacs
	guix.gnome-tweaks
	guix.guile-wisp
	guix.gwl
	guix.haunt
	guix.icecat
	guix.konsole
	guix.libreoffice
))

; Service Collections
(define global-services (list
	(guix.service guix.sysctl-service-type) ; kernel parameter config, different than systemctl
	(guix.service guix.avahi-service-type) ; DNS discovery
	(guix.service guix.syslog-service-type (guix.syslog-configuration))
	(guix.service guix.static-networking-service-type (list guix.%loopback-static-networking))
	(guix.service guix.gpm-service-type) ; mouse support in raw ttys
	(guix.service guix.urandom-seed-service-type)
	(guix.service guix.nscd-service-type) ; name service cache daemon, for passwords, groups, and hosts
	(guix.simple-service 'mtp guix.udev-service-type (list guix.libmtp)) ; Media Transfer Protocol
	(guix.service guix.upower-service-type) ; power monitoring, inc. battery status
	(guix.service guix.ntp-service-type) ; Network Time Protocol

	(guix.service guix.special-files-service-type
		`(("/bin/sh" ,(guix.file-append guix.dash "/bin/dash")) ; snowflaking FTW
		  ("/usr/bin/env",(guix.file-append guix.coreutils "/bin/env"))
	))

	; IPC mechanisms for processes that need to communicate without being aware of each
	; other at development time. For example, a message that a call has started needs to
	; be sent to any and all processes which might be playing audio.
	(guix.service guix.dbus-root-service-type)

	; permissions management
	(guix.service guix.polkit-service-type)
	guix.polkit-wheel-service ; enables the wheel group

	; all store services: garbage collector, builder, etc
	(guix.service guix.guix-service-type
		(guix.guix-configuration
		(authorize-key? #t)
		(guix (guix.current-guix))))

	(guix.service guix.udev-service-type ; sets up /dev
		(guix.udev-configuration (rules (list
			; for creating the mapper entries
			guix.lvm2

			; Filesystem in USErspace, for non-privileged filesystem creation and editing
			guix.fuse

			; Advanced Linux Sound Architecture
			guix.alsa-utils

			; helps regulatory compliance for wireless signals
			guix.crda
	))))
))

(define (minimal-services keyboard-layout) (cons*
	(guix.service guix.login-service-type
	              (guix.login-configuration (allow-empty-passwords? #t)))
	(map (lambda (tty)
		(guix.service sky.kmscon-with-configurable-resolution-service-type
			(sky.kmscon-with-configurable-resolution-configuration
				(virtual-terminal  (string-append "tty" (number->string tty)))
				(screen-resolution (cons 1920 1080))
				(login-program     (guix.file-append guix.shadow "/bin/login"))
				(keyboard-layout   keyboard-layout))))
		'(1 2 3 4 5 6 7 8 9))
))

(define (luxury-services keyboard-layout) (list
	; for use on, for example, a full install to a laptop
	(guix.service guix.gdm-service-type)
	(guix.service guix.gnome-desktop-service-type)
	(guix.set-xorg-configuration (guix.xorg-configuration (keyboard-layout keyboard-layout)))
	guix.gdm-file-system-service ; enhances Gnome Display Manager performance w/ cache
	guix.fontconfig-file-system-service ; compatibility service for fontconfig on guix

	; audio management
	(guix.service guix.pulseaudio-service-type)
	(guix.service guix.alsa-service-type)

	; Scanners Are Now Easy, visual scanning ranging from external cameras to screenshots
	(guix.service guix.sane-service-type)

	; Gnome uses this for some session management tasks, it allows unprivileged access to
	; some pieces of user information (list of accounts, associated metadata)
	(guix.service guix.accountsservice-service-type)

	; printer privileges
	(guix.service guix.cups-pk-helper-service-type)

	; adjusts colors based on device differences (inter-computer and image captures)
	(guix.service guix.colord-service-type)

	guix.x11-socket-directory-service ; compat between wayland and X11
))

(define normal-networking-services (list
	; wpa-supplicant IS an external NetworkManager dependency
	(guix.service guix.wpa-supplicant-service-type)
	(guix.service guix.network-manager-service-type)
))

;; WARNING: Even with this config, networking is finnicky. If you need to change
;; networks, you might need to reboot guix. It also doesn't seem to work when the network
;; is provided by whonix.
(define* (qubes-networking-services key: ip virtual-dns) (list
	(guix.service guix.static-networking-service-type
		(list
			(guix.static-networking
				(addresses (list (guix.network-address (device "eth0")
				                                       (value ip))))
				(routes (list (guix.network-route
				               (destination "default")
				               (device "eth0"))))
				(name-servers virtual-dns))
))))

; File System Collections
(define (get-gid-by-name name groups)
	(let ((matches (filter (lambda (group) (string=? (guix.user-group-name group)) name)
												 groups)))
		(if (>= (length matches) 1)
			(guix.user-group-id (car matches))
			(error (string-append "The group " name " must have an explicitly defined GID!"
														" Add a (gid <number>) form to the group definition (and"
														" probably add a (groups (user-group ...)) form to the"
														" operating-system definition")))))

(define (get-user-gid user groups)
	(unless (guix.user-account-group user)
		(error (string-append "The user " (guix.user-account-name user)
		                      " must have an explicitly defined group! Add"
		                      " (group <name|number>) to the user definition.")))

	(let ((gid (if (number? (guix.user-account-group user))
	           	(guix.user-account-group user)
	           	(get-gid-by-name (guix.user-account-group user) groups))))
		(number->string gid)))

(define (get-user-uid user)
	(unless (guix.user-account-uid user)
		(error (string-append "The user " (guix.user-account-name user)
		                      " must have an explicitly defined UID! Add (uid <number>) to"
		                      " the user definition.")))
	(number->string (guix.user-account-uid user)))

(define (essential-file-systems users groups) (append
	(list
		; I prefer /tmp to be tmpfs, but this can cause problems when substitutes are not
		; available because builds can be large. Will figure out a better solution later.
		;(guix.file-system
		;	(device              "tmpfs")
		;	(mount-point         "/tmp")
		;	(type                "tmpfs")
		;	(check?              #f)
		;	(options             "mode=0777")
		;	(create-mount-point? #t))
	)
	(map (lambda (user)
		(let ((uid (get-user-uid user))
		      (gid (get-user-gid user groups)))
			(guix.file-system
				(device              "tmpfs")
				(mount-point         (string-append "/run/user/" uid))
				(type                "tmpfs")
				(check?              #f)
				(options             (format #f "mode=0700,uid=~a,gid=~a" uid gid))
				(create-mount-point? #t))))
		(filter (lambda (u) (not (guix.user-account-system? u))) users))
	guix.%base-file-systems))
