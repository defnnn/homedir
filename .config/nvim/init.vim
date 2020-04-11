let g:iced_enable_default_key_mappings = v:true

let g:vim_markdown_folding_disabled = 1

let g:go_version_warning = 0

let g:pymode_options_max_line_length = 88

nmap Ee :IcedStartCljsRepl shadow-cljs app<ENTER>

nmap Ew :IcedDefJump<ENTER>

nmap <Home><Home> cse(
nmap <PageUp><PageUp> cse[
nmap <PageDown><PageDown> cse{

" Contract left
nmap <Backspace><Backspace> >(

" Expand Left
nmap <Delete><Backspace> <(

" Expand Right
nmap <Backspace><Delete> >)

" Contract right
nmap <Delete><Delete> <)

" insert at beginning of form
nmap Gf <I
" insert at end of form
nmap Fg >I

" move form up
nmap <PageDown><PageUp> <f
" move form down
nmap <PageUp><PageDown> >f

" move element up
nmap <End><Home> <e
" move element down
nmap <Home><End> >e

set nocompatible

set ruler
set nonumber
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

set shiftround smarttab
set autoindent smartindent
set showmatch

set hidden
set nonumber

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

" make uses real tabs
au FileType make set noexpandtab

" Thorfile, Rakefile, Vagrantfile and Gemfile are Ruby
au BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,Thorfile,config.ru} set ft=ruby

" These are Markdown
au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn,ronn} set ft=mkd " ft=markdown

" add json syntax highlighting
au BufNewFile,BufRead *.json set ft=javascript

" make Python follow PEP8 ( http://www.python.org/dev/peps/pep-0008/ )
au FileType python set softtabstop=4 tabstop=4 shiftwidth=4 textwidth=79

" use xoria256
set guioptions=
colorscheme xoria256
hi Folded  ctermfg=180 guifg=#dfaf87 ctermbg=234 guibg=#1c1c1c
hi NonText ctermfg=252 guifg=#d0d0d0 ctermbg=234 guibg=#1c1c1c cterm=none gui=none
