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

; This file is heavily dependent on GNU Guix. If you are not familiar with that project,
; it will not make much sense.

; # Documentation
; This file defines the set of packages which provide the code in this repository. This
; file needs to be installed imperatively, because the repository contains the
; operating-system and home definitions which would otherwise use the packages defined in
; this file. To avoid this problem, this file is used to "bootstrap" a new system with
; the definitions and dependencies. The other option would be to keep a separate
; repository as a channel, and this was tried first, but it added additional complexity
; without a clear benefit because there was still a bootstrapping step. It additionally
; cause an issue because upgrading the packages in this repository through `guix pull`
; also fetches updates from Guix (and any other channels such as RDE), which is rude when
; this is in active development and needs to be upgraded multiple times in a single day.

(load "src/scheme/r7rs/base/standard.scm")
(load "src/scheme/guile/base/standard.scm")
(load "src/scheme/guile/guix/build-utils.scm")
(load "src/scheme/guile/guix/packages.scm")
(use-modules (skyler guix packages))
personal-code
