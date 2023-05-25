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

(read-set! keywords #f)

(define-module (skyler guix pack)
	#:use-module ((guix profiles)                #:prefix guix.)

	#:use-module ((gnu packages admin)           #:prefix guix.)
	#:use-module ((gnu packages base)            #:prefix guix.)
	#:use-module ((gnu packages code)            #:prefix guix.)
	#:use-module ((gnu packages compression)     #:prefix guix.)
	#:use-module ((gnu packages emacs)           #:prefix guix.)
	#:use-module ((gnu packages guile)           #:prefix guix.)
	#:use-module ((gnu packages tmux)            #:prefix guix.)
	#:use-module ((gnu packages version-control) #:prefix guix.)
	#:use-module ((gnu packages vim)             #:prefix guix.)

	#:export (manifest)
)

(use-modules (skyler standard)
	((skyler guix collections)      #:prefix sky.)
	((skyler guix packages)         #:prefix sky.))
(read-set! keywords 'postfix)

(define manifest (guix.packages->manifest (list
	guix.atool
	guix.git
	guix.glibc-locales
	guix.guile-3.0-latest
	guix.guile-readline
	guix.neovim
	guix.tar
	guix.the-silver-searcher
	guix.tmux
	guix.tree

	sky.vim-solarized8

	;; I'm not sure if we have enough compression algorithms yet
	guix.tar ; reducing inode usage could technically be considered compression =)
	guix.gzip
	guix.bzip2
	guix.xz
	guix.lzip
	guix.zip
)))

manifest
