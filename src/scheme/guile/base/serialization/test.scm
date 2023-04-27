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

	#:export (make-serialization-test))

(define* (make-serialization-test name datum key: (print display))
	(make-test name
		(define serialized-datum (call-with-output-string (lambda (port)
		                                                 	(write (serialize datum) port))))

		(define deserialized-datum (call-with-input-string serialized-datum
		                                                  (lambda (port)
		                                                  	(deserialize (read port)))))

		(test-assert (print-data-on-fail print equal? datum deserialized-datum))))

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
	; Symbol N/A         - these are typically meant to be evaluated, not stand-alone objects
	("Vector"            . #(#t #\a))

	("Keyword"           . #:lockword)
	("Simple Class"      . ,(make <simple-class>))
	("Complex Class"     . ,(make <complex-class>))))

(define (make-primitive-serialization-test pair)
	(let ((name (car pair))
				(data (cdr pair)))
		(make-serialization-test name data)))

(define all-tests (map make-primitive-serialization-test primitives))
