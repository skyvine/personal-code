; There are a few conventions that I follow when creating GOOPS classes. For the most
; part, these conventions are just programming patterns that do not require rigid
; formalization through code. However, there are some helper functions that are useful
; when working with classes that follow these conventions, and they are defined here. The
; API documentation explains the conventions in full, even when there are no relevant
; helper functions.
;
; A GOOPS class is essentially just a container where each element is a slot, so all of
; the conventions revolve around slot usage. There are 3 conventions: one about
; initialization, one about categorization, and one about extensible flexibility.
;
; # Initialization
; No instance shall have an unbound slot after initialization is complete.
;
; # Categorization
; Slots are divided into 3 categories based on whether the constructor must (mandatory),
; might (optional), or cannot (implicit) receive explicit values for them. The category of
; the slot is implicitly defined by slot options.
;
; A slot is mandatory if it has an #:init-keyword, and has NONE of an #:init-form,
; #:init-value, or #:init-thunk. The slot will be unbound unless a value is passed through
; the #:init-keyword, so it is mandatory.
;
; A slot is optional if it has an #:init-keyword, and has AT LEAST ONE of an #:init-form,
; #:init-value, or #:init-thunk. The slot will be bound even if no value is passed through
; the #:init-keyword, so it is optional.
;
; A slot is implicit if it does NOT have an #:init-keyword. Regardless of the other
; options, if there is no #:init-keyword then it is not possible to explicitly pass in a
; value, so it must be implicitly defined, even if that definition leaves it unbound.**
;
; # Extensible Flexibility
; Data structures exposed through the API shall have a core set of slots which define the
; information that is essential for core operation as well as the information which is
; commonly used by extensions. Additionally, each data structure will have a slot devoted
; to arbitrary data for extensions to utilize. The extension slot shall be called
; user-data, and it shall expose dictionary semantics.
;
; In Scott Meyers' 1993 paper titled
; "Representing Software Systems in Multiple-View Development Environments", he
; convincingly argues that a core data structure with a set of well-known data that are
; common to many operations facilitates collaboration between extensions, minimizing the
; chances of problems like inconsistent reporting. Having another slot dedicated to
; arbitrary data allows each extension to add additional information necessary for its
; operation to the data structure without interfering with other extensions. It is
; possible for extensions to collaborate in unforseen ways through this mechanism as well.
; The paper focuses on representing source code for IDE tools, but the analysis seems
; generally applicable.

(define-module (skyler class-conventions)
	#:use-module (oop goops)
	#:use-module (skyler standard)
	#:use-module (srfi srfi-1)
	#:use-module (srfi srfi-69)

	#:export (mandatory-slot?
	          ; Signature: (mandatory-slot? (slot <slot-definition>))
	          ;
	          ; Arguments:
	          ; slot: The slot definition which should be checked.
	          ;
	          ; Return:
	          ; A truthy value if the slot must be explicitly intialized by the user, #f
	          ; if it either may or must be implicitly initialized.

	          mandatory-slots
	          ; Signature: (mandatory-slots (class <class>))
	          ;
	          ; Arguments:
	          ; class: The class whose slots should be examined.
	          ;
	          ; Return:
	          ; A list containing all of the class' slots which are considered mandatory,
	          ; as defined by `mandatory-slot?` (it is not guaranteed that `mandatory-slot?`
	          ; will be called, but it is guaranteed that the semantics are the same as the
	          ; definition in this module).

	          optional-slot?
	          ; Signature: (optional-slot? (slot <slot-definition>))
	          ;
	          ; Arguments:
	          ; slot: The slot definition which should be checked.
	          ;
	          ; Return:
	          ; A truthy value if the slot may be either explicitly or implicitly
	          ; initialized by the user, #f if it must be explicit or must be implicit.

	          optional-slots
	          ; Signature: (mandatory-slots (class <class>))
	          ;
	          ; Arguments:
	          ; class: The class whose slots should be examined.
	          ;
	          ; Return:
	          ; A list containing all of the class' slots which are considered optional,
	          ; as defined by `optional-slot?` (it is not guaranteed that `optional-slot?`
	          ; will be called, but it is guaranteed that the semantics are the same as the
	          ; definition in this module).

	          ensure-all-slots-are-bound
	          ; Signature: (ensure-all-slots-are-bound
	          ;              instance
	          ;              key: (on-unbound unbound-throws-error))
	          ;
	          ; Arguments:
	          ; instance: The instance whose slots should be examined
	          ;
	          ; on-unbound: If any slots are unbound, then this callback will be called with
	          ;             a single argument, a list containing all of the slot definitions
	          ;             representing unbund slots in this instance. By default, it
	          ;             signals an error with a message pretty-printing the list of
	          ;             unbound slot names.
	          ;
	          ; Return:
	          ; Undefined. Typically, this is used in a specialization of the `initialize`
	          ; method to signal an error if a class has any unbound slots
	          ; post-initialization.

	          make-user-data-accessor
	          ; Signature: (make-user-data-accessor (slot <slot-definition>))
	          ;
	          ; Arguments:
	          ; slot: The definition of the slot which will contain the user data. It is an
	          ;       error if the slot does not have an #:init-thunk of make-hash-table, as
	          ;       defined in the srfi-69 module.
	          ;
	          ; Returns:
	          ; A procedure-with-setter appropriate for accessing user-data. The accessor
	          ; has the following signature:
	          ;
	          ; (<accessor-name> instance key optional: missing-handler)
	          ;
	          ; Arguments:
	          ; instance: the task instance associated with the relevant datum.
	          ;
	          ; key: a symbol which uniquely identified which datum to retrieve.
	          ;
	          ; missing-handler: If this is a read request and the key does not exist,
	          ;                  return the value of calling this function, passing in the
	          ;                  key as the only argument. The user-data stored in the
	          ;                  instance will NOT be updated. By default, the handler will
	          ;                  signal an error.
	          ;
	          ; Return:
	          ; The value of the datum associated with the key. This procedure is compatible
	          ; with the generealized `set!` syntax.

	          user-data-cmp?
	          ; Signature: (user-data-cmp? cmp (slot <slot-definition>) lhs rhs)
	          ;
	          ; Arguments:
	          ; cmp: A two-argument predicate that returns true if the given values should
	          ;      be considered equal. This procedure will be applied to both keys and
	          ;      values. Typically, it will be equal? eqv? or eq?
	          ;
	          ; slot: The slot responsible for storing user data
	          ;
	          ; lhs, rhs: the instances whose user data should be compared
	          ;
	          ; Return:
	          ; A truthy value if lhs and rhs have equivalent contents in their user data,
	          ; #f otherwise.
))

; Both `unbound?` and `has-default-value?` leak (oop goops) implementation details.

(define unbound? (@@ (oop goops) unbound?))

(define (has-default-value? slot)
	"Returns a truthy value if the slot has a default. Otherwise, returns false.

	The ordering in the or statement is based on the preference of init definitions
	described in section 8.4 (Slot Options) of the manual. I assume this is stable.

	Per `module/oop/goops.scm`, in the `fold-slot-slots` macro, thunks are #f if they are
	not specified, while forms and values are unbound if they are not specified. Note that
	the unbound value is truthy."

	(or (slot-definition-init-thunk slot)
	    (not (unbound? (slot-definition-init-form  slot)))
	    (not (unbound? (slot-definition-init-value slot)))))

(define (mandatory-slot? slot)
	"Returns the given slot if it must be used in initialization. Otherwise, returns false.

	The assumptions are that all slots should be bound once the initialization function
	returns and the initialization function is the default `initialize` method described in
	the manual. Based on these assumptions, a slot is mandatory if it lacks an init form,
	thunk, and value. Additionally, this method checks whether the slot has a keyword,
	because if there is no keyword then there is no way for us to initialize it anyway, so
	it cannot be \"mandatory\" because it cannot be supplied at all."

	(if (and (slot-definition-init-keyword slot) (not (has-default-value? slot)))
		slot
		#f))

(define (mandatory-slots class)
	(filter-map mandatory-slot? (class-slots class)))

(define (optional-slot? slot)
	"Returns the given slot if it is optional to provide. Otherwise, returns false.

	See the `mandatory-slot?` docstring for assumptions. A slot is optional if it has an
	init keyword - meaning it is *possible* to initialize it at all - and it is not
	mandatory."

	(if (and (slot-definition-init-keyword slot) (has-default-value? slot))
		slot
		#f))

(define (optional-slots class)
	(filter-map optional-slot? (class-slots class)))

(define (unbound-throws-error unbound-slots)
	(define (slot->indented-name slot)
		(format #f "  ~a~%" (slot-definition-name slot)))

	(error (reduce-right string-append #f (cons (format #f "Unbound slots:~%")
	                                            (map slot->indented-name unbound-slots)))))

(define* (ensure-all-slots-are-bound instance key: (on-unbound unbound-throws-error))
	(define (slot-unbound? slot)
		(if (slot-bound? instance (slot-definition-name slot))
			#f
			slot))

	(let ((unbound-slots (filter-map slot-unbound? (class-slots (class-of instance)))))
		(when (> (length unbound-slots) 0)
			(on-unbound unbound-slots))))

(define (make-user-data-accessor slot)
	(unless (eq? make-hash-table (slot-definition-init-thunk slot))
		(error (format #f (string-append "Slot ~a does not use an init-thunk of "
		                                 "make-hash-table, as defined by srfi-69")
		               (slot-definition-name slot))))

	(define name (slot-definition-name slot))

	(define (ref instance)
		(slot-ref instance name))

	(define (missing-key-is-error key)
		(error (format #f "Key ~s not found in user data." key)))

	(define* (get instance key optional: (missing-handler missing-key-is-error))
		(hash-table-ref (ref instance) key (lambda () (missing-handler key))))

	(define (set instance key new-value)
		(hash-table-set! (ref instance) key new-value))

	(make-procedure-with-setter get set))

(define (user-data-cmp? cmp slot lhs rhs)
	(lset= cmp (hash-table->alist (slot-ref lhs (slot-definition-name slot)))
	           (hash-table->alist (slot-ref rhs (slot-definition-name slot)))))
