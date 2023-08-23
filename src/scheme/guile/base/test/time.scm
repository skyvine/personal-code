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

(define-module (skyler test time)
	#:use-module (ice-9 format)
	#:use-module (ice-9 match)
	#:use-module (oop goops)
	#:use-module (skyler time)
	#:use-module (skyler test util)
	#:use-module (srfi srfi-1)
	#:use-module (srfi srfi-64)
)

(define (1-of-each-unit function-under-test conversion-table)
	(define total (fold (lambda (entry result) (+ result (cdr entry)))
	                    0 conversion-table))

	(define result (function-under-test total))

	(for-each (match-lambda* (((unit . __) . _)
	                          (let ((value (slot-ref result unit)))
	                          	(format ((log-port)) "Value of ~a: ~:d~%" unit value)
	                          	(test-assert (= value 1)))))
	          conversion-table))

(define-test nanoseconds-1-of-each-unit "Nanoseconds (exactly 1 of each unit)"
	(1-of-each-unit nanoseconds->period (@@ (skyler time) nanoseconds-per)))

(define-test seconds-1-of-each-unit "Seconds (exactly 1 of each unit)"
	(1-of-each-unit seconds->period (@@ (skyler time) seconds-per)))

(define (1-plus-1-of-each-unit function-under-test conversion-table)
	(define total (fold (lambda (entry result) (+ 1 result (cdr entry)))
	                    0 conversion-table))

	(define result (function-under-test total))

	(for-each (match-lambda* (((unit . per) . _)
	                          (let ((value (slot-ref result unit))
	                                (expected (if (= per 1)
	                                          	(+ 1 (length conversion-table))
	                                          	1)))
	                          	(format ((log-port)) "Value of ~a: ~:d~%" unit value)
	                          	(test-assert (= value expected)))))
	          conversion-table))

(define-test nanoseconds-1-plus-1-of-each-unit "Nanoseconds (1 + 1 of each unit)"
	(1-plus-1-of-each-unit nanoseconds->period (@@ (skyler time) nanoseconds-per)))

(define-test seconds-1-plus-1-of-each-unit "Seconds (1 + 1 of each unit)"
	(1-plus-1-of-each-unit seconds->period (@@ (skyler time) seconds-per)))

(define (1-plus-half-of-unit entry)
	(define uut (make <period>))

	(match-let ((((from . to) . ratio) entry))
		(slot-set! uut from (+ ratio (quotient ratio 2)))
		(format ((log-port)) "set the slot")
		(simplify! uut)
		(format ((log-port)) "simplified")
		(test-assert "to"   (= (slot-ref uut to) 1))
		(test-assert "from" (= (slot-ref uut from) (quotient ratio 2)))))

(define-test 1-plus-half "Period (1 plus half)"
	(for-each 1-plus-half-of-unit (@@ (skyler time) single-step-ratios)))

(define-test some-random-math "Some random math"
	(let ((lhs (make <period> seconds: 50))
	      (rhs (multiply (make <period> seconds: 25) 3)))
		(format ((log-port)) "lhs: ~a~%" lhs)
		(format ((log-port)) "rhs: ~a~%" rhs)
		(test-assert "Multiplication" (and
			(= (seconds rhs) 15)
			(= (minutes rhs)  1)
			(= (hours   rhs)  0)))

		(let ((added (add lhs rhs)))
			(format ((log-port)) "added: ~a~%" rhs)
			(test-assert "Addition" (and
				(= (seconds added) 5)
				(= (minutes added) 2)
				(= (hours   added) 0))))))

(define all-tests (list nanoseconds-1-of-each-unit
                        seconds-1-of-each-unit
                        nanoseconds-1-plus-1-of-each-unit
                        seconds-1-plus-1-of-each-unit
                        1-plus-half
                        some-random-math))
