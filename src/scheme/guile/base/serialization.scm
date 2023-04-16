; This serialization module leans into lisp's ambiguity between code and data. Broadly,
; it deals with 3 categories of data:
;
; 1. Self-evaluating data
; 2. GOOPS classes which follow a convention
; 3. Other types of data
;
; ## 1. Self-Evaluating Data
; Serializiation of self-evaluating data is straight-forward. #f is written as #f, a
; string is written as that string (with quotation marks), etc.
;
; ## 2. Conventional GOOPS Classes
; "Conventional" refers to the conventions described in the (skyler class-conventions)
; module.
;
; An instance of a conventional class is serialized as a list where the first element is
; the name of the class and the remaining elements are those that should be passed to
; `make` in order to construct an identical copy of the object. For example, an instance
; of a class representing a 2d point defined as:
;
; (define-class <point> ()
; 	(x #:init-keyword #:x #:accessor x)
; 	(y #:init-keyword #:y #:accessor y))
;
; Would be serialized as:
;
; (<point> #:x 4 #:y 2)
;
; The exhaustive description is that mandatory and optional slots are serialized by adding
; the appopriate keyword and the serialization of the slot's value to the list, while
; (DANGER) implicit slots are not serialized.
;
; ## 3. Other types of data
; Other types of data are more flexible in how they are serialized, but are still a list
; with a symbol specifying type as the first element. For example, the compatibility code
; for srfi-19 dates would produce a form with only two elements, where the second is the
; iso-8610-date/time+zone format:
;
; (<srfi-19-serialized-date> "1970-01-01T00:00:00Z")
;
; Note that the srfi-19 submodule of the serialization module must be loaded in order to
; serialize srfi-19 dates.
;
; For details on writing new (de)serialization code for other data types, look at the
; implementation documentation. Additionally, the srfi-19 submodule is a good example of
; how to write this code. As date serialization is a solved problem, this module is mostly
; just hooking the string/date conversion functions into the system, making it easy to
; focus on what the programmer needs to do for compatibility.

(define-module (skyler serialization)
	#:use-module (oop goops)
	#:use-module (rnrs bytevectors)
	#:use-module (skyler standard)
	#:use-module (srfi srfi-1)
	#:use-module (srfi srfi-26)

	#:export (
	serialize
	; Signature: (serialize data)
	;
	; Arguments:
	; data: the data to be serialized
	;
	; Return:
	; A value for which the following call chain will produce an identical copy of the data:
	;
	; (deserialize (read (write data)))
	;
	; Pretend that read and write are wrapped in call-with-input-string and
	; call-with-output-string =)

	deserialize
	; Siganature: (deserialize data)
	;
	; Arguments:
	; data: the data to be deserialized; this should have come from a previous serialize
	;       call, possibly read from a file
	;
	; Return:
	; A copy of the value that was previously passed into the serialize function

	%deserialize
	; Method taking variable arguments. This is part of the ABI, thus needs to be exported,
	; but is not part of the API. If you want to write a custom (de)serializer then you will
	; need to add an implementation of this method, see the implementation documentation for
	; details and the srfi-19 submodule for an example implementation.
))

(define (self-evaluating? obj)
	(or (boolean?    obj)
	    (bytevector? obj)
	    (char?       obj)
	    (keyword?    obj)
	    (null?       obj)
	    (number?     obj)
	    (string?     obj)
	    (vector?     obj)))

; # Serialization
; The implementation of serialization can be broken down into 3 cases: containers,
; self-evaluating data, and other instances.
;
; If the data is a container then serialize all of the contents. Only pairs and lists are
; implemented currenly, but there is nothing preventing the same strategy from being
; applied to, for example, vectors. Hash tables might be a little trickier.
;
; Otherwise, if the data is self-evaluating, return that and we're done.
;
; Otherwise, we get into the weeds. By default, the serialization method assumes that the
; data is an instance of a conventional class and follows the process described in the API
; documentation. Custom serializers can also be written by specializig on the data type.
;
; ## Writing a custom serializer
; A custom serializer is defined like this:
;
; ```scm
; (define-method (serialize (obj <data-type>))
; 	body)
; ```
;
; The value that is returned will be given to the %deserialize function which you also
; need to create. The following restrictions apply to the value:
;
; 1. It must be a list.
; 2. The first element of the list must be a symbol that evaluates to a class.
; 3. The rest of the list must be serialized data. Typically, this means self-evaluating
;    data like keywords, numbers, strings, etc, but it can also include instances which
;    have been serialized, as they will be recursively deserialized before your custom
;    deserializer is called.
(define* (serialize-slot slot-definition obj #:optional (port (current-output-port)))
	(let ((init-keyword (slot-definition-init-keyword slot-definition)))
		(if init-keyword
			(list init-keyword
			      (serialize (slot-ref obj (slot-definition-name slot-definition))))
			'())))

(define-method (serialize obj)
	(if (self-evaluating? obj)
		obj
		(let ((class (class-of obj)))
			(cons (class-name class)
			      (concatenate (map (lambda (slot-definition)
			                        	(serialize-slot slot-definition obj))
			                        (class-slots class)))))))

(define-method (serialize (obj <list>))
	(map serialize obj))

(define-method (serialize (obj <pair>))
	(cons (serialize (car obj)) (serialize (cdr obj))))

; # Deserialization
; The implementation of deserialization is a little more complicated. When we encounter a
; list with a symbol as the first element, we need to `eval` it in the context of the
; calling module in order to get the correct class (or blame the user if we don't get a
; valid class). Therefore, the user-facing `deserialize` is actually a macro which calls
; the underlying `%deserialize` with `(current-module)` passed in as an extra parameter.
;
; Below is a flow chart explaining the process. When a cutom deserializer is required, it
; will be called in the bottom-left box, "initialize instance with rest".
;                                                          ┌─────────────┐
;                                                          │             │
;                                                ┌─────────┤  Main Call  ├──────┐
;                                                │         │             │      │
;                                                │         └─────────────┘      │
;                                                │                              │
;                                                │                              │
;                                                │                              │
;                                     ┌──────────┴────────────┐          ┌──────┴────────┐
;                                ┌────┤        List           ├─────┐    │Self-evaluating│
;                                │    │Break into first & rest│     │    │   No Work     │
;                                │    └───────────────────────┘     │    └───────────────┘
;                                │                                  │
;                                │                                  │
;                                │                                  │
;                         ┌──────┴──────────┐           ┌───────────┴───────────┐
;                ┌────────┤ First is symbol ├──────┐    │First is not symbol    │
;                │        └─────────────────┘      │    │Recurse on first & rest│
;                │                                 │    └───────────────────────┘
;                │                                 │
; ┌──────────────┴──────────────┐    ┌─────────────┴───────────────────┐
; │  Symbol evaluates to class  │    │Symbol does not evaluate to class│
; │Initialize instance with rest│    │             Error!              │
; └─────────────────────────────┘    └─────────────────────────────────┘
;
; ## Writing a custom deserializer
; A custom deserializer is defined like this:
;
; ```scm
; (define-method (%deserialize (inst <data-type>) init-vals)
; 	body)
; ```
;
; The `inst` argument is an uninitialized instance of `<data-type>`, and the `init-vals`
; argument are the values that come from deserializing the values previously returned by
; the serialize function (in other words, if they are plain data like strings then they
; will be passed in as they appear, but if the serializer returned other serialized data
; types, then `init-vals` will contain the deserialized instances).
;
; There is technically no requirement that the `inst` argument be used, and no requirement
; on what is returned from this function. This makes the system flexible, as seen in the
; implementation of the srfi-19 serialization code.
(define-syntax deserialize
	(syntax-rules ()
		((_ data) (%deserialize data (current-module)))))

; ## Main Call
; The macro should always call this implementation. If the data is self-evaluating, then
; we can just return it. Otherwise, the data must be a list to be valid. There are 2 valid
; next methods to go to, depending on whether or not the first element is a symbol.
(define-method (%deserialize data (module <module>))
	(if (self-evaluating? data)
		data ; Self-evaluating (no work)
		(%deserialize (first data) (rest data) module))) ; List (break into first & rest)

; ## First is symbol
; If the first element is a symbol, eval it in the context of a calling module. Simply
; evaluating a symbol should not execute any dangerous code, although using the value that
; it evaluates to seems riskier. Therefore, abort unless we get a class.
(define-method (%deserialize (symbol <symbol>) init-vals (module <module>))
		(if (is-a? (eval symbol module) <class>)
			; Symbol evaluates to class
			(%deserialize (eval symbol module) init-vals module)
			; Symbol does not evaluate to class (Error!)
			(error "Symbol must evaluate to a class: " symbol)))

; ## Initialize instance with rest
; If we do get a class, allocate an instance of it and deserialize the remaining values.
; Pass this forward to whatever method is responsible for this class.
(define-method (%deserialize (class <class>) init-vals (module <module>))
	; The definition of allocate-instance in module/oop/goops takes in 2 arguments, the
	; second being initargs, but this is unused. Pass in #f just to keep the compiler happy.
	(%deserialize (allocate-instance class #f)
	              (map (cute %deserialize <> module) init-vals)))

; By default, just use the normal initialize procedure provided by (oop goops). This will
; work for conventional classes.
(define-method (%deserialize (inst <object>) init-vals)
	(initialize inst init-vals)
	inst)

; ## First is not symbol (recurse on first & rest)
; If the first element is not a symbol, then this must be a list of serialized data in
; order to be valid. Calling %deserialize on first and rest is mostly the same as if we
; had called `(map (cute %deserialize <> module) data)` in the initial call. Technically,
; these have different outcomes for a list like
; `(#:keywords-self-evaluate <srfi-19-serialized-date> "1970-01-01T00:00:00Z")`
; Calling map on this entire list would create an error on the second element, but calling
; %deserialize on the first and rest of the list results a cons cell with the keyword and
; the date. I don't think this edge case is a problem though, and might even be beneficial
; in some circumstances. Reasonable behavior is generally preferable to errors.
(define-method (%deserialize first rest (module <module>))
	(cons (%deserialize first module) (%deserialize rest module)))
