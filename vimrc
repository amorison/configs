syntax on
set background=dark
set relativenumber
set number
set cursorline
set showcmd

set t_Co=256
colorscheme wombat256
highlight Search cterm=bold ctermbg=150 ctermfg=16
highlight CursorLineNr cterm=bold
" dark-red bg at 80th column
highlight At80thCol ctermbg=52
augroup custom_hi
    autocmd!
    autocmd VimEnter,WinEnter * match At80thCol /\%>79v.*\n\@!\%<81v/
augroup END
" more contrasted colors in diff
highlight diffAdded ctermfg=34
highlight diffRemoved ctermfg=124
" to display the highlight group of a word
command SynID  echo synIDattr(synID(line("."), col("."), 1), "name")

set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set smartindent
set hlsearch
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
filetype plugin indent on
augroup cd_to_bufpath
    autocmd!
    autocmd BufEnter * if &buftype!="terminal" | lcd %:p:h | endif
augroup END
nnoremap <LocalLeader>o :OpenIndentToCursorCol<CR>
command! OpenIndentToCursorCol call append('.', repeat(' ', getcurpos()[2] -1)) | exe "normal j" | startinsert!
