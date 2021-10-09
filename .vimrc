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

set cmdheight=1

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
set autowrite

" Remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

set guioptions=

colorscheme onedark
" colorscheme xoria256
" hi Folded  ctermfg=180 guifg=#dfaf87 ctermbg=234 guibg=#1c1c1c
" hi NonText ctermfg=252 guifg=#d0d0d0 ctermbg=234 guibg=#1c1c1c cterm=none gui=none

let b:ale_virtualenv_dir_names = ['venv']

let g:jedi#popup_on_dot = 0

autocmd FileType python map <leader>z :ALEFix black<CR>
