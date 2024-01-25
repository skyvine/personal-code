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
; This provides a set of operating-system-fragments which help me manage different
; installations in a way that is consistent where it makes sense and specific where it
; makes sense. All of the fragments can be divided into 3 categories: foundation,
; presentation, and application.
;
; ## Foundation Fragments 
; A foundation fragment supplies the core components required to make a system function in
; a particular context. Foundation fragment are differentiated by the environment in which
; the system will be used, For instance, the foundation fragment for a system which will
; be installed directly onto a computer as the primary operating system is different than
; the foundation fragment for a system that will be installed as a guest in QubesOS.
;
; Foundation fragments also supply components which are essential for system operation
; regardless of context, such as eudev to set up the /dev directory and nss-certs which
; are required to use https. This means that foundation fragments are doing 2 things, and
; this needs to be fixed.
;
; ## Presentation Fragments
; Presentation fragments deal with the manner in which software is made accessible to the
; user. This would typically mean that it provides the facilities of a specific desktop
; environment such as GNOME, but currently I only implement a tty-based machine. In the
; future, there will also be a qubes UX integration fragment, which is different than the
; foundation fragment which is concerned with basic operation (the foundation provides
; things like the networking service which will be needed even if the Guix guest is
; running in a dedicated window).
;
; In principle, presentation fragments should be supplied on a per-user basis. If one user
; wants to use i3, another Gnome, and another kmscon, there is no conflict so long as they
; are not trying to use the same physical machine simultaneously (at which point they have
; bigger problems to worry about).
;
; ## Application Fragments
; Application fragments provide the things that a user will be directly using, such as
; command-line utilities, web browsers, terminal emulators, etc. These are naturally
; package-centric, but there is nothing preventing them from providing services, file
; systems, etc if it makes sense.

(read-set! keywords #f)

(define-module (skyler guix collections)

	#:use-module (ice-9 optargs)
	#:use-module (oop goops)

	#:use-module ((gnu packages)                    #:prefix guix.)
	#:use-module ((gnu services)                    #:prefix guix.)
	#:use-module ((gnu system)                      #:prefix guix.)
	#:use-module ((gnu system accounts)             #:prefix guix.)
	#:use-module ((gnu system file-systems)         #:prefix guix.)
	#:use-module ((gnu system locale)               #:prefix guix.)
	#:use-module ((guix channels)                   #:prefix guix.)
	#:use-module ((guix config)                     #:prefix guix.)
	#:use-module ((guix profiles)                   #:prefix guix.)
	#:use-module ((guix gexp)                       #:prefix guix.)
	#:use-module ((gnu system)                      #:prefix guix.)
	#:use-module ((gnu system pam)                  #:prefix guix.)
	#:use-module ((gnu system shadow)               #:prefix guix.)
	#:use-module ((guix transformations)            #:prefix guix.)

; package & service modules come last
	#:use-module ((gnu packages admin)              #:prefix guix.)
	#:use-module ((gnu packages base)               #:prefix guix.)
	#:use-module ((gnu packages certs)              #:prefix guix.)
	#:use-module ((gnu packages code)               #:prefix guix.)
	#:use-module ((gnu packages compression)        #:prefix guix.)
	#:use-module ((gnu packages cryptsetup)         #:prefix guix.)
	#:use-module ((gnu packages file)               #:prefix guix.)
	#:use-module ((gnu packages gnupg)              #:prefix guix.)
	#:use-module ((gnu packages glib)               #:prefix guix.)
	#:use-module ((gnu packages gnome)              #:prefix guix.)
	#:use-module ((gnu packages guile)              #:prefix guix.)
	#:use-module ((gnu packages guile-xyz)          #:prefix guix.)
	#:use-module ((gnu packages less)               #:prefix guix.)
	#:use-module ((gnu packages linux)              #:prefix guix.)
	#:use-module ((gnu packages man)                #:prefix guix.)
	#:use-module ((gnu packages package-management) #:prefix guix.)
	#:use-module ((gnu packages pciutils)           #:prefix guix.)
	#:use-module ((gnu packages qubes)              #:prefix guix.)
	#:use-module ((gnu packages shells)             #:prefix guix.)
	#:use-module ((gnu packages texinfo)            #:prefix guix.)
	#:use-module ((gnu packages tmux)               #:prefix guix.)
	#:use-module ((gnu packages vim)                #:prefix guix.)
	#:use-module ((gnu packages version-control)    #:prefix guix.)
	#:use-module ((gnu packages wget)               #:prefix guix.)

	#:use-module ((gnu services avahi)      #:prefix guix.)
	#:use-module ((gnu services base)       #:prefix guix.)
	#:use-module ((gnu services desktop)    #:prefix guix.)
	#:use-module ((gnu services linux)      #:prefix guix.)
	#:use-module ((gnu services mail)       #:prefix guix.)
	#:use-module ((gnu services networking) #:prefix guix.)
	#:use-module ((gnu services qubes)      #:prefix guix.)
	#:use-module ((gnu services sysctl)     #:prefix guix.)

	#:use-module (skyler guix packages)
	#:use-module (skyler guix services)

	#:export (
		; All exported symbols are <os-frament> values, or procedures returning such a value

		; Foundation Fragments
		bare-metal
		; Provides components required to run a system directly on hardware. This is a typical
		; install onto a computer, or for building a disk image.

		qubes-guest
		; Provides components required to run a system as a Qubes guest with WIP integration.
		; Currently provides:
		; - Mounted xenfs
		; - QubesDB service
		; - Automatic network configuration

		; Presentation Fragments
		tty
		; Signature: (tty keyboard-layout users groups)
		;
		; Arguments:
		; keyboard-layout: The default keyboard layout that kmscon will use.
		;
		; users/groups: The complete list of non-system users and groups that will be
		;               instantiated. They must have explicitly defined UIDs and GIDs.
		;               System users/groups are safe to include in the list, but will be
		;               ignored. These parameters should not be required and will be removed
		;               in the future.
		;
		; Returns:
		; Provides components which allow the user to use a "tty" ergonomically. In
		; particular, it uses kmscon for better graphical support.

		; Application Fragments
		compression
		; Provides components related to de-/compression. This includes atool as a front-end
		; so that you don't have to memorize a million different interfaces, as well as the
		; back-ends it relies on.

		development
		; Provides components exclusively useful when developing software.

		email
		; Signature: (email key: (exim-config (exim-configuration)) (aliases '()))
		;
		; Arguments:
		; exim-config: An <exim-configuration>.
		;
		; aliases: An alist of email aliases, as understood by mail-aliases-service-type.
		;
		; Returns:
		; An operating-system fragment which is suitable for sending mail to remote servers.
		; This is useful, for example, when used with `git send-email`.

		terminal-utils
		; Provides components which facilitate a terminal-based workflow in general. This is
		; useful even on machines with full desktop environments (unless you prefer to not
		; have coreutils installed ;)
))


(read-set! keywords 'postfix)

; Foundation Fragments

;; Helpers
;;; Things which are common to all foundation fragments. Avoid repeating myself.
(define foundation-common
	(guix.operating-system-fragment
		(kernel-arguments-fragment   guix.%default-kernel-arguments)
		(firmware-fragment           guix.%base-firmware)
		(skeletons-fragment          (guix.default-skeletons))
		(locale-definitions-fragment guix.%default-locale-definitions)
		(locale-libcs-fragment       guix.%default-locale-libcs)
		(pam-services-fragment       (guix.base-pam-services))
		(setuid-programs-fragment    guix.%setuid-programs)

		(packages-fragment (list
			guix.eudev ; sets up /dev directory; eudev is the gentoo fork of plain udev
			guix.glibc-locales
			guix.kmod ; kernel module utils: modprobe, etc
			guix.nss-certs ; required for https
			guix.shadow
			guix.sudo))

		(services-fragment (list
			(guix.service guix.guix-service-type
				(guix.guix-configuration
				(authorize-key? #t)
				(guix (guix.current-guix))))
			(guix.service guix.ntp-service-type) ; Network Time Protocol
			; name service cache daemon, for passwords, groups, and hosts
			(guix.service guix.nscd-service-type)
			(guix.service guix.special-files-service-type
				`(("/bin/sh"      ,(guix.file-append guix.dash      "/bin/dash"))
				  ("/usr/bin/env" ,(guix.file-append guix.coreutils "/bin/env"))))
			(guix.service guix.static-networking-service-type
			              (list guix.%loopback-static-networking))
			; kernel parameter config, different than systemctl
			(guix.service guix.sysctl-service-type)
			(guix.service guix.syslog-service-type (guix.syslog-configuration))
			(guix.service guix.udev-service-type ; sets up /dev
				(guix.udev-configuration (rules (list
					; for creating the mapper entries
					guix.lvm2

					; Filesystem in USErspace, for non-privileged filesystem creation and editing
					guix.fuse

					; Advanced Linux Sound Architecture
					guix.alsa-utils

					; helps regulatory compliance for wireless signals
					guix.crda))))
			(guix.service guix.upower-service-type) ; power monitoring, inc. battery status
			(guix.service guix.urandom-seed-service-type)))

		(file-systems-fragment guix.%base-file-systems)
			; TODO: I prefer /tmp to be tmpfs, but this can cause problems when substitutes are
			; not available (particularly common during development =) because builds can be
			; large. Will figure out a better solution later.
			;file-systems: (list
			;	(guix.file-system
			;		(device              "tmpfs")
			;		(mount-point         "/tmp")
			;		(type                "tmpfs")
			;		(check?              #f)
			;		(options             "mode=0777")
			;		(create-mount-point? #t))
		))

(define bare-metal
	(guix.operating-system-fragment
		(inherit foundation-common)
		(packages-fragment (append
			(list guix.network-manager)
			(guix.operating-system-packages-fragment foundation-common)))
		(services-fragment (append
			(list
				(guix.service guix.avahi-service-type) ; DNS discovery
				(guix.service guix.network-manager-service-type)
				; wpa-supplicant IS an external NetworkManager dependency
				(guix.service guix.wpa-supplicant-service-type))
			(guix.operating-system-user-services-fragment foundation-common)))))

(define xen-guest
	(guix.operating-system-fragment
		(inherit foundation-common)
		(services-fragment (append
			(list
				(guix.service guix.kernel-module-loader-service-type
					; The list of modules here might be incomplete. It is based on the output of
					; `lsmod` and `/lib/modules/$(uname -r)/modules.builtin` on Debian and Fedora
					; guests.
					'("xen_blkback"
					  ; "xen_blkfront"          built-in module
					  ; "xenbus"                built-in module
					  ; "xenbus_probe_frontend" built-in module
					  "xen_evtchn"
					  "xen_fbfront"
					  "xen_gntdev"
					  ; "xen_netfront"          built-in module
					  "xen_privcmd"

					  ; The following modules only appear on 1 of the guests. This might
					  ; have to do with distro-dependent functionality, or it might have
					  ; to do with the way the guests are configured, although I have
					  ; not substantially changed the relevant guests from the default
					  ; configurations (no directly attached devices, etc, just changing
					  ; the number of vCPUs and RAM limit).
					  "xen_scsiback" ; only appears on Fedora guest
					  "xenfs"        ; only appear on Debian guest
					)))
			(guix.operating-system-user-services-fragment foundation-common)))
		(file-systems-fragment (append
			(list
				(guix.file-system
					(mount-point "/proc/xen")
					(device      "xenfs")
					(type        "xenfs")))
			(guix.operating-system-file-systems-fragment foundation-common)))))

(define qubes-guest
	(guix.operating-system-fragment
		(inherit xen-guest)
		(packages-fragment (append
			(list guix.qubesdb)
			(guix.operating-system-packages-fragment xen-guest)))
		(services-fragment (append
			(list
				(guix.service guix.qubesdb-service-type)
				(guix.service guix.qubes-networking-service-type))
			(guix.operating-system-user-services-fragment xen-guest)))))

; Presentation Fragments
;;; FIXME: this should not require foreknowledge of the existing users and groups. See the
;;;        note in the filesystems definition.
(define* (tty keyboard-layout users groups) (let*
	((get-gid-by-name (lambda (name groups)
	 	(let ((matches (filter (lambda (group) (string=? (guix.user-group-name group)) name)
	 	                       groups)))
	 		(if (>= (length matches) 1)
	 			(guix.user-group-id (car matches))
	 			(error (string-append "The group " name " must have an explicitly defined GID!"
	 			                      " Add a (gid <number>) form to the group definition."))))))

	 (get-user-gid (lambda (user groups)
	 	(unless (guix.user-account-group user)
	 		(error (string-append "The user " (guix.user-account-name user)
	 		                      " must have an explicitly defined group! Add"
	 		                      " (group <name|number>) to the user definition.")))

	 	(let ((gid (if (number? (guix.user-account-group user))
	 	           	(guix.user-account-group user)
	 	           	(get-gid-by-name (guix.user-account-group user) groups))))
	 		(number->string gid))))

	 (get-user-uid (lambda (user)
	 	(unless (guix.user-account-uid user)
	 		(error (string-append "The user " (guix.user-account-name user)
	 		                      " must have an explicitly defined UID! Add (uid <number>) to"
	 		                      " the user definition.")))
	 	(number->string (guix.user-account-uid user)))))

		(guix.operating-system-fragment
			(services-fragment (cons
				(guix.service guix.login-service-type)
				(map (lambda (tty)
					(guix.service kmscon-with-configurable-resolution-service-type
						(kmscon-with-configurable-resolution-configuration
							(virtual-terminal  (string-append "tty" (number->string tty)))
							(screen-resolution (cons 1920 1080))
							(login-program     (guix.file-append guix.shadow "/bin/login"))
							(keyboard-layout   keyboard-layout))))
					'(1 2 3 4 5 6 7 8 9))))
			; Provide the XDG_RUNTIME_DIR which many programs implicitly depend on. This is in
			; the presentation layer because I have previously seen a conflict when trying to
			; use this alongside a full desktop enviornment. Looking at the guix source again,
			; this is managed by the greetd service which should be able to launch kmscon just
			; as easily as anything else, so perhaps this can be revisited. This concern
			; should NOT be in the presentation layer. It also feels a bit off to call it a
			; foundation component. This is why it seems like there should be something in the
			; middle, because desktops inevitably end up assuming common attributes about
			; their environment (such as the existence of certain filesystems or serivces)
			; which are in principle independent of the physical/virtualized context they are
			; running in, which is most properly the concern of the foundation layer.
			(file-systems-fragment (map (lambda (user)
				(let ((uid (get-user-uid user))
				      (gid (get-user-gid user groups)))
					(guix.file-system
						; I don't know if this is normally a tmpfs, but the XDG basedir standard
						; says that it MUST not survive a reboot, so being tmpfs shouldn't cause any
						; problems. This is technically not compliant because it also says that the
						; contents MUST be removed if the user fully logs out (implicitly, even if
						; the system remains powered on) and I'm not doing that. It looks like guix
						; has a predefined greetd configuration to handle this correctly.
						(device              "tmpfs")
						(mount-point         (string-append "/run/user/" uid))
						(type                "tmpfs")
						(check?              #f)
						(options             (format #f "mode=0700,uid=~a,gid=~a" uid gid))
						(create-mount-point? #t))))
				(filter (negate guix.user-account-system?) users))))))

; Application Fragments
(define* terminal-utils (let ()
	(guix.operating-system-fragment
		(packages-fragment (list
			guix.guile-3.0-latest
			guix.guile-colorized
			guix.guile-readline

			guix.coreutils
			guix.cryptsetup
			guix.diffutils
			guix.e2fsprogs ; mkfs.*
			guix.file
			guix.gnupg
			guix.inetutils ; ping & traceroute
			guix.info-reader
			guix.iproute
			guix.less
			guix.man-db
			guix.pciutils ; pci is the port for peripherals like gfx card
			guix.procps ; ps command
			guix.psmisc ; fuser
			guix.the-silver-searcher
			guix.tcpdump
			guix.tmux
			guix.tree
			guix.usbutils
			guix.util-linux+udev ; fdisk, su, kill, mount, etc
			guix.wget
			guix.which

			; emacs is dope but context switching between lisp dialects is paaaaaiiinful
			((guix.options->transformation
				'((with-patch .
				   "neovim=%%patches share/patches/neovim-fixed-width-tabs.patch%%")))
				guix.neovim)
			neovim-solarized8)))))

(define compression
	(guix.operating-system-fragment
		(packages-fragment (list
			guix.bzip2
			guix.gzip
			guix.lzip
			guix.tar ; reducing inode usage could technically be considered compression :P
			guix.xz
			guix.zip

		guix.atool))))

(define development
	(guix.operating-system-fragment
		(packages-fragment (list
			guix.git
			guix.man-pages)))) ; linux & c man pages

(define* (email key: (exim-config (guix.exim-configuration)) (aliases '()))
	(guix.operating-system-fragment
		(services-fragment (list (guix.service guix.exim-service-type exim-config)
		                (guix.service guix.mail-aliases-service-type aliases)))))
