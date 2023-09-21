; Copyright © 2013-2023 Ludovic Courtès <ludo@gnu.org>
; Copyright © 2015, 2016 Alex Kost <alezost@gmail.com>
; Copyright © 2015, 2016, 2020 Mark H Weaver <mhw@netris.org>
; Copyright © 2015 Sou Bunnbu <iyzsong@gmail.com>
; Copyright © 2016, 2017 Leo Famulari <leo@famulari.name>
; Copyright © 2016 David Craven <david@craven.ch>
; Copyright © 2016 Ricardo Wurmus <rekado@elephly.net>
; Copyright © 2018 Mathieu Othacehe <m.othacehe@gmail.com>
; Copyright © 2019 Efraim Flashner <efraim@flashner.co.il>
; Copyright © 2019 Tobias Geerinckx-Rice <me@tobias.gr>
; Copyright © 2019 John Soo <jsoo1@asu.edu>
; Copyright © 2019 Jan (janneke) Nieuwenhuizen <janneke@gnu.org>
; Copyright © 2020 Florian Pelz <pelzflorian@pelzflorian.de>
; Copyright © 2020, 2021 Brice Waegeneire <brice@waegenei.re>
; Copyright © 2021 qblade <qblade@protonmail.com>
; Copyright © 2021 Hui Lu <luhuins@163.com>
; Copyright © 2021, 2022, 2023 Maxim Cournoyer <maxim.cournoyer@gmail.com>
; Copyright © 2021 muradm <mail@muradm.net>
; Copyright © 2022 Guillaume Le Vaillant <glv@posteo.net>
; Copyright © 2022 Justin Veilleux <terramorpha@cock.li>
; Copyright © 2022 ( <paren@disroot.org>
; Copyright © 2023 Bruno Victal <mirai@makinata.eu>
; Copyright © 2023 Skyler Ferris <skyvine@protonmail.com>
;
; This program is free software; you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or (at
; your option) any later version.
;
; This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; Some notes on the legal-ese:
; This file is basically just a copy of some code in the Guix repository,
; tweaked to support the configurable screen resolution patch for kmscon.
; I copied all of the copyright notices from that file
; (gnu/services/base.scm, commit 77f52db416a13e195d090cad4e9e7658feb2e86b) 
; to be a safe.
;
; Additionally, most of the code in this repository is licensed under the
; AGPL because that is my preferred default. However, Guix is licensed
; under the plain GPL. I am retaining their license for this file. If I
; understand correctly, it would be compatible to mark this file as AGPL
; because of clause 13 of the GPL (I am not a lawyer), but since I only
; made a small tweak I think it is better to be respectful of their
; licensing decision.

(define-module (skyler guix services)
	#:use-module (gnu packages fonts)
	#:use-module (gnu packages terminals)
	#:use-module (gnu services shepherd)
	#:use-module (gnu system keyboard)
	#:use-module (guix gexp)
	#:use-module (guix records)

	#:use-module ((skyler guix packages) #:prefix sky.)

	#:export (
		kmscon-with-configurable-resolution-service-type
		kmscon-with-configurable-resolution-configuration)
		; These work just like Guix's kmscon-service-type and kmscon-configuration, except
		; that they also recognize the (screen-resolution (width . height)) option. Will
		; upstream if the patch is acceptable to Aetf or includable with guix directly.
)

(define-record-type* <kmscon-with-configurable-resolution-configuration>
  kmscon-with-configurable-resolution-configuration make-kmscon-with-configurable-resolution-configuration
  kmscon-with-configurable-resolution-configuration?
  (kmscon                  kmscon-with-configurable-resolution-configuration-kmscon
                           (default sky.kmscon))
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
                           (default #f)) ; #f | <keyboard-layout>
  (debug                   kmscon-with-configurable-resolution-configuration-debug
                           (default #f)))

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
           (keyboard-layout (kmscon-with-configurable-resolution-configuration-keyboard-layout config))
           (debug (kmscon-with-configurable-resolution-configuration-debug config)))
       

       (define kmscon-command
         #~(list
            #$(file-append kmscon "/bin/kmscon") "--login"
            #$@(if debug '("--debug") '())
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
