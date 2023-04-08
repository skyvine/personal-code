(define-library (skyler r7rs test util)

(import
	(scheme base)
	(srfi 1)
	(srfi 64)
)

(export
	define-test
	run-tests

	log-port
	print-data-on-fail
)

(begin

(define log-port
	; This paramater contains a thunk that will return an output port to use for logging.
	; Because this is a parameter which returns a thunk, you need to use 2 sets of
	; parentheses in order to actually get the port: `((log-port))`

	; The --keep-failed flag will leave log files in the root of the build directory
	; If the build is successful, the logs are saved under `test-logs` in the output
	; directory

	(make-parameter
	; Note: Leaking implementation detail of guile's default test runner
	; TODO: Add a test runner to this library that is designed with guix in mind
	(lambda () (test-runner-aux-value (test-runner-get)))))

(define (tests-succeeded? runner)
	(eq? 0 (+ (test-runner-fail-count  runner)
			      (test-runner-xpass-count runner)
			      (test-runner-xfail-count runner))))

(define-syntax define-test
	(syntax-rules ()
		((_ code-name human-name exp exp* ...)
		 (define (code-name)
		 	(test-begin human-name)
			exp exp* ...
			(let ((result (tests-succeeded? (test-runner-get))))
				(test-end)
				result)))))

(define run-tests (lambda tests
	"
	Run all of the tests. Return false if any of them fail, otherwise return true.

	This method is designed to avoid short-circuiting so that all of the tests actually run.
	Passing and to fold directly doesn't work, because and is a macro not a function. Which
	makes sense when you consider the concept of short-circuiting. =)
	"

	(fold (lambda (lhs rhs) (and lhs rhs)) #t
	      (map (lambda (f) (f)) tests))))

(define (print-data-on-fail print comp lhs rhs)
	(if (comp lhs rhs)
		#t
		(begin
			(print "Left:  " ((log-port))) (print lhs ((log-port))) (newline ((log-port)))
			(print "Right: " ((log-port))) (print rhs ((log-port))) (newline ((log-port)))
			#f)))


))
