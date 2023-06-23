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
; Miscellaneous utilities for building websites with Haunt

(read-set! keywords #f)

(define-module (skyler haunt utils)
	#:use-module ((guix build utils) #:prefix guix.)
	#:use-module ((haunt artifact)   #:prefix haunt.)
	#:use-module ((haunt post)       #:prefix haunt.)

	#:use-module (skyler standard)

	#:export (
		signature-directory
		; TODO

		signed-posts
		; TODO

		signature-file-filter
		; TODO
))

(define signature-directory (make-parameter "/signed-source"))

(define* (signed-source source-file-name)
	(guix.invoke "%%gnupg /bin/gpg%%" "--verify" (string-append source-file-name ".sig"))

	(list (haunt.verbatim-artifact source-file-name
	                               (string-append (signature-directory)
	                                              "/" source-file-name))
	      (haunt.verbatim-artifact (string-append source-file-name ".sig")
	                               (string-append (signature-directory)
	                                              "/" source-file-name ".sig"))))

(define* (signed-posts site posts)
	(flatten (map signed-source (map haunt.post-file-name posts))))

(define* (signed-source-footer file-name)
	`(p (i "Download the "
	       (a (@ (href ,(string-append (signature-directory) file-name))) "markdown source")
	       " and "
	       (a (@ (href ,(string-append (signature-directory) file-name ".sig")))
	          "signature."))))

(define (signature-file-filter file-name)
	(not (string-suffix? ".sig" file-name)))
