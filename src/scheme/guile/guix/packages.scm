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
; Contains definitions for packages that I want to install but are not available upstream.

(read-set! keywords #f)

(define-module (skyler guix packages)
	#:use-module (guix gexp)

	#:use-module ((guix build-system copy)   #:prefix guix.)
	#:use-module ((guix build-system meson)  #:prefix guix.)
	#:use-module ((guix download)            #:prefix guix.)
	#:use-module ((guix git-download)        #:prefix guix.)
	#:use-module ((guix gexp)                #:prefix guix.)
	#:use-module ((guix packages)            #:prefix guix.)
	#:use-module ((guix licenses)            #:prefix license.)
	#:use-module ((guix transformations)     #:prefix guix.)
	#:use-module ((guix utils)               #:prefix guix.)

	#:use-module ((gnu packages)             #:prefix guix.)
	#:use-module ((gnu packages autotools)   #:prefix guix.)
	#:use-module ((gnu packages check)       #:prefix guix.)
	#:use-module ((gnu packages docbook)     #:prefix guix.)
	#:use-module ((gnu packages freedesktop) #:prefix guix.)
	#:use-module ((gnu packages gl)          #:prefix guix.)
	#:use-module ((gnu packages gtk)         #:prefix guix.)
	#:use-module ((gnu packages guile-xyz)   #:prefix guix.)
	#:use-module ((gnu packages linux)       #:prefix guix.)
	#:use-module ((gnu packages pkg-config)  #:prefix guix.)
	#:use-module ((gnu packages terminals)   #:prefix guix.)
	#:use-module ((gnu packages xdisorg)     #:prefix guix.)
	#:use-module ((gnu packages xml)         #:prefix guix.)

	#:export (
		libtsm
		; Aetf's version of libtsm which is required to build the updated kmscon (below).

		kmscon
		; A version of kmscon which is based on Aetf's development tree and has additional
		; changes for screen size support. 

		haunt-0.3.0
		; The latest version of haunt. Notably, it includes the `--host` argument to
		; `haunt build` which is helpful for testing in QubesOS. The tag exists, but no
		; tarball, so I don't think this is actually released yet.

		neovim-solarized8
		; Like the solarized package but with better truecolor support. Nothing fancy here.
))

(use-modules (skyler standard))
(read-set! keywords 'postfix)

(define libtsm
	(let ((commit "d66dd165a4a75d32c84a119bc5ec0da2aae52379"))
		(guix.package
			(inherit guix.libtsm)
			(name    "libtsm")
			(version (guix.git-version "4.0.2" "1" commit))

			(source (guix.origin
				(method    guix.git-fetch)
				(uri       (guix.git-reference (url "https://github.com/Aetf/libtsm")
				                               (commit commit)))
				(sha256    (guix.base32 "1n35blpl1yxlxib0v72cbycx2y6lsrq2asmayw7xq476ana6pcwd"))
				(file-name (guix.git-file-name "libtsm" version)))))))

(define kmscon
	(let ((commit "1f40bee5e692be6c8c571c06ec3ddb8896badbd9"))
		(guix.package
			; The COPYING file mentions some items not included in the guix licensing notes
			; (they are on a much older commit which does not use meson, hence this package),
			; but all of the licenses mentioned for the new items were already present for old
			; items.
			(inherit guix.kmscon)
			(name    "kmscon")
			(version (guix.git-version "9.0.0" "1" commit))

			(source (guix.origin
				(method    guix.git-fetch)
				(uri       (guix.git-reference (url "https://git.sr.ht/~skyvine/kmscon")
				                               (commit commit)))
				(sha256    (guix.base32 "157pvsmxw6dqraqbnaqpgrjsdgdgcf1kyi45zw4s545ndwbiba7s"))
				(file-name (guix.git-file-name "kmscon" version))))

			(build-system guix.meson-build-system)

			(native-inputs (list
				guix.check
				guix.docbook-xsl
				guix.libxslt
				guix.libxml2
				guix.mesa
				guix.pkg-config
			))

			(inputs (list
				guix.libdrm
				libtsm
				guix.libxkbcommon
				guix.pango
				guix.eudev
			))

			(arguments `(
				; the remove-sytemd phase from guix's definition references files that have been
				; removed in the updated Aetf version; removing systemd is a little more
				; complicated now that meson is in use, and since I'm already using a different
				; repository I just made the changes there.
				phases: (@ (guix build meson-build-system) %standard-phases))))))

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

(define neovim-solarized8
	(guix.package
		(name        "neovim-solarized8")
		(version     "1.5.1-neovim")
		(home-page   "https://github.com/lifepillar/vim-solarized8/tree/v1.4.0")
		(synopsis    "Solarized color theme for vim with full truecolor support")
		(description "This is yet another Solarized theme for Vim. The main reason for the existence of this project is that the original Solarized theme does not define `guifg` and `guibg` in terminal Vim, making it unsuitable for versions of Vim supporting true-color (i.e., 24-bit color) terminals. Instead, this color scheme works *out of the box everywhere*.")
		(license     license.expat)

		(build-system guix.copy-build-system)
		(source (guix.origin
			(method guix.url-fetch)
			(uri
				(string-append "https://github.com/lifepillar/vim-solarized8/archive/refs/tags/v"
				               version ".tar.gz"))
			(sha256 (guix.base32 "1pqspr68y7djyjq1l3hmk438kw4pr8wq438s66657d5rdp2bk0rf"))))

		(arguments '(
			install-plan: '(
				("colors"    "share/nvim/site/")
				("doc"       "share/nvim/site/")
				("templates" "share/nvim/site/"))))))
