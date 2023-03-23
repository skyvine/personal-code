(define-library (skyler r7rs standard)

(import
	(scheme base)
	(scheme write)
	(srfi 1)
)

(export
	; from srfi-1
	drop
	drop-right
	fold
	fold-right
	last
	reduce
	reduce-right
	take
	take-right

	first
	second
	third
	fourth
	fifth
	sixth
	seventh
	eight
	ninth
	tenth

	; from this module
	flatten
	rest
)

(begin

(define rest cdr)

(define (flatten lst)
	(define (flatten-impl lst result)
		(cond
			((null? lst) result)
			((list? (first lst))
				(flatten-impl (rest lst) (flatten-impl (first lst) result)))
			(#t (flatten-impl (rest lst) (cons (first lst) result)))))
	(reverse (flatten-impl lst '())))

))
