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
; This API is unstable. Because it's bad.
;
; Why is it bad? I am so glad you asked!
; - When actually creating an operating system, the caller typically wants to add some
;   fragment components that are specific to that installation. Creating an in-place
;   fragment is clunky. The compose-os procedure could take in these arguments to create
;   the in-place fragment internally, but this just moves the clunkiness to a different
;   spot, it doesn't actually fix it.
; - The semantic difference between foundation, presentation, and application fragments is
;   not encoded into the type system.
; - GOOPS is too heavy-handed for what I need here. I'm not doing anything complicated
;   with classes or defining methods, I just have a struct with a keyword constructor.
; - The guix-defaults fragment needs to be manually synced with upstream changes.
; - Typically guix code uses define-record-type* (from `guix records`), switching to a
;   different thing here is disorienting.
; - The composing logic is defined separately from slot definitions, even though they are
;   both dependent on the same underlying model.
;
; Probably the best thing to do is update `define-record-type*` to accept a `composer`
; argument in each field and do the combination logic generically.

(read-set! keywords #f)

(define-module (skyler guix os-fragment)
	#:use-module (oop goops)
	#:use-module (skyler class-conventions)
	#:use-module (skyler standard)
	#:use-module (srfi srfi-69)

	#:use-module ((gnu packages linux)      #:prefix guix.)
	#:use-module ((gnu services base)       #:prefix guix.)
	#:use-module ((gnu system)              #:prefix guix.)
	#:use-module ((gnu system file-systems) #:prefix guix.)
	#:use-module ((gnu system linux-initrd) #:prefix guix.)
	#:use-module ((gnu system locale)       #:prefix guix.)
	#:use-module ((gnu system nss)          #:prefix guix.)
	#:use-module ((gnu system pam)          #:prefix guix.)
	#:use-module ((gnu system shadow)       #:prefix guix.)

	#:export (
		<os-fragment>

		kernel-loadable-modules kernel-arguments firmware file-systems
		mapped-devices swap-devices users groups skeletons packages
		local-definitions locale-libcs services pam-services setuid-programs user-data

		guix-defaults

		compose-fragments

		compose-os))

(read-set! keywords 'postfix)

(define-class <os-fragment> ()
	(kernel-loadable-modules init-keyword: #:kernel-loadable-modules
	                         accessor:     kernel-loadable-modules
	                         init-form:    '())

	(kernel-arguments        init-keyword: #:kernel-arguments
	                         accessor:     kernel-arguments
	                         init-form:    '())

	(firmware                init-keyword: #:firmware
	                         accessor:     firmware
	                         init-form:    '())

	(file-systems            init-keyword: #:file-systems
	                         accessor:     file-systems
	                         init-form:    '())

	(mapped-devices          init-keyword: #:mapped-devices
	                         accessor:     mapped-devices
	                         init-form:    '())

	(swap-devices            init-keyword: #:swap-devices
	                         accessor:     swap-devices
	                         init-form:    '())

	(users                   init-keyword: #:users
	                         accessor:     users
	                         init-form:    '())

	(groups                  init-keyword: #:groups
	                         accessor:     groups
	                         init-form:    '())

	(skeletons               init-keyword: #:skeletons
	                         accessor:     skeletons
	                         init-form:    '())

	(packages                init-keyword: #:packages
	                         accessor:     packages
	                         init-form:    '())

	(locale-definitions      init-keyword: #:locale-definitions
	                         accessor:     locale-definitions
	                         init-form:    '())

	(locale-libcs            init-keyword: #:locale-libcs
	                         accessor:     locale-libcs
	                         init-form:    '())

	(services                init-keyword: #:services
	                         accessor:     services
	                         init-form:    '())

	(pam-services            init-keyword: #:pam-services
	                         accessor:     pam-services
	                         init-form:    '())

	(setuid-programs         init-keyword: #:setuid-programs
	                         accessor:     setuid-programs
	                         init-form:    '())

	(user-data               init-keyword: #:user-data
	                         init-thunk:   make-hash-table)
)

(define user-data
	(make-user-data-accessor (class-slot-definition <os-fragment> 'user-data)))

(define-method (initialize (obj <os-fragment>) initargs)
	(next-method)
	(ensure-all-slots-are-bound obj))

(define (append-composer accessor)
	(lambda (fragment result)
		(append (accessor fragment) result)))

(define guix-defaults (make <os-fragment>
	kernel-loadable-modules: '()
	kernel-arguments:        guix.%default-kernel-arguments
	firmware:                guix.%base-firmware
	file-systems:            guix.%base-file-systems
	swap-devices:            '()
	users:                   '()
	groups:                  guix.%base-groups
	skeletons:               (guix.default-skeletons)
	packages:                guix.%base-packages
	locale-definitions:      guix.%default-locale-definitions
	locale-libcs:            guix.%default-locale-libcs
	services:                guix.%base-services
	pam-services:            (guix.base-pam-services)
	setuid-programs:         guix.%setuid-programs
))

(define (compose-fragments . fragments)
	(make <os-fragment>
		kernel-loadable-modules: (fold (append-composer kernel-loadable-modules)
		                               '()
		                               fragments)
		kernel-arguments:        (fold (append-composer kernel-arguments)   '() fragments)
		firmware:                (fold (append-composer firmware)           '() fragments)
		file-systems:            (fold (append-composer file-systems)       '() fragments)
		mapped-devices:          (fold (append-composer mapped-devices)     '() fragments)
		swap-devices:            (fold (append-composer swap-devices)       '() fragments)
		users:                   (fold (append-composer users)              '() fragments)
		groups:                  (fold (append-composer groups)             '() fragments)
		skeletons:               (fold (append-composer skeletons)          '() fragments)
		packages:                (fold (append-composer packages)           '() fragments)
		locale-definitions:      (fold (append-composer locale-definitions) '() fragments)
		locale-libcs:            (fold (append-composer locale-libcs)       '() fragments)
		services:                (fold (append-composer services)           '() fragments)
		pam-services:            (fold (append-composer pam-services)       '() fragments)
		setuid-programs:         (fold (append-composer setuid-programs)    '() fragments)))

(define* (compose-os key: (host-name "guix")
                          (timezone "Etc/UTC")
                          (locale "en_US.utf8")
                          (kernel guix.linux-libre)
                          hurd
                          (initrd guix.base-initrd)
                          (initrd-modules guix.%base-initrd-modules)
                          (issue "This is the GNU system. Welcome.")
                          (name-service-switch guix.%default-nss)
                          (bootloader (error "Bootloader must be supplied!"))
                          keyboard-layout
                          (sudoers-file guix.%sudoers-specification)
                          (include-defaults? #t)
                          (fragments '()))
	(let ((input (apply compose-fragments
	                    (if include-defaults? (cons guix-defaults fragments) fragments))))
		(guix.operating-system
			(host-name               host-name)
			(timezone                timezone)
			(locale                  locale)
			(kernel                  kernel)
			(hurd                    hurd)
			(initrd                  initrd)
			(initrd-modules          initrd-modules)
			(issue                   issue)
			(name-service-switch     name-service-switch)
			(bootloader              bootloader)
			(keyboard-layout         keyboard-layout)
			(sudoers-file            sudoers-file)
			(kernel-loadable-modules (kernel-loadable-modules input))
			(kernel-arguments        (kernel-arguments input))
			(firmware                (firmware input))
			(file-systems            (file-systems input))
			(mapped-devices          (mapped-devices input))
			(swap-devices            (swap-devices input))
			(users                   (users input))
			(groups                  (groups input))
			(skeletons               (skeletons input))
			(packages                (packages input))
			(locale-definitions      (locale-definitions input))
			(locale-libcs            (locale-libcs input))
			(services                (services input))
			(pam-services            (pam-services input))
			(setuid-programs         (setuid-programs input)))))
