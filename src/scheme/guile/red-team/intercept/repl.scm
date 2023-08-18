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
; This module is a library for modules that want to start the intercept REPL. Most people
; will be more interested in the `(skyler red-team intercept repl interface)` module
; which, aside from having an obnoxiously long module name, contains documentation for the
; symbols available in the REPL environment.

(define-module (skyler red-team intercept repl)
	#:use-module (ice-9 colorized)
	#:use-module (ice-9 readline)
	#:use-module (srfi srfi-11)
	#:use-module (system repl repl)
	#:use-module (web client)
	#:use-module (web request)
	#:use-module (web response)
	#:use-module (web uri)

	#:use-module (skyler red-team intercept server)

	#:export (
		set-enter-hook! remove-enter-hook!
		set-exit-hook!  remove-exit-hook!
		; Signatures: (set-*-hook! name proc) (remove-*-hook! name)
		;
		; Arguments:
		; name: A symbol uniquely indentifying the hook
		;
		; proc: A thunk which will run when the hook is called.
		;
		; Returns:
		; Unspecified
		;
		; These hooks will be called before the REPL is entered and after it exits.

		repl
		; The intercept REPL is a guile repl preconfigured for ease of use (readline,
		; colorized). Additionally, symbols relevant to interception (eg, this module's
		; interface) will be available.
))

(define enter-hooks '())
(define exit-hooks  '())

(define (set-enter-hook! name proc)
	(set! enter-hooks (assq-set! enter-hooks name proc)))

(define (remove-enter-hook! name)
	(set! enter-hooks (assq-remove! enter-hooks name)))

(define (set-exit-hook! name proc)
	(set! exit-hooks (assq-set! exit-hooks name proc)))

(define (remove-enter-hook! name)
	(set! exit-hooks (assq-remove! exit-hooks name)))

(define activated? #f)

(define (repl)
	(unless activated?
		(activate-readline)
		(activate-colorized)
		(set! activated? #t))

	(let ((interaction-module (resolve-module '(guile-user)))
	      (repl-interface     (resolve-interface '(skyler red-team intercept repl interface))))
		(module-use! interaction-module repl-interface))

	(for-each (lambda (entry) ((cdr entry))) enter-hooks)
	(start-repl)
	(for-each (lambda (entry) ((cdr entry))) exit-hooks))
