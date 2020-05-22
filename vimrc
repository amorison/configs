syntax on
set background=dark
set relativenumber
set number
set cursorline
set showcmd
set t_Co=256
colorscheme wombat256
highlight CursorLineNr cterm=bold
highlight At80thCol ctermbg=52
match At80thCol /\%>79v.*\n\@!\%<81v/
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set smartindent
set hlsearch
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
filetype plugin indent on
autocmd BufEnter * lcd %:p:h
nnoremap <LocalLeader>o :OpenIndentToCursorCol<CR>
command! OpenIndentToCursorCol call append('.', repeat(' ', getcurpos()[2] -1)) | exe "normal j" | startinsert!
