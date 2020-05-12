syntax on
set background=dark
set relativenumber
set number
set cursorline
set showcmd
set t_Co=256
colorscheme wombat256
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set smartindent
set hlsearch
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
filetype plugin indent on
set grepprg=grep\ -nH\ $*
let g:tex_flavor="lualatex"
let g:Tex_DefaultTargetFormat="pdf"
let g:Tex_CompileRule_pdf="lualatex -interaction=nonstopmode $*"
autocmd BufEnter * lcd %:p:h
set runtimepath=$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,~/.vim/after,~/.vim
nnoremap <LocalLeader>o :OpenIndentToCursorCol<CR>
command! OpenIndentToCursorCol call append('.', repeat(' ', getcurpos()[2] -1)) | exe "normal j" | startinsert!
