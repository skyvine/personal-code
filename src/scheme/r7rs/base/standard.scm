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

(define-library (skyler r7rs standard)

(import
	(scheme base)
	(scheme write)
	(srfi 1)
)

(export
	; from srfi-1
	drop
	drop-right
	fold
	fold-right
	last
	reduce
	reduce-right
	take
	take-right

	first
	second
	third
	fourth
	fifth
	sixth
	seventh
	eight
	ninth
	tenth

	; from this module
	flatten
	rest
)

(begin

(define rest cdr)

(define (flatten lst)
	(define (flatten-impl lst result)
		(cond
			((null? lst) (reverse result))
			((list? (first lst))
				(flatten-impl (rest lst) (flatten-impl (first lst) result)))
			(#t (flatten-impl (rest lst) (cons (first lst) result)))))
	(flatten-impl lst '()))

))
