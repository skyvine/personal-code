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
	#:use-module ((haunt artifact)   #:prefix haunt.)
	#:use-module ((haunt post)       #:prefix haunt.)
	#:use-module ((haunt site)       #:prefix haunt.)

	#:use-module (skyler standard)

	#:export (
		signed-source
		; Signature: (signed-source source-file-name output-directory)
		;
		; Arguments:
		; source-file-name: The file name of the source which should be copied into the
		;                   signature-directory. for example, a call to Haunt's post-file-name
		;                   function, although that particular use-case is served by the
		;                   signed-posts builder. There must be a file with the same name and
		;                   a .sig extension added (not replaced).
		;
		; output-directory: The directory of the website where the files should be placed.
		;                   This is similar to the #:prefix argument of Haunt's blog
		;                   procedure.
		;
		; Return:
		; A list of 2 Haunt artifacts, representing a copy of the source and the sig file
		; inside the output-directory.

		signed-posts
		; A Haunt builder which will place a copy of the source for each post file as well as
		; its signature into a directory which mirrors the path of the the source file,
		; relative to the #:posts-directory argument of the site.

		signature-file-filter
		; A function that can be used in the #:file-filter argument to a Haunt site so that
		; Haunt does not try to process the signature files as posts.
))

(define* (signed-source source-file-name output-directory)
	(unless (eq? 0 (system* "%%gnupg /bin/gpg%%"
	                        "--verify" (string-append source-file-name ".sig")))
		(format #t "ERROR: ~A signature does not match" source-file-name)
		(exit -1))

	(let ((source-basename (basename source-file-name)))
		(list (haunt.verbatim-artifact source-file-name
		                               (string-append output-directory "/" source-basename))
		      (haunt.verbatim-artifact (string-append source-file-name ".sig")
		                               (string-append output-directory
		                                              "/" source-basename ".sig")))))

(define* (signed-posts site posts)
	(define (post->output-directory post)
		(let ((source-directory (dirname (haunt.post-file-name post)))
		      (post-directory   (haunt.site-posts-directory site)))
			(if (string-prefix? post-directory source-directory)
				(string-drop source-directory (string-length post-directory))
				source-directory)))

	(flatten (map (lambda (post)
	              	(signed-source (haunt.post-file-name post)
	              	               (post->output-directory post)))
	              posts)))

(define (signature-file-filter file-name)
	(not (string-suffix? ".sig" file-name)))
