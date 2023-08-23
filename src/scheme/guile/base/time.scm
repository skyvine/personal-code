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
;
; This module exists because there is no built-in way to convert an amount of time to a
; human-readable description. For example, if I have 2.3 * 10^5 seconds in a time object,
; how many hours is that? How many minutes left over? Etc. The period class in this module
; answers that question.

(define-module (skyler time)
	#:use-module (ice-9 match)
	#:use-module (oop goops)
	#:use-module (skyler standard)
	#:use-module (srfi srfi-1)
	#:use-module (srfi srfi-11)
	#:use-module (srfi srfi-19)
	#:export     (

		; Period Class
		<period>
		; Represents a period of time. Tracks units ranging from days to nanoseconds. Mostly
		; exists for formatting textual output.
		;
		; The diplay generic (~a) is specialized on this class for readable output.

		days hours minutes seconds milliseconds nanoseconds
		; These accessors return the amount of each unit being tracked by the period. Note
		; that none of these accessors return the total amount of time tracked. If a period
		; contains 1 hour 3 minutes, then (minutes period) will return 3 and (hours period)
		; will return 1.

		add
		; Method signature: (add lhs rhs)
		;
		; Arguments:
		; lhs, rhs (period): The periods to add together
		;
		; Return:
		; A new period object which represents lhs and rhs contiguously.

		multiply
		; Method signature: (multiply lhs rhs)
		;
		; Arguments:
		; lhs (period): a period of time to be scaled
		; rhs (number): a factor to scale the period by
		;
		; note: arguments may be given in reverse order
		;
		; Returns:
		; A new period which represents lhs occuring rhs times contiguously.

		simplify!
		; Signature: (simplify! period)
		;
		; Arguments:
		; period: The period to destructively simplify. It WILL be modified.
		;
		; Returns:
		; The updated period object.
		;
		; In this context, "simplify" means to make sure that each value contains less than
		; its ratio for the next unit. For example, a period which contains 90 seconds will
		; contain 1 minute 30 seconds after simplification.

		nanoseconds->period
		; Signature: (nanoseconds->period nanoseconds)
		;
		; Arguments:
		; nanoseconds: An integral number
		;
		; Returns:
		; A simplified period representing the same amount of time as the given number of
		; nanoseconds.

		seconds->period
		; Signature: (seconds->period seconds)
		;
		; Arguments:
		; seconds: An integral number
		;
		; Returns:
		; A simplified period representing the same amount of time as the given number of
		; seconds.

		time->period
		; Signature: (time->period time)
		;
		; Arguments:
		; time: An srfi-19 time object
		;
		; Returns:
		; A simplified period representing the same amount of time as given.
))

(re-export-all '(srfi srfi-19))

; # Conversion Tables

(define single-step-ratios '(
	((nanoseconds  . milliseconds) . 1000000)
	((milliseconds . seconds)      . 1000)
	((seconds      . minutes)      . 60)
	((minutes      . hours)        . 60)
	((hours        . days)         . 24)
))

(define seconds-per `(
	(days    . ,(* 3600 24))
	(hours   . 3600)
	(minutes . 60)
	(seconds . 1)
))

(define nanoseconds-per `(
	(days         . ,(* 86.4 1000 1000 1000 1000))
	(hours        . ,(*  3.6 1000 1000 1000 1000))
	(minutes      . ,(*        60 1000 1000 1000))
	(seconds      . ,(*         1 1000 1000 1000))
	(milliseconds . ,(*              1 1000 1000))
	(nanoseconds  . 1)
))

; # Class definition & methods

(define-class <period> ()
	(days         init-value: 0 init-keyword: #:days         accessor: days)
	(hours        init-value: 0 init-keyword: #:hours        accessor: hours)
	(minutes      init-value: 0 init-keyword: #:minutes      accessor: minutes)
	(seconds      init-value: 0 init-keyword: #:seconds      accessor: seconds)
	(milliseconds init-value: 0 init-keyword: #:milliseconds accessor: milliseconds)
	(nanoseconds  init-value: 0 init-keyword: #:nanoseconds  accessor: nanoseconds)
)

(define-method (display (obj <period>) port)
	(format port "~a days, ~a:~a:~a hours ~ams ~ans"
	             (days obj)
	             (hours obj)
	             (minutes obj)
	             (seconds obj)
	             (milliseconds obj)
	             (nanoseconds obj)))

(define-method (add (lhs <period>) (rhs <period>))
	(let ((ret (make <period> #:days          (+ (days lhs)         (days rhs))
	                          #:hours         (+ (hours lhs)        (hours rhs))
	                          #:minutes       (+ (minutes lhs)      (minutes rhs))
	                          #:seconds       (+ (seconds lhs)      (seconds rhs))
	                          #:milliseconds  (+ (milliseconds lhs) (milliseconds rhs))
	                          #:nanoseconds   (+ (nanoseconds lhs)  (nanoseconds rhs)))))
		(simplify! ret)))

(define-method (multiply (lhs <period>) (rhs <number>))
	(let ((ret (make <period> #:days          (* (days lhs)         rhs)
	                          #:hours         (* (hours lhs)        rhs)
	                          #:minutes       (* (minutes lhs)      rhs)
	                          #:seconds       (* (seconds lhs)      rhs)
	                          #:milliseconds  (* (milliseconds lhs) rhs)
	                          #:nanoseconds   (* (nanoseconds lhs)  rhs))))
		(simplify! ret)))

(define-method (multiply (lhs <number>) (rhs <period>))
	(multiply rhs lhs))

; # Plain Functions

(define (simplify! period)
	(define process-entry (match-lambda*
	                      	((((from . to) . ratio))
	                      	 (let ((current-value (slot-ref period from)))
	                      	 	(when (>= current-value ratio)
	                      	 		(let-values (((to-result from-result)
	                      	 		              (truncate/ current-value ratio)))
	                      	 		  (slot-set! period from from-result)
	                      	 		  (slot-set! period to (+ to-result (slot-ref period to)))))))))

	(for-each process-entry single-step-ratios)
	period)

(define (time->period time)
	(let* ((seconds     (seconds->period     (time-second time)))
	       (nanoseconds (nanoseconds->period (time-nanosecond time))))
		(simplify! (add seconds nanoseconds))))

(define (units->period amount conversion-table)
	(define process-entry (match-lambda*
		(((unit . per) (result . amount))
			(let-values (((quotient remainder) (truncate/ amount per)))
				(slot-set! result unit (+ (slot-ref result unit) quotient))
				(cons result remainder)))))

	(car (fold process-entry (cons (make <period>) amount) conversion-table)))

(define (nanoseconds->period amount) (units->period amount nanoseconds-per))
(define (seconds->period amount) (units->period amount seconds-per))
