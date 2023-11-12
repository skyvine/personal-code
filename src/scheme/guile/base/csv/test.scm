(define-module (skyler csv test)
	#:use-module (ice-9 pretty-print)
	#:use-module (skyler csv)
	#:use-module (skyler standard)
	#:use-module (skyler test util)
	#:use-module (srfi srfi-26)
	#:use-module (srfi srfi-64))

(define (data-map proc tree)
	(map (cut map proc <>) tree))

(define (test-representation string-representation expected)
	(format #t "String representation: ~s~%" string-representation)
	(test-assert (print-data-on-fail pretty-print equal?
	                                 (csv->rows string-representation)
	                                 expected)))

(define* (csv-test rows)
	(parameterize ((current-output-port ((log-port)))
	               (current-error-port  ((log-port)))
	               (trace-parse-port    ((log-port))))
		(test-begin "Bare")
		(test-representation (rows->csv rows) rows)
		(test-end)

		(test-begin "Quoted")
		(let ((quoted-rows (data-map (cut string-append "\"" <> "\"") rows)))
			(pretty-print quoted-rows)
			(test-representation (rows->csv quoted-rows) rows))
		(test-end)

		(test-begin "Missing final newline")
		(test-representation (string-drop-right (rows->csv rows) 1) rows)
		(test-end)
))

(define-test parse-non-empty-bare-entries "Non-empty entries"
	(csv-test
		'(("one"  "two" "three"  "four")
		  ("five" "six" "seven"  "eight")
		  ("nine" "ten" "eleven" "twelve"))))

(define-test single-line "Single line"
	(csv-test '(("one"  "two" "three"  "four"))))

(define-test first-entry-is-empty "First entry is empty"
	(csv-test '((""  "two"  "three" "four")
	            (""  "six"  "seven" "eight")
	            (""  "nine" "ten"   "eleven"))))

(define-test middle-entry-is-empty "Middle entry is empty"
	(csv-test '(("one"  ""    "three" "four")
							("five" "six" ""      "eight")
							("nine" ""    ""      "twelve"))))

(define-test last-entry-is-empty "Last entry is empty"
	(csv-test '(("one"  "two" "three"  "")
	            ("five" "six" "seven"  "")
	            ("nine" "ten" "eleven" ""))))

(define-test one-entry-per-row "One entry per row"
	(csv-test '(("one")
	            ("two")
	            ("three"))))

(define-test data-with-commas "Data with commas"
	(parameterize ((current-output-port ((log-port)))
	               (current-error-port  ((log-port)))
	               (trace-parse-port    ((log-port))))
		(test-representation "\"o,n,e\",\",two\",\"three,\"\n"
		                     '(("o,n,e" ",two" "three,")))))

(define all-tests (list
	parse-non-empty-bare-entries
	single-line
	first-entry-is-empty
	middle-entry-is-empty
	last-entry-is-empty
	one-entry-per-row
	data-with-commas))
