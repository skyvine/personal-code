(define-module (skyler test util)
	#:use-module (ice-9 pretty-print)
	#:use-module (oop goops)
	#:use-module (skyler class-conventions)
	#:use-module (skyler r7rs test util)
	#:use-module (skyler standard)
	#:use-module (srfi srfi-26)
	#:use-module (srfi srfi-69)

	#:export (example-instances print-all-fields))

(re-export-all '(skyler r7rs test util))

(define (slot->test-args default-value-spec slot)
	"Return a 2-element list appropriate for inclusion in the arglist of make.

	In particular, the first element of the list is the relevant keyword, and the second
	element is the appropriate value. The value is taken from the default-value-spec
	argument.

	# Arguments
	default-value-spec: A hashtable with symbols as keys and any kind of value as elements.
	                    The table must contain an entry whose key is the slot name.

	slot: The slot definition which should be initialized by the return value."

	(list (slot-definition-init-keyword slot)
	      (hash-table-ref default-value-spec (slot-definition-name slot) (lambda ()
	      	(error (format #f "No default value for slot: ~s~%"
	      	                  (slot-definition-name slot)))))))

(define (example-instances class default-value-spec)
	"Generate a list of instances which have every combination of optional slots being
	explicitly or implicitly defined.

	# Arguments
	class: The instances will be of this type.

	default-value-spec: A hashtable with symbols as keys and any kind of value as elements.
	                    The table must contain an entry whose key is the slot name.

	# User Story
	Let's say you have a class for storing cross-stitch patterns. The class might be defined
	like this:

	```scm
	(define-class <cross-stitch-pattern> ()
		(name        init-keyword: #:name)
		(size        init-keyword: #:size)
		(description init-keyword: #:description init-form: \"\")
		(quality     init-keyword: #:quality     init-form: #f))
	```

	All patterns must have a name and a size, but description and quality might be default
	initialized. You want to make sure that your code works whether the optional values have
	default data or realistic user data. This is particularly relevant for quality, as the
	default value is a boolean but a user-supplied value would be an integer.

	This function allows you to easily generate a list of instances which represent all
	possible combinations of the optional slots being initialized or not. So if you have a
	function `run-test-suite` which takes in an instance and tests it, you could do this:

	```scm
	(map run-test-suite (example-instances <cross-stitch-pattern> (alist->hash-table
		`((name        . \"The name of a pattern\")
			(size        . ,(cons 50 100))
			(description . \"A string with non-zero length\")
			(quality     . 11)))))
	```

	The test suite will then run against a list of instances which have been initialized
	with the following cases. Note that order is undefined by the API, and the optionality
	of slots are determined automatically through the class-conventions module.

	- Only name and size are given to the constructor. Description and quality are
	  default-initialized.
	- Name, size, and description are given to the constructor. Quality is
	  default-initialized.
	- Name, size, and quality are given to the constructor. Description is
	  default-initialized.
	- Name, size, description, and quality are given to the consructor. Nothing is
	  default-initialized."

	(let ((mandatory-args (apply append (map (cute slot->test-args default-value-spec <>)
	                                    (mandatory-slots class))))
	      (optional-args (append (map (cute slot->test-args default-value-spec <>)
	                                 (optional-slots class)))))
		(map (lambda (slot-combination)
		     	(apply make class (append (apply append slot-combination) mandatory-args)))
		     (n-ary-combinations optional-args))))

(define* (print-all-fields obj port optional: (oneline? #f))
	"Pretty-print an object by printing the class name, then the each of the fields."
	(if (string? obj)
		(display obj port)
		(begin
			(format port "~s:" (class-name (class-of obj)))
			(unless oneline? (newline port))
			(map
				(lambda (slot)
					(format port "  ~s: ~s" (slot-definition-name slot)
					                           (slot-ref obj (slot-definition-name slot)))
					(unless oneline? (newline port)))
				(class-slots (class-of obj))))))
