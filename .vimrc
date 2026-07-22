"------------------------------------------------------------
" Plugins - Run :PlugUpdate once in a while, :PlugInstall for new plugins
if !empty(glob('~/.vim/autoload/plug.vim'))
call plug#begin('~/.vim/plugged')
" Use explicit Alt-* mappings instead of vim-tmux-navigator's default Ctrl-* mappings.
let g:tmux_navigator_no_mappings = 1
" Comment functions - \cs and \c<space>
Plug 'preservim/nerdcommenter'
" Delete/change/add parentheses/quotes/XML-tags/much more with ease - cs'"
Plug 'tpope/vim-surround'
" Unix commands in vim
Plug 'tpope/vim-eunuch'
" Vimium like navigation
Plug 'easymotion/vim-easymotion'
" Improved snipmate. <c-j> <c-k> to move backwards/forwards in snippet fields.
" :UltiSnipsEdit for an editable list of snippets
if has('python3')
Plug 'sirver/ultisnips', { 'tag': '3.2' }
endif
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
Plug 'prabirshrestha/vim-lsp'
" Project tags and manual completion
Plug 'ludovicchabant/vim-gutentags'
Plug 'lifepillar/vim-mucomplete'
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
" Run selected code
Plug 'tpope/vim-dispatch'
" Use git style diffing(patience) in vimdiff
Plug 'chrisbra/vim-diff-enhanced'
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
" Colorschemes
Plug 'morhetz/gruvbox'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'altercation/vim-colors-solarized'
Plug 'joshdick/onedark.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'ayu-theme/ayu-vim'
Plug 'junegunn/seoul256.vim'
Plug 'nanotech/jellybeans.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'sainnhe/everforest'
Plug 'sainnhe/gruvbox-material'
Plug 'sainnhe/edge'
Plug 'sainnhe/sonokai'
Plug 'cocopon/iceberg.vim'
Plug 'rakr/vim-one'
Plug 'jacoborus/tender.vim'
Plug 'bluz71/vim-moonfly-colors'
Plug 'bluz71/vim-nightfly-colors'
Plug 'fenetikm/falcon'
" Optional deep learning assisted YCM fork - heavy
" Plug 'zxqfl/tabnine-vim'
call plug#end()
endif

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
xnoremap > >gv
xnoremap < <gv

" Minimal number of screen lines to keep above and below the cursor.
set scrolloff=1

set encoding=UTF-8
set ffs=unix,dos,mac

" Enable mouse support for coworkers
set mouse=a

"------------------------------------------------------------
" History options

call mkdir($HOME . '/.vim/undo', 'p')
call mkdir($HOME . '/.vim/swap', 'p')
set undodir=$HOME/.vim/undo
set directory^=$HOME/.vim/swap//
set undolevels=1000
set undoreload=10000
set undofile
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

" Wrap mode up/down navigation with gj and gk
nnoremap j gj
nnoremap k gk

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

" t0 - don't indent return types
" c0 - indent comment to the start of the opener
" U1 - do not ignore the indenting specified by { or u
" ks - indent after for/while/if
" (0 - When in unclosed parentheses, indent N characters from the line with the
"      unclosed parentheses
autocmd FileType c,cpp,objc,objcpp,verilog,systemverilog setlocal cindent cinoptions=b1,c0,U1,ks cinkeys+=*;

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
nnoremap Y y$

" Open Tagbar
nnoremap <F3> <esc>:Tagbar<cr>

function! s:TmuxNavigateVertical(direction) abort
    let l:before = winnr()
    if a:direction ==# 'j'
        wincmd j
    else
        wincmd k
    endif
    if winnr() != l:before
        return
    endif

    if winnr('$') > 1
        if a:direction ==# 'j'
            wincmd t
        else
            wincmd b
        endif
        return
    endif

    if !empty($TMUX) && !empty($TMUX_PANE)
        let l:socket = split($TMUX, ',')[0]
        let l:edge = a:direction ==# 'j' ? 'bottom' : 'top'
        let l:tmux_direction = a:direction ==# 'j' ? '-D' : '-U'
        let l:at_edge = system('tmux -S ' . shellescape(l:socket) . ' display-message -p -t ' . shellescape($TMUX_PANE) . ' "#{pane_at_' . l:edge . '}"')
        if v:shell_error == 0 && l:at_edge =~# '^0'
            call system('tmux -S ' . shellescape(l:socket) . ' select-pane -t ' . shellescape($TMUX_PANE) . ' ' . l:tmux_direction)
            return
        endif
    endif
endfunction

for s:key in ['<C-h>', '<C-j>', '<C-k>', '<C-l>']
    if !empty(maparg(s:key, 'n'))
        execute 'nunmap ' . s:key
    endif
    if !empty(maparg(s:key, 't'))
        execute 'tunmap ' . s:key
    endif
endfor
unlet s:key

nnoremap <silent> <M-h> :<C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :<C-U>call <SID>TmuxNavigateVertical('j')<cr>
nnoremap <silent> <M-k> :<C-U>call <SID>TmuxNavigateVertical('k')<cr>
nnoremap <silent> <M-l> :<C-U>TmuxNavigateRight<cr>
nnoremap <silent> <M-\> :<C-U>TmuxNavigatePrevious<cr>
nnoremap <silent> <A-h> :<C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <A-j> :<C-U>call <SID>TmuxNavigateVertical('j')<cr>
nnoremap <silent> <A-k> :<C-U>call <SID>TmuxNavigateVertical('k')<cr>
nnoremap <silent> <A-l> :<C-U>TmuxNavigateRight<cr>
nnoremap <silent> <A-Left> :<C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <A-Down> :<C-U>call <SID>TmuxNavigateVertical('j')<cr>
nnoremap <silent> <A-Up> :<C-U>call <SID>TmuxNavigateVertical('k')<cr>
nnoremap <silent> <A-Right> :<C-U>TmuxNavigateRight<cr>
nnoremap <silent> <Esc>h :<C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <Esc>j :<C-U>call <SID>TmuxNavigateVertical('j')<cr>
nnoremap <silent> <Esc>k :<C-U>call <SID>TmuxNavigateVertical('k')<cr>
nnoremap <silent> <Esc>l :<C-U>TmuxNavigateRight<cr>
execute "nnoremap <silent> \e[1;3B :<C-U>call <SID>TmuxNavigateVertical('j')<cr>"
execute "nnoremap <silent> \e[1;3A :<C-U>call <SID>TmuxNavigateVertical('k')<cr>"
execute "nnoremap <silent> \e[1;3D :<C-U>TmuxNavigateLeft<cr>"
execute "nnoremap <silent> \e[1;3C :<C-U>TmuxNavigateRight<cr>"
tnoremap <silent> <M-h> <C-\><C-n>:<C-U>TmuxNavigateLeft<cr>
tnoremap <silent> <M-j> <C-\><C-n>:<C-U>call <SID>TmuxNavigateVertical('j')<cr>
tnoremap <silent> <M-k> <C-\><C-n>:<C-U>call <SID>TmuxNavigateVertical('k')<cr>
tnoremap <silent> <M-l> <C-\><C-n>:<C-U>TmuxNavigateRight<cr>
tnoremap <silent> <A-Left> <C-\><C-n>:<C-U>TmuxNavigateLeft<cr>
tnoremap <silent> <A-Down> <C-\><C-n>:<C-U>call <SID>TmuxNavigateVertical('j')<cr>
tnoremap <silent> <A-Up> <C-\><C-n>:<C-U>call <SID>TmuxNavigateVertical('k')<cr>
tnoremap <silent> <A-Right> <C-\><C-n>:<C-U>TmuxNavigateRight<cr>

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
nnoremap <C-g> :Git<Cr>

" Use tmux style pane zoom in vim windows with Ctrl+w+z
nmap <C-W>z <Plug>(zoom-toggle)

vnoremap <silent> <Leader>f :Autoformat<CR>

" Create a new float term with Ctrl + t
nnoremap <silent> <C-t> :FloatermToggle<CR>
tnoremap <silent> <C-t> <C-\><C-n>:FloatermToggle<CR>

" Save as sudo
cmap w!! SudoWrite

" EasyMotion prefix
nmap <Leader><Leader> <Plug>(easymotion-prefix)

" Use \hjkl for easy motion direction
nmap <Leader>l <Plug>(easymotion-lineforward)
nmap <Leader>j <Plug>(easymotion-j)
nmap <Leader>k <Plug>(easymotion-k)
nmap <Leader>h <Plug>(easymotion-linebackward)

" TODO: Run scripts and makefiles

"------------------------------------------------------------
" Fold settings

" Don't fold something smaller than function name+brackets
set foldminlines=3

" Number of fold columns display on the left side of the screen
set foldcolumn=1

" Keep folds manual by default; syntax folds are expensive in large source files.
set foldmethod=manual

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
nnoremap <Leader>s "sy:ZZWrap .,%s///gc<Left><Left><Left><Left>

"------------------------------------------------------------
" Plugin settings
let g:org_agenda_files = ['~/org/*.org']

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
let g:ale_completion_enabled = 0
let g:ale_completion_autoimport = 1
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
command! ClangFormatFix ALEFix clang-format
command! ClangTidyFix ALEFix clangtidy

" Project completion and tags
set completeopt=menuone,noselect
if exists('+completepopup')
    set completeopt+=popup
    set completepopup=align:item,width:70,height:15,border:single,borderhighlight:Comment,highlight:Normal,close:off,resize:off
endif
let g:lsp_async_completion = 0
let g:lsp_signature_help_enabled = 1
let g:lsp_signature_help_delay = 150
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_echo_delay = 200
let g:lsp_diagnostics_float_cursor = 0
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_preview_float = 1
let g:lsp_preview_max_width = 70
let g:lsp_preview_max_height = 15
let g:lsp_popup_highlight = 'Normal'
let g:lsp_popup_borderchars = ['─', '│', '─', '│', '┌', '┐', '┘', '└']
let g:mucomplete#no_mappings = 1
let g:mucomplete#enable_auto_at_startup = 0
let g:mucomplete#chains = {
            \ 'default': ['omni', 'tags', 'keyn', 'path'],
            \ 'vim': ['cmd', 'keyn', 'path'],
            \ }
let g:gutentags_enabled = 1
let g:gutentags_define_advanced_commands = 1
let g:gutentags_cache_dir = expand('~/.cache/vim/tags')
let g:gutentags_project_root = ['.vim-project.json']
let g:gutentags_add_default_project_roots = 0
let g:gutentags_init_user_func = 'configs_project#tags_enabled'
let g:gutentags_ctags_exclude = [
            \ '.git', 'build', 'build-*', 'node_modules',
            \ '__pycache__', '.mypy_cache', '.pytest_cache', '*.egg-info',
            \ ]

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

" UltiSnip settings
if has('python3')
" Trigger configuration
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
endif

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

"------------------------------------------------------------
" Theme settings

set background=dark
set t_Co=256
if has('termguicolors')
    set termguicolors
endif
let s:theme_file = expand('~/.vim/theme.vim')
if filereadable(s:theme_file)
    execute 'source' fnameescape(s:theme_file)
else
    colorscheme molokai
endif

call configs_project#setup()

if filereadable(expand('~/.vimrc.local'))
    execute 'source' fnameescape(expand('~/.vimrc.local'))
endif
