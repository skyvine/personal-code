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
	(scheme case-lambda)
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
	n-ary-combinations
	flatten
	rest
)

(begin

(define rest cdr)

(define (n-ary-combinations given)
	"Return all possible combinations of any length composed of elements in the given list."

	; Notes:
	; 1. All n-ary combinations of a one-element list are that list and the empty list
	; 2. If there are 2 elements, then:
	;    2a. Set the first element aside
	;    2b. Get all the combinations in case 1, these are also valid for case 2
	;    2c. Additionally prepend the first element to all combinations in case 1
	; n. For n elements, case 2 applies, replacing case 1 with case n-1.
	(define (combination-branches-for remaining-givens)
		(if (eq? (length remaining-givens) 1)
			(list remaining-givens '()) ; 1
			(let ((sub-branches (combination-branches-for (rest remaining-givens)))) ; n
				(append (map (lambda (branch) (cons (first remaining-givens) branch))
				             sub-branches) ; 2c
				        sub-branches)))) ; 2b

	(apply (case-lambda (() '(()))
	                    (_ (combination-branches-for given)))
	       given))

(define (flatten lst)
	(define (flatten-impl lst result)
		(cond
			((null? lst) (reverse result))
			((list? (first lst))
				(flatten-impl (rest lst) (flatten-impl (first lst) result)))
			(#t (flatten-impl (rest lst) (cons (first lst) result)))))
	(flatten-impl lst '()))

))
