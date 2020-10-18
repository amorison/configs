syntax on
set background=dark
set relativenumber
set number
set cursorline
set showcmd

function! CustomHI() abort
    highlight Search cterm=bold ctermbg=150 ctermfg=16
    highlight CursorLineNr cterm=bold
    " dark-red bg at 80th column
    highlight At80thCol ctermbg=52
    " more contrasted colors in diff
    highlight diffAdded ctermfg=34
    highlight diffRemoved ctermfg=124
endfunction

augroup custom_hi
    autocmd!
    autocmd VimEnter,WinEnter * match At80thCol /\%>79v.*\n\@!\%<81v/
    autocmd ColorScheme * call CustomHI()
augroup END
colorscheme wombat256

" to display the highlight group of a word
command SynID  echo synIDattr(synID(line("."), col("."), 1), "name")

set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set autoindent
set hlsearch
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
filetype plugin indent on
augroup cd_to_bufpath
    autocmd!
    autocmd BufEnter * if &buftype!="terminal" | lcd %:p:h | endif
augroup END
nnoremap <LocalLeader>o :OpenIndentToCursorCol<CR>
command! OpenIndentToCursorCol call append('.', repeat(' ', getcurpos()[2] -1)) | exe "normal j" | startinsert!

" plugin management using junegunn/vim-plug
" run :PlugUpdate to install/update plugins
call plug#begin('~/.vim/plugged')
Plug 'ervandew/supertab'
call plug#end()
