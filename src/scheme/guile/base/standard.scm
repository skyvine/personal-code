(define-module (skyler standard)
	#:use-module (ice-9 optargs)
	#:use-module (skyler r7rs standard)
)

(define (hash-table-keys ht)
	(hash-map->list (lambda (k v) k) ht))

(define (re-export-all module-name)
	(let ((interface (resolve-interface module-name)))
		(module-re-export! (current-module) (hash-table-keys (module-obarray interface)))))

(map re-export-all '((ice-9 optargs) (skyler r7rs standard)))
