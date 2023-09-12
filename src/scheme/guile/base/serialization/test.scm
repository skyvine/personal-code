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
; These tests make sure that the serialization code works with most built-in types (see
; the exception below), a simple GOOPS class (one containing only built-in types as
; members), and a complex GOOPS class (one containing another GOOPS class as a member). It
; is recommended that users of this module write similar tests to make sure that their
; data types are compatible, particularly if they write custom serialization code. These
; tests can be facilitated by the exported `make-serialization-test`.
;
; # Un-serializable Data
; 4 types of built-in data types are considered un-serializable:
;
; ## EOF
; Writing the EOF character seems problematic and not particularly useful. The argument
; for excluding this is weak and in principle it can be serialized, but the need has not
; come up yet.
;
; ## Port
; A port is dependent on run-time state, so trying to serialize it is absurd.
;
; ## Procedure
; Procedures can be serialized in principle, but the implementation would be quite complex
; and introduces a number of security risks. GNU Guix accomplishes this through
; G-Expressions which are very sophisticated; this module is intended for more
; straightforward use-cases where it is desirable that the output is easily read and
; modified by human beings (eg, for plaintext configuration files).
;
; ## Symbols
; Serializing symbols seems error-prone because symbols are typically meant for
; evaluation. Additionally, symbols are used as the magic marker at the start of a
; serialized object, and expempting them from being otherwise serialized prevents any
; potential confusion between the two. Like EOF, the argument is weak and it can be
; implemented should the need arise.

(define-module (skyler serialization test)
	#:use-module (ice-9 binary-ports)
	#:use-module (ice-9 pretty-print)
	#:use-module (ice-9 textual-ports)
	#:use-module (oop goops)
	#:use-module (srfi srfi-1)
	#:use-module (srfi srfi-19)
	#:use-module (srfi srfi-26)
	#:use-module (srfi srfi-64)
	#:use-module (srfi srfi-69)
	#:use-module (skyler standard)
	#:use-module (skyler test util)

	#:use-module (skyler serialization)

	#:export (
		make-serialization-test
		; Signature: (make-serialization-test name datum key: (print display))
		;
		; Arguments:
		; name: A string containing a human-readable name decribing the test.
		;
		; datum: The piece of data that should be (de-)serialized.
		;
		; print: The function responsible for printing the data when reporting errors.
		;
		; Returns:
		; An srfi-64 test which serializes the datum, de-serializes it, and checks that the
		; result is `equal?` to the original datum.
))

(define* (make-serialization-test name datum key: (print display) (cmp equal?))
	(make-test name
		(define serialized-datum (call-with-output-string (lambda (port)
		                                                 	(write (serialize datum) port))))

		(format ((log-port)) "Serialized form: ~s~%" serialized-datum)

		(define deserialized-datum (call-with-input-string serialized-datum
		                                                  (lambda (port)
		                                                  	(deserialize (read port)))))

		(test-assert (print-data-on-fail print cmp datum deserialized-datum))))

; # Data
; Serialization should succeed for every primitive type, that is the types described in
; section 3.2 of the r7rs spec, with some exceptions explained inline.
;
; Additionally, there are guile-specific contstructs which we need to test. Keywords are
; used extensively in guile, but require SRFI-88 in standard lisp. Additionally,
; user-defined GOOPS classes should be serializable so long as they follow the conventions
; described in (skyler class-conventions).
(define-class <simple-class> ()
	(slot-containing-boolean init-keyword: #:slot-containing-boolean init-form: #t)
	(slot-containing-number  init-keyword: #:slot-containing-number  init-form: 616))

(define-method (display (obj <simple-class>) port)
	(format port "(<simple-class> (bool: ~s) (number: ~s))"
	        (slot-ref obj 'slot-containing-boolean)
	        (slot-ref obj 'slot-containing-number)))

(define-method (equal? (lhs <simple-class>) (rhs <simple-class>))
	(and (equal? (slot-ref lhs 'slot-containing-boolean)
	             (slot-ref rhs 'slot-containing-boolean))
	     (equal? (slot-ref lhs 'slot-containing-number)
	             (slot-ref rhs 'slot-containing-number))))

(define-class <complex-class> ()
	(slot-containing-user-defined-class init-keyword: #:slot-containing-user-defined-class
	                                    init-form:    (make <simple-class>)))

(define-method (display (obj <complex-class>) port)
	(format port "(<simple-class> (user-defined-class: ~s))"
	        (slot-ref obj 'slot-containing-user-defined-class)))

(define-method (equal? (lhs <complex-class>) (rhs <complex-class>))
	(equal? (slot-ref lhs 'slot-containing-user-defined-class) 
	        (slot-ref lhs 'slot-containing-user-defined-class)))

(define primitives `(
	("Boolean True"      . #t)
	("Boolean False"     . #f)
	("Bytevectors"       . #vu8(18 15 12 10))
	("Character Letter"  . #\a)
	("Character Special" . #\escape)
	("Character Multi"   . #\x262E)
	; EOF N/A            - writing the EOF object doesn't make sense
	("Null"              . ())
	("Number"            . 42)
	("Pair"              . (#t . #\a))
	; Port N/A           - depends on runtime state
	; Procedure N/A      - too complicated & dangerous, these aren't G-Expressions!
	("String"            . "Coffee. Now.")
	("Symbol"            . this-is-a-symbol!-who-would-have-guessed?)
	("Vector"            . #(#t #\a))

	("Keyword"           . #:lockword)
	("Simple Class"      . ,(make <simple-class>))
	("Complex Class"     . ,(make <complex-class>))))

(define (make-primitive-serialization-test pair)
	(let ((name (car pair))
				(data (cdr pair)))
		(make-serialization-test name data)))

(define all-tests (map make-primitive-serialization-test primitives))
