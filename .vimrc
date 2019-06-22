"------------------------------------------------------------
" Plugins - Run :PluginUpdate once in a while, :PluginInstall for new plugins
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'snipMate'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
"Plugin 'scrooloose/Syntastic'
Plugin 'easymotion/vim-easymotion'
Plugin 'garbas/vim-snipmate'
Plugin 'scrooloose/nerdcommenter'
"Plugin 'davidhalter/jedi-vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'vhda/verilog_systemverilog.vim'
Plugin 'jceb/vim-orgmode'
Plugin 'tpope/vim-repeat'
Plugin 'taglist.vim'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-speeddating'
Plugin 'itchyny/calendar.vim'
Plugin 'SyntaxRange'
" Switch between highlighted objects with %
Plugin 'andymass/vim-matchup'
" ':Man <section> [page]'
Plugin 'vim-utils/vim-man'
call vundle#end()

"------------------------------------------------------------
" Misc options

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on

" When on a buffer becomes hidden when it is abandoned. Allows reusing the same
" window and switching from an unused buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window.
set hidden

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Show the line number relative to the current line and the line number of 
" the current line
set relativenumber

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Prevent automatically leaving indentation mode after a single indentation
vmap > >gv
vmap < <gv

" Minimal number of screen lines to keep above and below the cursor.
set scrolloff=1

set encoding=UTF-8
set term=xterm-256color
set ffs=unix,dos,mac

"------------------------------------------------------------
" History options

set undodir=$HOME/.vim/undo
set undolevels=1000
set undoreload=10000
set undofile
set noswapfile
set history=1000

"------------------------------------------------------------
" Status line options

" Always display the status line, even if only one window is displayed
set laststatus=2

" Set the command window height to 1 lines
set cmdheight=1

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Show partial commands in the last line of the screen
set showcmd

"------------------------------------------------------------
" Search options

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" While typing a search command, show where the pattern, as it was typed
" so far, matches.
set incsearch

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

set ic
set scs
set is
set autoread
set nowb
set lbr
set tw=500

" Wrap mode up/down navigation with gj and gk
map j gj
map k gk

"------------------------------------------------------------
" Theme settings

set background=dark
set t_Co=256
colorscheme molokai

"------------------------------------------------------------
" Syntax-related settings

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. 
set autoindent

" Do smart autoindenting when starting a new line.
set smartindent

" Highlight matching bracket
"set showmatch
"set matchtime=3

" Maximum line length
set textwidth=90

" Add a comma separated list of screen columns as a max textwidth reminder
set colorcolumn=+1

" 4 spaces instead of tabs
set expandtab
set smarttab
set shiftwidth=4
set softtabstop=4

" Get the amount of indent for line {lnum} according the C indenting rules
set cindent

" t0 - don't indent return types
" c0 - indent comment to the start of the opener
" U1 - do not ignore the indenting specified by { or u
" ks - indent after for/while/if
" (0 - When in unclosed parentheses, indent N characters from the line with the 
"      unclosed parentheses
set cino=b1,c0,U1,ks

" C - Automatically re-indent once the user is done typing the line (on ';')
set cink+=*;

" Disable text wrap
set nowrap

set formatoptions=croqn1

" Automatically add closing brackets after pressing enter similarly to VS
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

"------------------------------------------------------------
" Directory browser settings

" zsh-like path auto-completion
set wildmenu
set wildmode=full

" Case is ignored when completing file names and directories.
set wildignorecase

" Ignore temp/binary files
set wildignore=*.a,*.o,*.pyc,*.pyo,*~

"------------------------------------------------------------
" Window/split settings

" When on, splitting a window will put the new window right of the
" current one.
set splitright

" When on, all the windows are automatically made the same size after
" splitting or closing a window.
set equalalways

"------------------------------------------------------------
" File settings

" Remember position when reopening file

" Write the contents of the file, if it has been modified, on each :next, 
" :rewind, :last, :make, etc.
set autowrite

" Make a backup before overwriting a file.  Leave it around after the
" file has been successfully written.
set backup

"------------------------------------------------------------
" Key mappings

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
nmap Y y$

" Switch between splits with alt + hjkl
nnoremap <silent> <A-h> :wincmd h<CR>
nnoremap <silent> <A-j> :wincmd j<CR>
nnoremap <silent> <A-k> :wincmd k<CR>
nnoremap <silent> <A-l> :wincmd l<CR>

" Open NerdTree
nnoremap <F4> <esc>:NERDTreeToggle<cr>

" Save as sudo
cmap w!! w !sudo tee % > /dev/null

" Overwrite vim-tmux-navigator keybindings with Alt-*
let g:tmux_navigator_no_mappings = 0
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
nnoremap <silent> <M-\> :TmuxNavigatePrevious<cr>

" Toggle spell check
nnoremap <F8> :setlocal spell! spelllang=en_us<CR>

" Escape by uncommon sequence
inoremap jj <Esc>

" TODO: Run scripts and makefiles

"------------------------------------------------------------
" Fold settings

" Don't fold something smaller than function name+brackets
set foldminlines=3

" Number of fold columns display on the left side of the screen
set foldcolumn=1

" Folds are defined by syntax highlighting 
set foldmethod=syntax

" Ensure all folds are open up to a ridiculous nesting level
set foldlevel=100

"------------------------------------------------------------
" Scripts
func! WordProcessorMode()
    setlocal textwidth=80
    setlocal smartident
    setlocal spell spelllang=en_us
    setlocal noexpandtab
endfu

com! WP call WordProcessorMode()

"------------------------------------------------------------
" Plugin settings
let g:org_agenda_files = ['~/org/*.org']

" Match-up settings
" underline matching words, don't change the color of the match under the cursor
hi MatchWord ctermfg=lightred guifg=lightred cterm=underline gui=underline
hi MatchParenCur cterm=underline gui=underline
hi MatchWordCur cterm=underline gui=underline
