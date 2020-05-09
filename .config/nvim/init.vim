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

let g:iced#hook = {
    \ 'connected': {'type': 'command',
    \               'exec': 'IcedStartCljsRepl shadow-cljs app'}
    \ }

colorscheme xoria256

hi Folded  ctermfg=180 guifg=#dfaf87 ctermbg=234 guibg=#1c1c1c
hi NonText ctermfg=252 guifg=#d0d0d0 ctermbg=234 guibg=#1c1c1c cterm=none gui=none
