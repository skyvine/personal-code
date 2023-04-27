(define-library (skyler r7rs test)

(import
	(scheme base)
	(scheme process-context)
	(scheme write)
	(skyler r7rs standard)
	(skyler r7rs test util)
	(srfi 1)
	(srfi 26)
	(srfi 64)
)

(export main)

(begin

(define example-n-ary-lists
	; (input     . expected-output)
	'((()        . (()))
	  ((1)       . ((1) ()))
	  ((1 2)     . ((1 2) (2) (1) ()))
	  ((1 2 3)   . ((1 2 3) (1 2) (1 3) (2 3) (1) (2) (3) ()))
	  ((1 2 3 4) . ((1 2 3 4)
	                (1 2 3)
	                (1 2 4)
	                (1 2)
	                (1 3 4)
	                (1 3)
	                (1 4)
	                (1)

	                (2 3 4)
	                (2 3)
	                (2 4)
	                (2)

	                (3 4)
	                (3)

	                (4)

	                ()))))

(define-test n-ary-lists "n-ary-combinations"
	(define (test-list data)
		(test-assert (print-data-on-fail write (cut lset= (cut lset= eq? <> <>) <> <>)
		                                 (n-ary-combinations (car data)) (cdr data))))

	(map test-list example-n-ary-lists))

(define nested-lists
	'((1  2  3  4)
		(1 (2  3  4))
		(1  2 (3  4))
		(1  2  3 (4))
		(1 (2 (3  4)))
		(1 (2  3 (4)))
		(1  2 (3 (4)))
		(1 (2 (3 (4))))))

(define-test flattened-lists "flatten"
	(define (test-list data)
		(test-assert (print-data-on-fail write equal? (flatten data) '(1 2 3 4))))

	(map test-list nested-lists))

(define all-tests (list n-ary-lists flattened-lists))

))
