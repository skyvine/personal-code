nnoremap <tab> :bn<enter>

let mapleader = " "

nnoremap K <nop>

nnoremap <leader><escape> <nop>

nnoremap <leader><leader>l :set list!<enter>

nnoremap <leader>bs :w<enter>
nnoremap <leader>bi :edit $MYVIMRC<enter>
nnoremap <leader>bd gQbuffers<enter>bdelete 
nnoremap <leader>bw :s/\v\s+$//

nnoremap <leader>.b gQbuffers<enter>buffer 
nnoremap <leader>.d :q<enter>
nnoremap <leader>.e :edit 
nnoremap <leader>./ :vsplit<enter>
nnoremap <leader>.- :split<enter>
nnoremap <leader>.h <c-w>h
nnoremap <leader>.j <c-w>j
nnoremap <leader>.k <c-w>k
nnoremap <leader>.l <c-w>l
nnoremap <leader>.H <c-w>H
nnoremap <leader>.J <c-w>J
nnoremap <leader>.K <c-w>K
nnoremap <leader>.L <c-w>L

nnoremap <leader>h :help 

nnoremap <leader>ei :source $MYVIMRC<enter>
nnoremap <leader>eb :source %<enter>

nnoremap <s-space>x dd
