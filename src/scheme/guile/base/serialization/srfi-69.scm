(define-module (skyler serialization srfi-69)
	#:use-module (oop goops)
	#:use-module (skyler standard)
	#:use-module (srfi srfi-69)

	#:use-module (skyler serialization)

	#:export (<srfi-69-hashtable>
	         ; This evaluates to the class of objects returned by make-hash-table, when
	         ; srfi-69 is loaded (this is distinct from hash tables in the vanilla
	         ; environment).
))

(define <srfi-69-hashtable> (class-of (make-hash-table)))

(define-method (serialize (instance <srfi-69-hashtable>))
	(list '<srfi-69-hashtable> (hash-table->alist instance)))

(define-method (%deserialize (instance <srfi-69-hashtable>) initargs)
	; TODO: use the pre-allocated instance instead of just throwing it away
	(alist->hash-table (first initargs)))
