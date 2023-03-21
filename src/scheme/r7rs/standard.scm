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
	rest
)

(begin

(define rest cdr)

))
