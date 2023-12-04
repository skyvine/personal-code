(define-module (bin view-log)
	#:use-module (ice-9 getopt-long)
	#:use-module (ice-9 rdelim)
	#:use-module (srfi srfi-1)
	#:use-module (srfi srfi-26)
	#:use-module (term ansi-color)

	#:export (main))

; alist of log level symbol to (term ansi-color) symbols
(define default-log-colors '((TRACE   MAGENTA)
                             (DEBUG   GREEN)
                             (INFO    CYAN)
                             (WARNING YELLOW)
                             (ERROR   RED)
                             (FATAL   RED BOLD UNDERLINE)))

(define valid-color?
	(let ((colors (hash-map->list (lambda (key value) key)
	                              (@@ (term ansi-color) ansi-color-tables))))
		(lambda (color)
			(member color colors))))

(define (log-level->option-name level)
	(string->symbol (string-append (string-downcase (symbol->string level)) "-color")))

(define (user-argument->colors argument)
	(map string->symbol (string-split argument #\,)))

(define (log-color->option-spec-entry log-color)
	(list (log-level->option-name log-color)
	      '(value #t)
	      `(predicate ,(lambda (arg)
	                    	(let ((invalid-colors (filter (negate valid-color?)
	                    	                              (user-argument->colors arg))))
	                    		(if (= (length invalid-colors) 0)
	                    			#t
	                    			(begin
	                    				(format #t "These are not valid colors: ~s~%" invalid-colors)
	                    				#f)))))))

(define option-spec (map (compose log-color->option-spec-entry car) default-log-colors))

(define (parse-log-colors options)
	(define (decide-on-colors level)
		(let ((user-colors (option-ref options (log-level->option-name level) #f)))
			(cons level
			      (if user-colors
			      	(user-argument->colors user-colors)
			      	(assq-ref default-log-colors level)))))

	(map (compose decide-on-colors car) default-log-colors))

(define (colorize-line line colors)
  (define words (string-split line #\space))
  (define presumed-level-word (third words))

  (define word->level
    (let ((str-levels (map (compose symbol->string car) default-log-colors)))
      (lambda (word)
        (let ((level (find (cute string-contains word <>) str-levels)))
          (if level (string->symbol level) #f)))))

  (define level
    (let ((presumed-level (word->level presumed-level-word)))
      (if presumed-level
        presumed-level
        (let ((maybe-level (find word->level words)))
          (if maybe-level (word->level maybe-level) #f)))))

  (if level
    (apply colorize-string line (assq-ref colors level))
    line))

(define* (colorize-all-lines port colors #:optional (result '()))
	(let ((next-line (read-line port)))
		(if (eof-object? next-line)
			(reverse result)
			(colorize-all-lines port colors (cons (colorize-line next-line colors) result)))))

(define (main args)
	(let* ((options    (getopt-long args option-spec))
	       (arguments  (option-ref options '() '()))
	       (log-colors (parse-log-colors options)))
		(call-with-input-file (first args)
			(lambda (port)
				(map (lambda (line)
				     	(display line)
				     	(newline))
				     (colorize-all-lines port log-colors))))))
