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
	; IMPORTANT: This module MUST NOT import any modules from the `(skyler ...)` namespace
	;            other than build-utils, to avoid bootstrapping complexity. Modules from
	;            guile core and guix are fine. Other third-party modules might be fine but
	;            I haven't tried crossing that bridge yet.
	#:use-module (skyler guix build-utils)

	#:use-module (guix gexp)

	#:use-module ((guix build-system copy)          #:prefix guix.)
	#:use-module ((guix build-system guile)         #:prefix guix.)
	#:use-module ((guix build-system meson)         #:prefix guix.)
	#:use-module ((guix build-system trivial)       #:prefix guix.)
	#:use-module ((guix download)                   #:prefix guix.)
	#:use-module ((guix git-download)               #:prefix guix.)
	#:use-module ((guix gexp)                       #:prefix guix.)
	#:use-module ((guix packages)                   #:prefix guix.)
	#:use-module ((guix licenses)                   #:prefix license.)
	#:use-module ((guix transformations)            #:prefix guix.)
	#:use-module ((guix utils)                      #:prefix guix.)

	#:use-module ((gnu packages)                    #:prefix guix.)
	#:use-module ((gnu packages autotools)          #:prefix guix.)
	#:use-module ((gnu packages check)              #:prefix guix.)
	#:use-module ((gnu packages docbook)            #:prefix guix.)
	#:use-module ((gnu packages freedesktop)        #:prefix guix.)
	#:use-module ((gnu packages gl)                 #:prefix guix.)
	#:use-module ((gnu packages gtk)                #:prefix guix.)
	#:use-module ((gnu packages gnupg)              #:prefix guix.)
	#:use-module ((gnu packages guile)              #:prefix guix.)
	#:use-module ((gnu packages guile-xyz)          #:prefix guix.)
	#:use-module ((gnu packages linux)              #:prefix guix.)
	#:use-module ((gnu packages package-management) #:prefix guix.)
	#:use-module ((gnu packages pkg-config)         #:prefix guix.)
	#:use-module ((gnu packages terminals)          #:prefix guix.)
	#:use-module ((gnu packages tls)                #:prefix guix.)
	#:use-module ((gnu packages version-control)    #:prefix guix.)
	#:use-module ((gnu packages xdisorg)            #:prefix guix.)
	#:use-module ((gnu packages xml)                #:prefix guix.)

	#:export (
		; External Packages
		guix-utilities
		; A guile library constructed from files picked out of the guix source. Useful for
		; taking advantage of guix utilities (such as `invoke` or `mkdir-p`) in tools that
		; might be exported to foreign environments (eg, through `guix pack`).

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

		guile-gnutls-3.7.14
		; The latest version of guile-gnutls. Adds some function to the API such as
		; generate-x509-private-key.

		; Local Packages
		patches
		; A package containing the patches that I use on packages defined elsewhere.

		base-guile-code
		; A package containing all of the code in the "base" projects. This code is intended
		; to be re-usable across multiple projects and keeping it in a separate project keeps
		; the dependency footprint smaller.

		guix-code
		; A package containing all of my guix configuration, including helpers for defining
		; machines for specific uses, packages, and everything else that depends on guix.

		haunt-code
		; A package containing the helper functions I use for generating web pages with Haunt.

		red-team-code
		; A package containing utilities for red-teamers

		web-code
		; A package containing support code for web programming

		personal-code
		; A meta-package which includes the other packages defined in this file as propagated
		; inputs.
))

(use-modules (skyler standard))
(read-set! keywords 'postfix)

(define guix-utilities
	(guix.package
		(inherit guix.guix)
		(build-system guix.guile-build-system)
		(inputs '())
		(propagated-inputs (list guix.guile-3.0-latest))
		(arguments (list #:phases
			#~(modify-phases (@ (guix build guile-build-system) %standard-phases)
				(add-after 'unpack 'pick-files
					(lambda* (key: source #:allow-other-keys)
						(use-modules (guix build utils))

						(chdir "..")
						(let ((target-directory "included-source/"))
							(map
								(lambda (filename)
									(let ((target-location (string-append target-directory
									                                      (dirname filename)))
									      (source-filename (string-append "source/" filename))
									      (target-filename (string-append target-directory filename)))
										(mkdir-p target-location)
										(copy-file source-filename target-filename)))
								'("guix/build/utils.scm" "guix/base64.scm"))
							(delete-file-recursively "source")
							(chdir target-directory)))))))))

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

(define guile-gnutls-3.7.14
	(guix.package
		(inherit guix.guile-gnutls)
		(version "3.7.14")
		(source (guix.origin
			(method guix.git-fetch)
			(uri (guix.git-reference
				(url "https://gitlab.com/gnutls/guile")
				(commit (string-append "v" version))))
			(file-name (guix.git-file-name "gnutls" version))
			(sha256 (guix.base32 "01571piav96kw32g3k8ccfand4vp7x92rrfdnybaghjfa2bay2qj"))))
		(native-inputs (cons* `("autoconf" ,guix.autoconf)
		                      `("automake" ,guix.automake)
		                      (guix.package-native-inputs guix.guile-gnutls)))))

; Local Packages
(define project-root
	(canonicalize-path (string-append (dirname (current-filename)) "/../../../..")))

(define (project-dir dir)
	(guix.local-file (string-append project-root "/" dir) recursive?: #t))

(define version "0.0")
(define home-page "https://git.sr.ht/~skyvine/personal-code")
(define license license.agpl3+)

(define patches (let ((patches-dir (project-dir "patches")))
	(guix.package
		(name        "patches")
		(version     version)
		(source      #f)
		(description "Custom patches to suit software to my taste.")
		(synopsis    description)
		(home-page   home-page)
		(license     license)

		(build-system guix.copy-build-system)
		(inputs (list patches-dir))
		(arguments (list
			phases: '(modify-phases (@ (guix build copy-build-system) %standard-phases)
			        	(delete 'unpack))
			install-plan: #~(list (list #$patches-dir "share/patches")))))))

(define base-guile-code
	(let ((guile-src (project-dir "src/scheme/guile/base"))
	      (r7rs-src  (project-dir "src/scheme/r7rs/base")))
		(guix.package
			(name        "base-guile-code")
			(version     version)
			(source      #f)
			(description "Sharable code used by my projects.")
			(synopsis    description)
			(home-page   home-page)
			(license     license)

			(build-system  guix.guile-build-system)
			(native-inputs (list guix.guile-3.0-latest))
			(inputs        (list guile-src r7rs-src))

			(arguments (list
				modules: `((guix build utils) ,@guix.%guile-build-system-modules)

				phases: #~(modify-phases (@ (guix build guile-build-system) %standard-phases)
					(delete 'unpack)
					(add-before 'set-locale-path 'fix-paths
						; Paths in the filesystem are sensible for editing, but not a useful
						; module structure inside an actual implementation
						(lambda* (key: inputs #:allow-other-keys)
							(use-modules (guix build utils))
							(copy-recursively #$guile-src "./skyler")
							(copy-recursively #$r7rs-src "./skyler/r7rs")))

					(add-after 'install-documentation 'check
						#$(check '((skyler r7rs test)
						           (skyler serialization test)
						           (skyler test time))))))))))

(define guix-code
	(let ((guix-dir (project-dir "src/scheme/guile/guix")))
		(guix.package
			(name        "guix-code")
			(version     version)
			(source      #f)
			(description #f)
			(synopsis    #f)
			(home-page   #f)
			(license     #f)

			(build-system  guix.guile-build-system)
			(native-inputs (list guix.guile-3.0-latest))
			(inputs        (list guix-dir patches))

			(propagated-inputs (list
				guix.guile-gcrypt
				base-guile-code
				patches
			))

			(arguments (list
				; don't compile anything, we always want to use the system's guix, not some snapshot
				not-compiled-file-regexp: ".*"

				phases: #~(modify-phases (@ (guix build guile-build-system) %standard-phases)
					(delete 'unpack)
					(add-before 'set-locale-path 'fix-paths
						; Paths in the filesystem are sensible for editing, but not a useful
						; module structure inside an actual implementation
						(lambda* (key: inputs #:allow-other-keys)
							(use-modules (guix build utils))
							(copy-recursively #$guix-dir "./skyler/guix")))

					(add-after 'fix-paths 'inject-store-paths #$inject-store-paths)))))))

(define haunt-code
	(let ((haunt-dir (project-dir "src/scheme/guile/haunt"))
	      (upgrade-guile-gnutls (guix.package-input-rewriting
	      	`((,guix.guile-gnutls ,guile-gnutls-3.7.14))))
				)
		(guix.package
			(name        "haunt-code")
			(version     version)
			(source      #f)
			(description "Code which supports my website.")
			(synopsis    description)
			(home-page   home-page)
			(license     license)

			(build-system  guix.guile-build-system)
			(native-inputs (list guix.guile-3.0-latest patches))
			(inputs        (list haunt-dir))

			(propagated-inputs (list
				base-guile-code
				guix.gnupg
				(upgrade-guile-gnutls guix.haunt)
			))

			(arguments (list
				phases: #~(modify-phases (@ (guix build guile-build-system) %standard-phases)
					(delete 'unpack)
					(add-before 'set-locale-path 'fix-paths
						; Paths in the filesystem are sensible for editing, but not a useful
						; module structure inside an actual implementation
						(lambda* (key: inputs #:allow-other-keys)
							(use-modules (guix build utils))
							(copy-recursively #$haunt-dir "./skyler/haunt")))

					(add-after 'fix-paths 'inject-store-paths #$inject-store-paths)))))))

(define red-team-code
	(let ((red-team-dir (project-dir "src/scheme/guile/red-team")))
		(guix.package
			(name        "red-team-code")
			(version     version)
			(source      #f)
			(description "Red teaming scripts; not industrial-grade.")
			(synopsis    description)
			(home-page   home-page)
			(license     license)

			(build-system  guix.guile-build-system)
			(native-inputs (list guix.guile-3.0-latest patches))
			(inputs        (list red-team-dir))

			(propagated-inputs (list base-guile-code guix-utilities))

			(arguments (list
				phases: #~(modify-phases (@ (guix build guile-build-system) %standard-phases)
					(delete 'unpack)
					(add-before 'set-locale-path 'fix-paths
						; Paths in the filesystem are sensible for editing, but not a useful
						; module structure inside an actual implementation
						(lambda* (key: inputs #:allow-other-keys)
							(use-modules (guix build utils))
							(unless (copy-recursively #$red-team-dir "./skyler/red-team")
								(error "Unable to copy source!"))))

					(add-after 'fix-paths 'inject-store-paths #$inject-store-paths)

					(add-before 'inject-store-paths 'copy-webshells
						(lambda* (key: outputs #:allow-other-keys)
							(use-modules (guix build utils))
							(let ((webshells-dir "skyler/red-team/webshells/")
							      (share-dir (string-append (assoc-ref outputs "out") "/share/")))
								(format #t "Webshells dir: ~s~%" webshells-dir)
								(format #t "Share dir:     ~s~%" share-dir)
								(force-output)
								(mkdir-p share-dir)
								(unless (copy-recursively webshells-dir
								                          (string-append share-dir "/webshells"))
									(error "Unable to copy webshells!")))))))))))

(define web-code (let ((web-dir (project-dir "src/scheme/guile/web")))
	(guix.package
		(name        "web-code")
		(version     version)
		(source      #f)
		(description "Code for working with internet technologies.")
		(synopsis    description)
		(home-page   home-page)
		(license     license)

		(build-system  guix.guile-build-system)
		(native-inputs (list guix.guile-3.0-latest))
		(inputs        (list web-dir))

		(propagated-inputs (list
			base-guile-code
			guile-gnutls-3.7.14
			guix.openssl
		))

		(arguments (list
			phases: #~(modify-phases (@ (guix build guile-build-system) %standard-phases)
				(delete 'unpack)
				(add-before 'set-locale-path 'fix-paths
					; Paths in the filesystem are sensible for editing, but not a useful
					; module structure inside an actual implementation
					(lambda* (key: inputs #:allow-other-keys)
						(use-modules (guix build utils))
						(copy-recursively #$web-dir "./skyler/web")))

				(add-after 'fix-paths 'inject-store-paths #$inject-store-paths)))))))

(define personal-code (guix.package
	(name        "personal-code")
	(source      #f)
	(version     version)
	(description "A meta-package propogating all of my personal packages.")
	(synopsis    description)
	(home-page   home-page)
	(license     license)

	(build-system      guix.trivial-build-system)
	(propagated-inputs (list guix.guile-3.0-latest base-guile-code guix-code guix-utilities haunt-code red-team-code web-code))
	(arguments         `(builder: (begin (mkdir (assoc-ref %outputs "out")))))))
