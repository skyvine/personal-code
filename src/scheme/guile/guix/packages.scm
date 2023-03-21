(define-module (skyler guix packages)
	#:use-module (guix gexp)

	#:use-module ((skyler guix utils)      #:prefix sky:)

	#:use-module ((guix build-system copy) #:prefix guix:)
	#:use-module ((guix git-download)      #:prefix guix:)
	#:use-module ((guix gexp)              #:prefix guix:)
	#:use-module ((guix packages)          #:prefix guix:)
	#:use-module ((guix licenses)          #:prefix license:)

	#:use-module ((gnu packages guile)     #:prefix guix:)

	#:export (vim-solarized8)
)

(define vim-solarized8
	(let ((version "1.4.0"))
		(guix:package
			(name        "vim-solarized8")
			(version     "1.4.0")
			(home-page   "https://github.com/lifepillar/vim-solarized8/tree/v1.4.0")
			(synopsis    "Solarized color theme for vim with full truecolor support")
			(description "This is yet another Solarized theme for Vim. The main reason for the existence of this project is that the original Solarized theme does not define `guifg` and `guibg` in terminal Vim, making it unsuitable for versions of Vim supporting true-color (i.e., 24-bit color) terminals. Instead, this color scheme works *out of the box everywhere*.")
			(license     license:expat)

			(build-system guix:copy-build-system)
			(source (guix:origin
				(method guix:git-fetch)
				(uri (guix:git-reference
					(url "https://github.com/lifepillar/vim-solarized8")
					(commit (string-append "v" version))))
				(file-name (guix:git-file-name name version))
				(sha256 (guix:base32 "1kqpxqgw1nbysd9b84f0h70sz2gik13xzwswycrn7i529dkx4wai"))))

			(arguments '(
				#:install-plan '(
					("colors"    "share/nvim/site/")
					("doc"       "share/nvim/site/")
					("templates" "share/nvim/site/")))))))
