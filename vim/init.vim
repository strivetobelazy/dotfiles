"                   RUN COMMANDS (rc) file for Vi[M]
"-----------------------------------------------------------------------
" Plugins.vim file containing all the plugin settings except the keymap(bottom)
" Functions.vim file contains all the functions that are used in this file

scriptencoding utf-8

source $HOME/.dotfiles/vim/plugin/plugins.vim
source $HOME/.dotfiles/vim/plugin/functions.vim

"=====================[ BASIC ]========================================"

set nocompatible "Remove back compatability for vi
filetype off
syntax enable
" filetype plugin on
filetype plugin indent on
set omnifunc=syntaxcomplete#Complete

set number "relative number is a toogle function <LocalLeaderleader>n
set showmatch "Show matching [] and {}
set formatoptions+=r formatoptions+=c
set modifiable
set backspace =indent,eol,start
set nocursorline
" set foldmethod=indent

" Syntax highlighting when needed for fast performance
set lazyredraw
set synmaxcol=128
syntax sync minlines=256
set spell spelllang=en_gb

" set clipboard+=unnamed "Compile with +clipboard block paste doent work
"to check `vim --version | grep clipboard`

set visualbell t_vb= "setting visual bell to null
set hidden  " allows you to hide buffers with unsaved changes without being prompted

" Search Settings
set hlsearch
set ignorecase
"set incsearch
set smartcase

" Swap, Undo and Backup files
if exists('$SUDO_USER')
    set nobackup
    set noswapfile
    set nowritebackup
    set noundofile
else
    let g:netrw_home=$HOME.'/.tmp/'
    set directory=$HOME/.tmp/vimswap//
    set backupdir=$HOME/.tmp/vimswap//
    set viewdir=$HOME/.tmp/views//
    set undofile "poor man's version controll
endif
if has("persistent_undo")
    set undodir=$HOME/.tmp/vimswap//
    set undofile
endif

" Remember where i left off
au BufWinLeave ?* mkview
au BufWinEnter ?* silent! loadview

set switchbuf=usetab
set path+=** "Fuzzy file search
set wildmenu "Display all matching files on tab complete
set complete+=kspell

" TAB settings "
    set autoindent
    set expandtab
    set shiftround
    set shiftwidth=4
    set smartindent
    set softtabstop=4
    set tabstop=4

set scrolloff=3                       " start scrolling 3 lines before edge of viewport
set shortmess+=A                      " ignore annoying swapfile messages
set shortmess+=I                      " no splash screen
set shortmess+=O                      " file-read message overwrites previous
set shortmess+=T                      " truncate non-file messages in middle
set shortmess+=W                      " don't echo "[w]"/"[written]" when writing
set shortmess+=a                      " use abbreviations in messages eg. `[RO]` instead of `[readonly]`
set shortmess+=o                      " overwrite file-written messages
set shortmess+=t                      " truncate file messages at start

if has('linebreak')
  set linebreak                       " wrap long lines at characters in 'breakat'
endif

" List
    set list                              " show whitespace
    set listchars=nbsp:⦸
    set listchars+=tab:⇥\                  "should be a space after this
    " set listchars+=eol:¬
    " set listchars+=trail:⋅
    set listchars+=extends:❯
    set listchars+=precedes:❮
    set listchars+=trail:␣
    set nojoinspaces                      " don't autoinsert two spaces after '.', '?', '!' for join command
    set fillchars+=vert:│
    hi VertSplit ctermbg=NONE guibg=NONE

    if has('linebreak')
    let &showbreak='⤷ '               " ARROW POINTING DOWNWARDS THEN CURVING RIGHTWARDS (U+2937, UTF-8: E2 A4 B7)
    endif

if has('linebreak')
    set breakindent
    if exists('&breakindentopt')
        set breakindentopt=shift:2
    endif
endif

if has('folding')
    if has('windows')
        set fillchars+=vert:│
    endif
    set foldmethod=indent
    set foldlevelstart=99
endif

set whichwrap=b,h,l,s,<,>,[,],~
set wildmode=longest:full,full

" Ignore certain things
set wildignore+=*.a,*.o
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.jpeg,*.png
set wildignore+=.DS_Store,.hg,.svn
set wildignore+=*~,*.swp,*.tmp

runtime macros/matchit.vim

"====================[ MAPPINGS ]====================================="
"
" Remapping the leader key
let mapleader ="\<Space>"
let maplocalleader = "\,"

let g:netrw_banner       = 0
let g:netrw_liststyle    = 3
let g:netrw_sort_options = 'i'
let g:netrw_winsize = 25
" let g:netrw_dirhistmax = 0 "store no history or bookmarks

" Remove bad Habits
" noremap <Up> <NOP>
" noremap <Down> <NOP>
" noremap <Left> <NOP>
" noremap <Right> <NOP>

" Prevent Ex-mode
nnoremap q: <Nop>
nnoremap Q <Nop>

" Using the dot . to repeat in the visualmode as well
vnoremap . :normal .<CR>

" Enable magic mode for regex
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v

" Moving around in split windows
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Easier indentation of lines/blocks without losing the visualmode selection
vnoremap < <gv
vnoremap > >gv

" Easier formatting of paragraphs
vmap Q gq
nmap Q gqap

" Multi variable change
nnoremap c* *Ncgn

" Switching tabs
nnoremap tn :Texplore<CR>

" ctags
set tags=./tags

" Spell settings for plintext  markdown and gitcommit
autocmd BufNewFile,BufReadPost *.md,*.txt,*.html,gitcommit call plugin#functions#plaintext()

" Git
autocmd Filetype gitcommit setlocal textwidth=72

" HTML
au BufReadPost *.html,htm set syntax=html

" Gnuplot
au BufNewFile,BufRead *.gpl,*.gp setf sh

"set pwd to dir of the file
autocmd BufEnter * silent! lcd %:p:h

"remove preview window ex:omnicomplete after complete
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif
