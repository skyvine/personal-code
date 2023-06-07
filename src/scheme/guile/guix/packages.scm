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

(define-module (skyler guix packages)
	#:use-module (guix gexp)

	#:use-module ((guix build-system copy) #:prefix guix.)
	#:use-module ((guix git-download)      #:prefix guix.)
	#:use-module ((guix gexp)              #:prefix guix.)
	#:use-module ((guix packages)          #:prefix guix.)
	#:use-module ((guix licenses)          #:prefix license.)
	#:use-module ((guix transformations)   #:prefix guix.)
	#:use-module ((guix utils)             #:prefix guix.)

	#:use-module ((gnu packages autotools) #:prefix guix.)
	#:use-module ((gnu packages guile-xyz) #:prefix guix.)
	#:use-module ((gnu packages terminals) #:prefix guix.)

	#:export (haunt-0.3.0 kmscon-with-configurable-resolution vim-solarized8)
)

(use-modules (skyler standard))
(read-set! keywords 'postfix)

(define kmscon-with-configurable-resolution
	((guix.options->transformation '((with-patch . "kmscon=/home/skyler/Projects/personal-code/patches/kmscon-configurable-resolution.patch")))
	                               guix.kmscon))

(define haunt-0.3.0 (guix.package
	(inherit guix.haunt)
	(name "haunt-0.3.0")
	(version "0.3.0")
	(native-inputs (guix.modify-inputs (guix.package-native-inputs guix.haunt)
	                                   (guix.prepend guix.autoconf guix.automake)))
	(source (guix.origin
		(method guix.git-fetch)
		(uri (guix.git-reference
			(url "https://git.dthompson.us/haunt.git")
			(commit "d7cac9e175082829ebfd31185bc3811575f2deb5")))
		(file-name (guix.git-file-name name version))
		(sha256 (guix.base32 "1w703ic2pvjcfy3541a206iz5iljxpynvp21dcr6ls8mxzfk7g3x"))))))

(define vim-solarized8
	(let ((version "1.4.0"))
		(guix.package
			(name        "vim-solarized8")
			(version     "1.4.0")
			(home-page   "https://github.com/lifepillar/vim-solarized8/tree/v1.4.0")
			(synopsis    "Solarized color theme for vim with full truecolor support")
			(description "This is yet another Solarized theme for Vim. The main reason for the existence of this project is that the original Solarized theme does not define `guifg` and `guibg` in terminal Vim, making it unsuitable for versions of Vim supporting true-color (i.e., 24-bit color) terminals. Instead, this color scheme works *out of the box everywhere*.")
			(license     license.expat)

			(build-system guix.copy-build-system)
			(source (guix.origin
				(method guix.git-fetch)
				(uri (guix.git-reference
					(url "https://github.com/lifepillar/vim-solarized8")
					(commit (string-append "v" version))))
				(file-name (guix.git-file-name name version))
				(sha256 (guix.base32 "1kqpxqgw1nbysd9b84f0h70sz2gik13xzwswycrn7i529dkx4wai"))))

			(arguments '(
				install-plan: '(
					("colors"    "share/nvim/site/")
					("doc"       "share/nvim/site/")
					("templates" "share/nvim/site/")))))))
