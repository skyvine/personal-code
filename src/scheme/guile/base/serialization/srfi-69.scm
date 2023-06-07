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

(define-module (skyler serialization srfi-69)
	#:use-module (oop goops)
	#:use-module (skyler standard)
	#:use-module (srfi srfi-69)

	#:use-module (skyler serialization)

	#:export (<srfi-69-hashtable>
	         ; This evaluates to the class of objects returned by make-hash-table, when
	         ; srfi-69 is loaded (this is distinct from hash tables in the vanilla
	         ; environment).
))

(define <srfi-69-hashtable> (class-of (make-hash-table)))

(define-method (serialize (instance <srfi-69-hashtable>))
	(list '<srfi-69-hashtable> (hash-table->alist instance)))

(define-method (%deserialize (instance <srfi-69-hashtable>) initargs)
	; TODO: use the pre-allocated instance instead of just throwing it away
	(alist->hash-table (first initargs)))
