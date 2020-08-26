execute pathogen#infect()

set nocompatible

set ruler
set number
syntax on

" Set encoding
set encoding=utf-8

" Whitespace stuff
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Tab completion
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,*.class,.svn,vendor/gems/*

" Status bar
set laststatus=2

set backspace=indent,eol,start

filetype plugin indent on

set modeline
set modelines=10

set noshowcmd
set noshowmode

set cmdheight=10

set shiftround smarttab
set autoindent smartindent
set showmatch

set hidden

set history=1000
set undolevels=1000
set title
set visualbell
set noerrorbells
set t_vb=

set scrolloff=3
set nojoinspaces

set nobackup
set noswapfile

" Remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

set guioptions=

colorscheme xoria256
hi Folded  ctermfg=180 guifg=#dfaf87 ctermbg=234 guibg=#1c1c1c
hi NonText ctermfg=252 guifg=#d0d0d0 ctermbg=234 guibg=#1c1c1c cterm=none gui=none

let g:go_fmt_command = "goimports"
let g:go_doc_max_height = 50
let g:go_doc_popup_window = 1
let g:go_def_reuse_buffer = 1

let g:go_metalinter_autosave_enabled = ['vet', 'golint']
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']

map X :bprevious<CR>
map C :bnext<CR>

autocmd FileType go nmap B <Plug>(go-build)
autocmd FileType go nmap T <Plug>(go-test)
autocmd FileType go nmap K <Plug>(go-doc)
autocmd FileType go nmap I <Plug>(go-info)
autocmd FileType go nmap L <Plug>(go-metalinter)
autocmd FileType go nmap S <Plug>(go-alternate-edit)
