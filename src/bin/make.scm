#!/bin/guile \
-e main -s
!#

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
