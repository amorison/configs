" put \begin{} \end{} tags tags around the current word
function! s:ExpandTexEnv()
    let l:cword = expand("<cWORD>")
    execute "normal! YpkI\\begin{\<esc>A}\<esc>jI\\end{\<esc>A}\<esc>k$"
    if l:cword ==# "equation"
        execute "normal! o\\label{eq:}\<esc>k$"
    elseif l:cword ==# "figure"
        execute "normal! o\\includegraphics{}\<cr>\\caption{}\<cr>\\label{fig:}\<esc>2k$h"
    elseif l:cword ==# "frame"
        execute "normal! o\\frametitle{}\<esc>h"
    elseif l:cword ==# "minipage"
        execute "normal! A{\\textwidth}\<esc>%"
    endif
endfunction

nnoremap <F5> :call <SID>ExpandTexEnv()<CR>a
inoremap <F5> <ESC>:call <SID>ExpandTexEnv()<CR>a
