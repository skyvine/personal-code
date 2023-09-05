" Misc Behavior/Visuals {{{
set nu
set noerrorbells
set colorcolumn=91

set autochdir
set mouse=

set tabstop=2
set autoindent
set nosmartindent
set nowrap
inoremap <Tab> <C-v><Tab>

set hlsearch  " highlight all matches when searhing
set incsearch " start highlighting while the expression is still being typed
set ignorecase

" 'list' means 'show blankspace'
set list
" make the final character a crossed pipe, all characters before the double-arrow
set listchars=tab:⇉⇉‡
" }}}

" Colorscheme {{{
set background=dark
set termguicolors

function RemoveRedFromSolarized()
	highlight PreProc guifg=#d33682
	highlight Special guifg=#6c71c4
	highlight Underlined guifg=#268bd2 gui=underline cterm=underline
endfunction

function ColorOfTabMarker()
	if &background ==# 'light'
		highlight NonText guifg=#93a1a1 cterm=italic gui=italic
	else " dark
		highlight NonText guifg=#586e75 cterm=italic gui=italic
	endif
	highlight link NonText Comment
endfunction

augroup SolarizedCustomization
	autocmd!
	autocmd ColorScheme solarized8 call RemoveRedFromSolarized()
	autocmd ColorScheme solarized8 call ColorOfTabMarker()
augroup END

colorscheme solarized8
" }}}

" Status Line {{{
set statusline=
set statusline+=%f%m%r  " filename[modified][RO]
set statusline+=\ %y    " filetype
set statusline+=%=      " switch sides
set statusline+=[%l/%L] " current line / total lines
set statusline+=:%c     " column number
" }}}

" Meson Settings {{{
" With meson 1.1, meson_options.txt has been renamed to meson.options
augroup meson
	autocmd!
	autocmd BufNewFile,BufRead meson.options set filetype=meson
augroup END
" }}}
