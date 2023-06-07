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

; Add serialization support for srfi-19 dates. They use the symbol <srfi-19-date> as a
; marker, and a ISO 8610 date/time+zone formatted string to store the value.

(define-module (skyler serialization srfi-19)
	#:use-module (oop goops)
	#:use-module (skyler standard)
	#:use-module (srfi srfi-19)

	#:use-module (skyler serialization)

	#:export (<srfi-19-date>
	         ; This evaluates to the class of objects returned by make-date
))

; Keeping dates in iso-8610-date/time+zone format makes me less nervous about random bugs
; related to integer sizes and also makes it more portable. Strangely, srfi-19 defines ~4
; as a shortcut for this in string->date, but not date->string, so keep it in a variable
; for consistency.
(define iso-8610-date/time+zone-format "~Y-~m-~dT~H:~M:~S~z")

; The date type from (srfi srfi-19) is defined as a record, not a class, but once you load
; goops it gets a class implicitly. The class is not directly exposed through the API,
; however, so I use this hack to get at it.
(define <srfi-19-date> (class-of (make-date 0 0 0 0 0 0 0 0)))

; Note that a symbol is being literally written, instead of (class-name <srfi-19-date>).
; This is because the name of the class is not necessarily a symbol that will evaluate to
; the class. Typically it will be, because `define-class` makes it that way by default,
; but due to the above hack the class name is an implementation detail that should not be
; leaked.
(define-method (serialize (obj <srfi-19-date>))
	(list '<srfi-19-date> (date->string obj iso-8610-date/time+zone-format)))

(define-method (%deserialize (inst <srfi-19-date>) init-vals)
	; TODO: use the pre-allocated instance instead of just throwing it away
	(string->date (first init-vals) iso-8610-date/time+zone-format))
