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

(define-module (skyler standard)
	#:use-module (ice-9 optargs)
	#:use-module (skyler r7rs standard)
)

(define (hash-table-keys ht)
	(hash-map->list (lambda (k v) k) ht))

(define (re-export-all module-name)
	(let ((interface (resolve-interface module-name)))
		(module-re-export! (current-module) (hash-table-keys (module-obarray interface)))))

(map re-export-all '((ice-9 optargs) (skyler r7rs standard)))
