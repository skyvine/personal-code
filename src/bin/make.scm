#!/bin/guile \
-e main -s
!#

(use-modules (guix build utils) (skyler standard))

(define (no-args-error)
	(format #t "ERROR: Must give at least 1 argument, the output name.~%")
	(exit))

(define (out-file-not-symlink-error)
	(format #t "ERROR: Output file already exists, but is not a symlink.~%")
	(exit))

(define (out-file-not-pointing-to-store-error)
	(format #t "ERROR: Output file is a symlink, but does not point to the store.~%")
	(exit))

(define (maybe-remove-out-file output-name)
	(when (access? output-name R_OK)
		(let ((out-stat (lstat output-name)))
			(if (eq? (stat:type out-stat) 'symlink)
				(if (string-prefix? "/gnu/store" (readlink output-name))
					(delete-file output-name)
					(out-file-not-pointing-to-store-error))
				(out-file-not-symlink-error)))))

(define (build output-name passthrough-args)
	(maybe-remove-out-file output-name)
	(apply invoke "guix" "build"
	              "--file=make.scm"
	              (string-append "--root=" output-name)
	              passthrough-args))

(define-public (main args)
	(let ((args (rest args)))
		(if (nil? args)
			(no-args-error)
			(build (first args) (rest args)))))
