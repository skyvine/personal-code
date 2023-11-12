; Copyright 2023 Skyler Ferris
;
; This program is free software: you can redsitribute it and/or modify it under the terms
; of the GNU Affero General Public License as published by the Free Software Foundation,
; either version 3 of the License or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful, but WITHOUT ANY
; WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
; PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
;
; You should have received a copy of the GNU Affero General Public License along with this
; program. If not, see <https://www.gnu.org/licenses>.

; # Documentation
; Miscellaneous utilities useful for defining tests.

(define-library (skyler r7rs test util)

(import
	(scheme base)
	(scheme write)
	(srfi 1)
	(srfi 64)
)

(export
	define-test
	; Macro Signature: (define-test code-name human-name exp exp* ...)
	;
	; Creates a test and binds the result to the symbol provided in the `code-name`
	; argument. The return value is undefined. See the `make-test` documentation for
	; additional details.
	;
	; This is comparable to the built-in (define (lambda-name name) exp exp* ...) for making
	; a lambda and binding the result to a symbol.

	make-test
	; Macro Signature: (make-test human-name exp exp* ...)
	;
	; Arguments:
	; human-name: A human-readable string naming the test.
	;
	; exp exp* ...: The code that runs the test. This is comparable to the built-in
	;               (lambda (args) exp exp* ...) for making a callable object, but with some
	;               additional constraints and feature described below.
	;
	; Returns:
	; A thunk which runs the given code as an srfi-64 test. In particular, it handles
	; calling `test-begin` and `test-end`, and handles any exception that the code might
	; throw to make sure the information is logged and the test suite runs to completion.
	; The thunk will return true if the test passes, false otherwise. The logic assumes
	; that the test runner is the default runner supplied by Guile.

	run-tests
	; Signature: (run-tests tests)
	;
	; Arguments:
	; tests: A list of tests, as created by make-test
	;
	; Returns:
	; True if all of the tests pass, false otherwise. All tests will run to completion (if
	; possible) even if some tests fail.

	log-port
	; Signature: (log-port)
	;
	; Returns:
	; The port that the srfi-64 test suite is currently using to log test results. This
	; logic assumes that the test runner is the default runner supplied by Guile.

	print-data-on-fail
	; Signature: (print-data-on-fail print cmp lhs rhs)
	;
	; Arguments:
	; print: A 2-argument function used to print the data in the event that the comparison
	;        fails. The first argument is the datum (lhs or rhs) and the second argument is
	;        theport to write to. The standard `write` is a fine option in many cases.
	;
	; cmp: A 2-argument predicate used to test whether lhs and rhs are equal. If this
	;      returns false, the function will consider this a failure state and print the
	;      data.
	;
	; lhs, rhs: The data being compared
	;
	; Returns:
	; #t if (cmp lhs rhs) returns a truthy value, #f otherwise.
)

(begin

(define log-port
	; This parameter contains a thunk that will return an output port to use for logging.
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

(define (print-exception exception port)
	(display "Exception: " port) (write exception port) (newline port))

(define-syntax make-test
	(syntax-rules ()
		((_ human-name exp exp* ...)
			(lambda ()
				(test-begin human-name)
				(with-exception-handler
					(lambda (exception)
						(print-exception exception ((log-port)))
						(print-exception exception (current-output-port))
						(test-assert #f)
						#f)
					(lambda () exp exp* ...))
				(let ((result (tests-succeeded? (test-runner-get))))
					(test-end human-name)
					result)))))

(define-syntax define-test
	(syntax-rules ()
		((_ code-name human-name exp exp* ...)
			(define code-name (make-test human-name exp exp* ...)))))

(define (run-tests tests)
	"Run all of the tests. Return false if any of them fail, otherwise return true.

	This method is designed to avoid short-circuiting so that all of the test results are
	reported."

	(fold (lambda (lhs rhs) (and lhs rhs)) #t
	      (map (lambda (f) (f)) tests)))

(define (print-data-on-fail print comp lhs rhs)
	(if (comp lhs rhs)
		#t
		(begin
			(display "Left: " ((log-port))) (newline ((log-port)))
			(print lhs ((log-port))) (newline ((log-port)))
			(display "Right:" ((log-port))) (newline ((log-port)))
			(print rhs ((log-port))) (newline ((log-port)))
			#f)))


))
