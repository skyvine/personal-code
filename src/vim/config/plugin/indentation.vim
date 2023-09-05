function s:SetIndentColumn()
	let b:indent_column = virtcol('.')
endfunction
nnoremap <a-i> :call <SID>SetIndentColumn()<CR>

function s:IndentsNeeded()
	return b:indent_column - virtcol('.')
endfunction

function s:IndentToColumn()
	execute "normal! i" . repeat(" ", s:IndentsNeeded())
endfunction
nnoremap > :call <SID>IndentToColumn()<CR>

function s:VisualIndentToColumn(type)
	if a:type ==# ""
		execute "normal! `<`>I" . repeat(" ", s:IndentsNeeded())
	else
		echom "Unsupported visual type: " . a:type
	endif
endfunction
vnoremap > :<c-u>call <SID>VisualIndentToColumn(visualmode())<cr>
