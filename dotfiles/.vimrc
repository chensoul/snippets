" Basics
set history=2000 
set nocompatible   	    " not compatible with the old-fashion vi mode
set fenc=utf-8 		    " UTF-8
set cpoptions=aABceFsmq
"             |||||||||
"             ||||||||+-- When joining lines, leave the cursor between joined lines
"             |||||||+-- When a new match is created (showmatch) pause for .5
"             ||||||+-- Set buffer options when entering the buffer
"             |||||+-- :write command updates current file name automatically add <CR> to the last line when using :@r
"             |||+-- Searching continues at the end of the match at the cursor position
"             ||+-- A backslash has no special meaning in mappings
"             |+-- :write updates alternative file name
"             +-- :read updates alternative file name
syntax on 		" syntax highlighting on
set background=dark

" General
filetype plugin indent on " load filetype plugins/indent settings
command W w !sudo tee % > /dev/null

" Vim UI
set autoread        	" Set to auto read when a file is changed from the outside
set wildmenu 	    	" Turn on the WiLd menu
set title           	" show title in console title bar
set ttyfast         	" smoother changes
set cmdheight=2     	" Height of the command bar
set lazyredraw 	    	" do not redraw while running macros
set linespace=0     	" don't insert any extra pixel lines betweens rows
set matchtime=5         " how many tenths of a second to blink matching brackets for
set hlsearch        	" Highlight search results
set incsearch       	" Makes search act like search in modern browsers
set nohlsearch 		" do not highlight searched for phrases
set nostartofline   	" leave my cursor where it was
set novisualbell    	" don't blink
set number 	    	" turn on line numbers
set numberwidth=5   	" We are good up to 99999 lines
set report=0 		" tell us when anything is changed via :...
set ruler 	        " Always show current positions along the bottom
set scrolloff=10 	" Keep 10 lines (top/bottom) for scope
set shortmess=aOstT 	" shortens messages to avoid 'press a key' prompt
set showcmd 		" show the command being typed
set showmatch 		" show matching brackets
set magic           	" For regular expressions turn magic on
set mat=2           	" How many tenths of a second to blink when matching brackets
set sidescrolloff=10 	" Keep 5 lines at the size
set laststatus=2 	" always show the status line
"set statusline='%4*%<\%m%<[%f\%r%h%w]\ [%{&ff},%{&fileencoding},%Y]%=\[Position=%l,%v,%p%%]'
set statusline='%F%m%r%h%w[%L][%{&ff},%{&fileencoding},%y]%=\[Position=%l,%v,%p%%]'
"              | | | | |  |   |      		       |  	       |  |  |
"              | | | | |  |   |                        |               |  |  +-- current % into file
"              | | | | |  |   |                        |               |  + current column
"              | | | | |  |   |                        |               +-- current line          
"              | | | | |  |   |                        +-- current syntax in square brackets
"              | | | | |  |   +-- current fileformat
"              | | | | |  +-- number of lines
"              | | | | +-- preview flag in square brackets
"              | | | +-- help flag in square brackets
"              | | +-- readonly flag in square brackets
"              | +-- rodified flag in square brackets
"              +-- full path to file in the buffer

" Text Formatting/Layout
set ai              	" Auto indent
set si              	" Smart indent
set encoding=utf8
set ffs=unix,dos,mac 
set completeopt=menuone " don't use a pop up menu for completions
set expandtab 		" no real tabs please!
set formatoptions=rq 	" Automatically insert comment leader on return, and let gq format comments
set ignorecase 		" case insensitive by default
set infercase 		" case inferred by default
set smartcase 		" if there are caps, go case-sensitive
set nowrap 	        " do not wrap line
set shiftround 		" when at 3 spaces, and I hit > ... go to 4, not 5
set shiftwidth=8 	" auto-indent amount when using cindent, >>, << and stuff like that
set softtabstop=8 	" when hitting tab or backspace, how many spaces should a tab be (see expandtab)
set tabstop=8 		" real tabs should be 4, and they will show with set list on
set backspace=eol,start,indent " Configure backspace so it acts as it should act

" Folding
set foldenable 		" Turn on folding
set foldmethod=indent 	" Fold on the indent (damn you python)
set foldlevel=100 	" Don't autofold anything (but I can still fold manually)
set foldopen=block,hor,mark,percent,quickfix,tag " what movements open folds
function SimpleFoldText() " {
	return getline(v:foldstart).' '
endfunction " }
set foldtext=SimpleFoldText() " Custom fold text function (cleaner than default)
