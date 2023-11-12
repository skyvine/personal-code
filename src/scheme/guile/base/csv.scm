(define-module (skyler csv)
	#:use-module (ice-9 optargs)
	#:use-module (ice-9 peg)
	#:use-module (ice-9 pretty-print)
	#:use-module (skyler standard)
	#:use-module (srfi srfi-1)
	#:use-module (srfi srfi-26)

	#:export (
		csv->rows
		; Signature: (csv->rows csv)
		;
		; Arguments:
		; csv: A string containing csv data. If any value starts with a double-quote then it
		;      may contain both commas and newlines.
		;
		; Returns:
		; A list of lists, where each inner list contains the extracted value. For example:
		;
		; (csv->rows "one,two,three\nfour,five,six\n")
		;
		; Results in:
		;
		; '(("one"  "two"  "three")
		;   ("four" "five" "six"))

		rows->csv
		; Signature: (rows-csv rows)
		;
		; Arguments:
		; rows: A list of lists, where each of the inner lists contain strings representing
		;       the data to be formatted as csv text.
		;
		; Returns:
		; A string containing the input formatted as csv text. For example:
		;
		; (rows->csv '(("one"  "two"  "three")
		;              ("four" "five" "six"))
		;
		; Results in:
		;
		; "one,two,three\nfour,five,six\n"

		trace-parse-port
		; When true, this parameter contains a port which will print a trace of the steps
		; taken while parsing the CSV file, to aid in debugging. Note that this only traces
		; the custom code that processes the PEG parser output, not the PEG parser itself
		; (see implementation documentation).
))

; # Implementation Notes
; The bulk of the work is done by a PEG parser defined in the beginning of this file. The
; results of the tree are converted into formats which are more usable for this purpose
; by some internal converters. These are used to build the API itself, described above.

; # Tracing Code
; This is like pretty-print, but returns the result as a string instead of writing it
; externally, like `(format #f ...)`.
(define (pretty-format obj . args)
	(call-with-output-string (lambda (port)
		(apply pretty-print obj port args))))

(define (trace-parse . format-args)
	(when (trace-parse-port)
		(apply format (trace-parse-port) format-args)))

; # PEG Parser
; ## File Structure
; A csv file is a series of rows. The comma delimination is parsed within the row
; pattern so that it is easier to handle empty fields at the beginning or end of a row.
; The eof is also considered so that data which is technically malformed by missing a
; trailing newline will still parse as expected (more likely when literals are used or
; strings are computed in-memory, rather than read from a file). Without this, the parser
; would report a success but omit the final "line" of data.
(define-peg-pattern csv body  (+ row))
(define-peg-pattern row all   (and (* (and data comma))
                                           data
                                           (or nl eof)))

; ## Row Structure
; The bare data parser needs to be aware of the comma or newline in order to know when to
; stop parsing, but does not consume it to handle the edge cases mentioned above. It does
; not need to handle the EOF because the parser will naturally stop there, as there is no
; data (there will not be some eof object included in the parse results).
(define-peg-pattern data        all   (or quoted-data bare-data))
(define-peg-pattern bare-data   body  (* (and (not-followed-by (or comma nl)) peg-any)))
(define-peg-pattern quoted-data body  (and quotation-mark
                                             (* (and (not-followed-by quotation-mark)
                                                     peg-any))
                                             quotation-mark))

; ## Literals
(define-peg-pattern comma          none ",")
(define-peg-pattern nl             none "\n")
(define-peg-pattern quotation-mark none "\"")
(define-peg-pattern eof            none (not-followed-by peg-any))

; # Internal Converters
; The PEG parser produces a tree that looks like this:
;
; Input:
; ```
; one,   two,   three
; four,  ,      six
; seven
; ```
;
; Output:
; ```
; ((row ((data "one") (data "two")) (data "three"))
;  (row ((data "four") data) (data "six"))
;  (row (data "seven")))
; ```
;
; Three things are notable about this output:
;
; 1. Empty fields produce the symbol 'data, while fields with content produce a list,
;    the first element being the symbol 'data and the second element being the text.
; 2. Rows with more than 1 field produce a three-element list, of the form
;    ('row (leading-data-elements) final-data-element).
; 3. Rows with exactly 1 field produce a two-element list, of the form
;    ('row sole-data-element)).
;
; The heterogeneity of the data types is because the PEG code maximizes lossless
; compression, which is good when dealing with large data sets. However, it does add some
; complexity when processing the data due to differing data types.
;
; The separation of data into a list containing most elements and then a standalone datum
; as a separate element is because I wrote the row parser to consider the final field of
; data a separate parse element from the leading data, in order to clarify to the parser
; that the final element will not have a trailing comma (so a comma followed by a newline
; produces an empty element, rather than omitting the information all together).
;
; The field->content and tree-row->plain-row helpers retrieve the relevant data based on
; the variant we are working with.

(define (field->content field)
	(define result
		(cond
			((symbol? field) "")
			((list?   field) (second field))
			(else (format (current-error-port) "Unrecognized field format: ~s~%" data) data)))

	(trace-parse "Transformed field:~%~a~%~%Into content:~%~a~%~%"
	             (pretty-format field  per-line-prefix: "  ")
	             (pretty-format result per-line-prefix: "  "))
	result)

(define (tree-row->plain-row row)
	(define result
		(if (= (length row) 3)
			`(,@(map field->content (second row))
			  ,(field->content (third row)))
			(list (field->content (second row)))))

	(trace-parse "Transformed tree row:~%~a~%~%Into plain row:~%~a~%~%"
	             (pretty-format row    per-line-prefix: "  ")
	             (pretty-format result per-line-prefix: "  "))
	result)

(define (csv->tree text)
	(define result (keyword-flatten '(row) (peg:tree (match-pattern csv text))))

	(trace-parse "PEG parser produced tree:~%~a~%"
	             (pretty-format result per-line-prefix: "  "))

	result)

(define (tree->rows tree)
	(define result (map tree-row->plain-row tree))

	(trace-parse "Transformed tree:~%~a~%~%Into rows:~%~a~%~%"
	             (pretty-format tree   per-line-prefix: "  ")
	             (pretty-format result per-line-prefix: "  "))
	result)

; # API
(define trace-parse-port (make-parameter #f))

(define csv->rows (compose tree->rows csv->tree))

(define (rows->csv rows)
	(define (row->csv row)
		(apply string-append (interweave "," row)))
	(apply string-append (map (cut string-append <> "\n")  (map row->csv rows))))
