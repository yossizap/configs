"------------------------------------------------------------
" Plugins - Run :PluginUpdate once in a while, :PluginInstall for new plugins
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
" File tree viewer
Plugin 'scrooloose/nerdtree'
" Delete/change/add parentheses/quotes/XML-tags/much more with ease - cs'"
Plugin 'tpope/vim-surround'
" Unix commands in vim
Plugin 'tpope/vim-eunuch'
" Vimium like navigation:
Plugin 'easymotion/vim-easymotion'
" Improved snipmate. <c-j> <c-k> to move backwards/forwards in snippet fields
"Plugin 'SirVer/ultisnips'
" Snippets collection
Plugin 'honza/vim-snippets'
" Comment functions - \cs and \c<space>
Plugin 'scrooloose/nerdcommenter'
" Integration with tmux navigation shortcuts
Plugin 'christoomey/vim-tmux-navigator'
"Plugin 'melonmanchan/vim-tmux-resizer'
Plugin 'vhda/verilog_systemverilog.vim'
Plugin 'jceb/vim-orgmode'
Plugin 'tpope/vim-repeat'
Plugin 'majutsushi/tagbar'
" use CTRL-A/CTRL-X to increment dates, times, and more
Plugin 'tpope/vim-speeddating'
Plugin 'itchyny/calendar.vim'
" Linting
Plugin 'dense-analysis/ale'
" :FZF [directory]
set rtp+=~/.fzf
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'
" Switch between highlighted objects with %
Plugin 'andymass/vim-matchup'
" ':Man <section> [page]'
Plugin 'vim-utils/vim-man'
" Deep learning assisted YCM fork - heavy
" Plugin 'zxqfl/tabnine-vim'
Plugin 'kergoth/vim-bitbake'
" Run :AutoFormat on file or selected text
Plugin 'vim-autoformat/vim-autoformat'
" Run :ClangFormat on file or selected text
" Plugin 'rhysd/vim-clang-format'
" Tmux syntax
Plugin 'tmux-plugins/vim-tmux'
" Kernel device tree syntax
Plugin 'goldie-lin/vim-dts'
" Mimic tmux's display-pane feature
Plugin 't9md/vim-choosewin'
" Git plugin - use :Git and then g? for help
Plugin 'tpope/vim-fugitive'
" Jump to selected text on github
Plugin 'danishprakash/vim-githubinator'
" Run selected code
Plugin 'tpope/vim-dispatch'
" FIXME Doesn't work? should let you auto complete text from other tmux planes
Plugin 'wellle/tmux-complete.vim'
" Use git style diffing(patience) in vimdiff
Plugin 'chrisbra/vim-diff-enhanced'
" Fuzzy search in file
Plugin 'dyng/ctrlsf.vim'
Plugin 'thinca/vim-logcat'
Plugin 'makerj/vim-pdf'
Plugin 'alderz/smali-vim'
Plugin 'hsanson/vim-android'
Plugin 'Speech'
" Use :ContextToggle to show the function's context
Plugin 'wellle/context.vim'
Plugin 'leafgarland/typescript-vim'
" Toggle zoom of current window within the current tab similarly to tmux's M-z
Plugin 'dhruvasagar/vim-zoom'
" Floating terminal window with Ctrl+t
Plugin 'voldikss/vim-floaterm'
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
let g:context_enabled = 1

" NERDTree settings
" Fix hjkl tmux movemenet when in NERDTree's file tree
let g:NERDTreeMapJumpPrevSibling=""
let g:NERDTreeMapJumpNextSibling=""
