" Allow multiple buffers in the same window
set hidden

" Better command-line completion
set wildmenu

" Ensure that we are in modern vim mode, not backwards-compatible vi mode
set nocompatible
set backspace=indent,eol,start
filetype off " required for Vundle plugin manager

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" vim-c0 plugin on Github repo
Plugin 'cmugpi/vim-c0'

" install gundo
Plugin 'sjl/gundo.vim'

" NERD tree
Plugin 'scrooloose/nerdtree'

call vundle#end()

" Helpful information: cursor position in bottom right, line numbers on
" left
set ruler
set number

"Enable filetype detection and syntax hilighting
syntax on
filetype on
filetype indent on
filetype plugin on

set tabstop=2
set shiftwidth=2
set expandtab

" Indent as intelligently as vim knows how
set smartindent

" Show multicharacter commands as they are being typed
set showcmd

" Show 80 character limit line
set colorcolumn=80

" Set the command window height to 2 lines, to avoid many cases of having to
" press <Enter> to continue
set cmdheight=2

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Map ctrl-arrow to shifting buffers
map <C-Up> :bnext<ENTER>
map <C-Down> :bprevious<ENTER>

map <C-O> :NERDTree<ENTER>

nnoremap gV `[v`]

" ARM assembly syntax
let asmsyntax='armasm' 
let filetype_inc='armasm'

" Change leader key
let mapleader=","

" gundo tree
nnoremap <F2> :GundoToggle<CR>

" Search as characters are entered
set incsearch
" Highlight matches
set hlsearch

" Save session
nnoremap <leader>s :mksession<CR>

