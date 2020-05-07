" Specify a directory for plugins
call plug#begin('~/.config/nvim/plugged')

" One of following
Plug 'ctrlpvim/ctrlp.vim'

" Requires
Plug 'guns/vim-sexp',    {'for': 'clojure'}
Plug 'liquidz/vim-iced', {'for': 'clojure'}

call plug#end()

" Enable vim-iced's default key mapping
" This is recommended for newbies
let g:iced_enable_default_key_mappings = v:true
