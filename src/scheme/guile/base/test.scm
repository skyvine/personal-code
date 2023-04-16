(define-module (skyler test)
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

	#:export (main <simple-class> <complex-class>))

; # Data
; Serialization should succeed for every primitive type, that is the types described in
; section 3.2 of the r7rs spec, with some exceptions explained inline.
;
; Additionally, there are guile-specific contstructs which we need to test. Keywords are
; used extensively in guile, but conspicuously absent from r7rs. Additionally,
; user-defined GOOPS classes should be serializable so long as they follow the conventions
; described in (skyler class-conventions).
(define-class <simple-class> ()
	(slot-containing-boolean #:init-keyword #:slot-containing-boolean #:init-form #t)
	(slot-containing-number  #:init-keyword #:slot-containing-number  #:init-form 616))

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
	(slot-containing-user-defined-class #:init-keyword #:slot-containing-user-defined-class
	                                    #:init-form (make <simple-class>)))

(define-method (display (obj <complex-class>) port)
	(format port "(<simple-class> (user-defined-class: ~s))"
	        (slot-ref obj 'slot-containing-user-defined-class)))

(define-method (equal? (lhs <complex-class>) (rhs <complex-class>))
	(equal? (slot-ref lhs 'slot-containing-user-defined-class) 
	        (slot-ref lhs 'slot-containing-user-defined-class)))

(define example-data `(
	("Booleans"     . (#f #t))
	("Bytevectors"  . #vu8(18 15 12 10))
	;("Characters"  . '(#\a #\escape #\x262E))
	; EOF N/A       - writing the EOF object doesn't make sense
	("Null"         . ())
	("Number"       . 42)
	("Pair"         . (#t . #\a))
	; Port N/A      - depends on runtime state
	; Procedure N/A - too complicated & dangerous, these aren't G-Expressions!
	("String"       . "Coffee. Now.")
	; Symbol N/A    - these are typically meant to be evaluated, not stand-alone objects
	("Vector"       . #(#t #\a))

	("Keyword"       . #:lockword)
	("Simple Class"  . ,(make <simple-class>))
	("Complex Class" . ,(make <complex-class>))))

(define (test-example-datum name datum)
	(define serialized-data (call-with-output-string (lambda (port)
	                                                 	(write (serialize datum) port))))

	(format ((log-port)) "Serialized data: ~s~%" serialized-data)

	(define deserialized-data (call-with-input-string serialized-data
	                                                  (lambda (port)
	                                                  	(deserialize (read port)))))
		(test-assert (print-data-on-fail display equal? datum deserialized-data)))

(define (test-example-data pair)
	(lambda ()
		(let ((name (car pair))
					(data (cdr pair)))
			(run-test name (lambda ()
				(if (and (list? data)
				         (not (string=? "Null" name)))
					(map (cute test-example-datum name <>) data)
					(test-example-datum name data)))))))

(define (main)
	(let ((tests (map test-example-data example-data)))
		(unless (apply run-tests tests)
			(force-output)
			(exit -1))))
