(define-module (skyler guix services)
	#:use-module (gnu packages fonts)
	#:use-module (gnu packages terminals)
	#:use-module (gnu services shepherd)
	#:use-module (gnu system keyboard)
	#:use-module (guix gexp)
	#:use-module (guix records)

	#:use-module (skyler guix packages)

	#:export (kmscon-with-configurable-resolution-service-type kmscon-with-configurable-resolution-configuration)
	)

(define-record-type* <kmscon-with-configurable-resolution-configuration>
  kmscon-with-configurable-resolution-configuration     make-kmscon-with-configurable-resolution-configuration
  kmscon-with-configurable-resolution-configuration?
  (kmscon                  kmscon-with-configurable-resolution-configuration-kmscon
                           (default kmscon-with-configurable-resolution))
  (virtual-terminal        kmscon-with-configurable-resolution-configuration-virtual-terminal)
  (login-program           kmscon-with-configurable-resolution-configuration-login-program
                           (default (file-append shadow "/bin/login")))
  (login-arguments         kmscon-with-configurable-resolution-configuration-login-arguments
                           (default '("-p")))
  (auto-login              kmscon-with-configurable-resolution-configuration-auto-login
                           (default #f))
  (hardware-acceleration?  kmscon-with-configurable-resolution-configuration-hardware-acceleration?
                           (default #f))  ; #t causes failure
  (font-engine             kmscon-with-configurable-resolution-configuration-font-engine
                           (default "pango"))
  (font-size               kmscon-with-configurable-resolution-configuration-font-size
                           (default 12))
  (screen-resolution       kmscon-with-configurable-resolution-configuration-screen-resolution
                           (default #f))
  (keyboard-layout         kmscon-with-configurable-resolution-configuration-keyboard-layout
                           (default #f))) ; #f | <keyboard-layout>

(define kmscon-with-configurable-resolution-service-type
  (shepherd-service-type
   'kmscon
   (lambda (config)
     (let ((kmscon (kmscon-with-configurable-resolution-configuration-kmscon config))
           (virtual-terminal (kmscon-with-configurable-resolution-configuration-virtual-terminal config))
           (login-program (kmscon-with-configurable-resolution-configuration-login-program config))
           (login-arguments (kmscon-with-configurable-resolution-configuration-login-arguments config))
           (auto-login (kmscon-with-configurable-resolution-configuration-auto-login config))
           (hardware-acceleration? (kmscon-with-configurable-resolution-configuration-hardware-acceleration? config))
           (font-engine (kmscon-with-configurable-resolution-configuration-font-engine config))
           (font-size (kmscon-with-configurable-resolution-configuration-font-size config))
           (screen-resolution (kmscon-with-configurable-resolution-configuration-screen-resolution config))
           (keyboard-layout (kmscon-with-configurable-resolution-configuration-keyboard-layout config)))

       (define kmscon-command
         #~(list
            #$(file-append kmscon "/bin/kmscon") "--login"
            "--vt" #$virtual-terminal
            #$@(if screen-resolution
                 `("--desired-width" ,(number->string (car screen-resolution))
                   "--desired-height" ,(number->string (cdr screen-resolution)))
                 '())
            "--no-switchvt" ;Prevent a switch to the virtual terminal.
            "--font-engine" #$font-engine
            "--font-size" #$(number->string font-size)
            #$@(if keyboard-layout
                   (let* ((layout (keyboard-layout-name keyboard-layout))
                          (variant (keyboard-layout-variant keyboard-layout))
                          (model (keyboard-layout-model keyboard-layout))
                          (options (keyboard-layout-options keyboard-layout)))
                     `("--xkb-layout" ,layout
                       ,@(if variant `("--xkb-variant" ,variant) '())
                       ,@(if model `("--xkb-model" ,model) '())
                       ,@(if (null? options)
                             '()
                             `("--xkb-options" ,(string-join options ",")))))
                   '())
            #$@(if hardware-acceleration? '("--hwaccel") '())
            "--login" "--"
            #$login-program #$@login-arguments
            #$@(if auto-login
                   #~(#$auto-login)
                   #~())))

       (shepherd-service
        (documentation "kmscon virtual terminal")
        (requirement '(user-processes udev dbus-system))
        (provision (list (symbol-append 'term- (string->symbol virtual-terminal))))
        (start #~(make-forkexec-constructor
                  #$kmscon-command

                  ;; The installer needs to be able to display glyphs from
                  ;; various scripts, so give it access to unifont.
                  ;; TODO: Make this configurable.
                  #:environment-variables
                  (list (string-append "XDG_DATA_DIRS="
                                       #+font-gnu-unifont "/share"))))
        (stop #~(make-kill-destructor)))))
   (description "Start the @command{kmscon} virtual terminal emulator for the
Linux @dfn{kernel mode setting} (KMS).")))
