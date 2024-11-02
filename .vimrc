"------------------------------------------------------------
" Plugins - Run :PluginUpdate once in a while, :PluginInstall for new plugins
filetype off
if empty(glob('~/.vim/autoload/plug.vim'))
silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin('~/.vim/plugged')
" File tree viewer
Plug 'scrooloose/nerdtree'
" Comment functions - \cs and \c<space>
Plug 'scrooloose/nerdcommenter'
" Delete/change/add parentheses/quotes/XML-tags/much more with ease - cs'"
Plug 'tpope/vim-surround'
" Unix commands in vim
Plug 'tpope/vim-eunuch'
" Vimium like navigation
Plug 'easymotion/vim-easymotion'
" Improved snipmate. <c-j> <c-k> to move backwards/forwards in snippet fields.
" :UltiSnipsEdit for an editable list of snippets
Plug 'sirver/ultisnips'
" " Snippets are separated from the engine
Plug 'honza/vim-snippets'
" Integration with tmux navigation shortcuts
Plug 'christoomey/vim-tmux-navigator'
" Verilog/SystemVerilog Syntax and Omni-completion
Plug 'vhda/verilog_systemverilog.vim'
" Remaps `.` in a way that plugins can tap into it
Plug 'tpope/vim-repeat'
" Browse the tags of the current file and get an overview of its structure with F3
Plug 'majutsushi/tagbar'
" use CTRL-A/CTRL-X to increment dates, times, and more
Plug 'tpope/vim-speeddating'
" Linting
Plug 'dense-analysis/ale'
" :FZF [directory]
set rtp+=~/.fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Switch between highlighted objects with %
Plug 'andymass/vim-matchup'
" ':Man <section> [page]'
Plug 'vim-utils/vim-man'
" Bitbake tool and format support
Plug 'kergoth/vim-bitbake'
" Run :AutoFormat on file or selected text
Plug 'vim-autoformat/vim-autoformat'
" Run :ClangFormat on file or selected text
Plug 'rhysd/vim-clang-format'
" Tmux syntax
Plug 'tmux-plugins/vim-tmux'
" Kernel device tree syntax
Plug 'goldie-lin/vim-dts'
" Mimic tmux's display-pane feature
Plug 't9md/vim-choosewin'
" Git plugin - use :Git and then g? for help
Plug 'tpope/vim-fugitive'
" Jump to selected text on github
Plug 'danishprakash/vim-githubinator'
" Run selected code
Plug 'tpope/vim-dispatch'
" Use git style diffing(patience) in vimdiff
Plug 'chrisbra/vim-diff-enhanced'
" Lets VIM read PDF files in text format using the pdftotext utility
Plug 'makerj/vim-pdf'
" Use :ContextToggle to show the function's context
Plug 'wellle/context.vim'
" Toggle zoom of current window within the current tab similarly to tmux's M-z
Plug 'dhruvasagar/vim-zoom'
" Floating terminal window with Ctrl+t
Plug 'voldikss/vim-floaterm'
" Distraction free vim mode, enter with :Goyo
Plug 'junegunn/goyo.vim'
" Hyperfocus-writing in Vim, enter with :Limelight exit with :Limelight!
Plug 'junegunn/limelight.vim'
" Optional deep learning assisted YCM fork - heavy
" Plug 'zxqfl/tabnine-vim'
Plug 'vim-scripts/speech'
call plug#end()

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

" the screen will not be redrawn while executing macros, registers and other commands 
" that have not been typed. Also, updating the window title is postponed. To force an
" update use :redraw. 
set lazyredraw 

" When on a buffer becomes hidden when it is abandoned. Allows reusing the same
" window and switching from an unused buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window.
set hidden

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Display line number on the current line
set number

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

" Enable mouse support for coworkers
set mouse=a

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

" Center search results (zz - vertical line centering)
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" Use easymotion in search
"map  / <Plug>(easymotion-sn)
"omap / <Plug>(easymotion-tn)
"map  n <Plug>(easymotion-next)
"map  N <Plug>(easymotion-prev)


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
set wildignore+=*.swp,*.zip,*.exe,*.class

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

" Write the contents of the file, if it has been modified, on each :next,
" :rewind, :last, :make, etc.
set autowrite

" Make a backup before overwriting a file.  Leave it around after the
" file has been successfully written.
"set backup

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
nnoremap <silent> <A-Left> :wincmd h<CR>
nnoremap <silent> <A-Down> :wincmd j<CR>
nnoremap <silent> <A-Up> :wincmd k<CR>
nnoremap <silent> <A-Right> :wincmd l<CR>

" Open NerdTree
nnoremap <F4> <esc>:NERDTreeToggle<cr>

" Open Tagbar
nnoremap <F3> <esc>:Tagbar<cr>

" Overwrite vim-tmux-navigator keybindings with Alt-*
let g:tmux_navigator_no_mappings = 0
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
nnoremap <silent> <M-\> :TmuxNavigatePrevious<cr>
nnoremap <silent> <A-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <A-j> :TmuxNavigateDown<cr>
nnoremap <silent> <A-k> :TmuxNavigateUp<cr>
nnoremap <silent> <A-l> :TmuxNavigateRight<cr>
nnoremap <silent> <A-Left> :TmuxNavigateLeft<cr>
nnoremap <silent> <A-Down> :TmuxNavigateDown<cr>
nnoremap <silent> <A-Up> :TmuxNavigateUp<cr>
nnoremap <silent> <A-Right> :TmuxNavigateRight<cr>

" Toggle spell check
nnoremap <F8> :setlocal spell! spelllang=en_us<CR>

" Escape by uncommon sequence
inoremap jj <Esc>

" Continue resizing the window with (^W)>/</+/- instead of retyping ^W+ each time(^W>^W>^W+)
" Similar to tmux C-b M-Up/Down/Left/Right
nmap          <C-W>+     <C-W>+<SID>ws
nmap          <C-W>-     <C-W>-<SID>ws
nmap          <C-W>>     <C-W>><SID>ws
nmap          <C-W><     <C-W><<SID>ws
nn <script>   <SID>ws+   <C-W>+<SID>ws
nn <script>   <SID>ws-   <C-W>-<SID>ws
nn <script>   <SID>ws>   <C-W>><SID>ws
nn <script>   <SID>ws<   <C-W><<SID>ws
nmap          <SID>ws    <Nop>

" Open the FZF navigator with Ctrl+p
nnoremap <C-p> :FZF<CR>

" Map Ctrl+f to search file content with FZF using ripgrep
nnoremap <C-f> :Rg<CR>

" Open fugitive window with Ctrl+g
noremap <C-g> :Git<Cr>

" Use tmux style pane zoom in vim windows with Ctrl+w+z
nmap <C-W>z <Plug>(zoom-toggle)

vnoremap <silent> <Leader>f :Autoformat<CR>

" Create a new float term with Ctrl + t
nnoremap <silent> <C-t> :FloatermToggle<CR>
tnoremap <silent> <C-t> <C-\><C-n>:FloatermToggle<CR>

" Save as sudo
cmap w!! SudoWrite

" Map shift+f to easymotion prefix
nnoremap <F> <Plug>(easymotion-prefix)

" Use \hjkl for easy motion direction
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)

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

" Hotkey for better confirmation based substitute. Search results are centered unless they
" are at the bottom of the page (zz - vertical line centering)
com! -nargs=* -complete=command ZZWrap let &scrolloff=999 | exec <q-args> | let &so=0
noremap <Leader>s "sy:ZZWrap .,%s///gc<Left><Left><Left><Left>

"------------------------------------------------------------
" Plugin settings
let g:org_agenda_files = ['~/org/*.org']

" FIXME Tmux complete settings
let g:tmuxcomplete#trigger = 'completefunc'

" Enhanced diff settings
" Automatically set diffexpr to patience when vim is started In diff-mode
if &diff
    let &diffexpr='EnhancedDiff#Diff("git diff", "--diff-algorithm=patience")'
endif

" Clang-format settings
" automatically detect the style file and apply the style when formatting
let g:clang_format#detect_style_file = 1

" Match-up settings
" underline matching words, don't change the color of the match under the cursor
hi MatchWord cterm=underline gui=underline

" YCM/Tabnine settings
" Disable auto completion window showing up as you type, use shift+space instead
"let g:ycm_auto_trigger = 0

" ALE settings
" Show error when hovering over highlited text
let g:ale_echo_cursor = 1
let g:ale_sign_column_always = 1
" ALE error message formatting
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
" Disable inlined ale errors
let g:ale_virtualtext_cursor=0
" Highlight error/warning line
highlight ALEErrorSign ctermbg=NONE ctermfg=Red
highlight ALEWarningSign ctermbg=NONE ctermfg=Yellow

" FZF settings
" Customize fzf colors to match vim's color scheme
let g:fzf_colors =
            \ { 'fg':      ['fg', 'Normal'],
            \ 'bg':      ['bg', 'Normal'],
            \ 'hl':      ['fg', 'Comment'],
            \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
            \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
            \ 'hl+':     ['fg', 'Statement'],
            \ 'info':    ['fg', 'PreProc'],
            \ 'border':  ['fg', 'Ignore'],
            \ 'prompt':  ['fg', 'Conditional'],
            \ 'pointer': ['fg', 'Exception'],
            \ 'marker':  ['fg', 'Keyword'],
            \ 'spinner': ['fg', 'Label'],
            \ 'header':  ['fg', 'Comment'] }

" EasyMotion settings
" keep cursor column with JK motion
let g:EasyMotion_startofline = 0 
" Similar to Vim's smartcase option -  " type `l` and match `l`&`L`
let g:EasyMotion_smartcase = 1

" Context settings
" Disable context plugin, use manually when lost
let g:context_enabled = 0

" NERDTree settings
" Fix hjkl tmux movemenet when in NERDTree's file tree
let g:NERDTreeMapJumpPrevSibling=""
let g:NERDTreeMapJumpNextSibling=""

" UltiSnip settings
" Trigger configuration
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" Lightlime settings
" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240
" Color name (:help gui-colors) or RGB color
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'
" Default: 0.5
let g:limelight_default_coefficient = 0.7
" Highlighting priority (default: 10)
"   Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1

" Goyo settings
" Enter limelight mode when entering goyo
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!
" Adjust goyo width from the default 80
let g:goyo_width=100
