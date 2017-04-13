" ------------------------------------------------------------------
" Vim run command file
" ------------------------------------------------------------------
scriptencoding utf-8
set nocompatible
unlet! skip_defaults_vim
syntax on
filetype plugin indent on

set number
set relativenumber
set showmatch
set backspace=indent,eol,start

" TAB settings "
set autoindent
set expandtab
set shiftround
set shiftwidth=4
set smartindent
set softtabstop=4
set tabstop=4
set scrolloff=3
set shortmess=aIT
set nocursorline
set formatoptions+=1

set path+=**
set wildmenu

set list
set listchars=nbsp:⦸
set listchars+=tab:⇥\ 
" set listchars+=eol:¬
set listchars+=extends:❯
set listchars+=precedes:❮
set listchars+=trail:␣
set nojoinspaces
set diffopt=filler,vertical

if has('linebreak')
    set linebreak
    let &showbreak='⤷ '
endif

set visualbell t_vb=
set hidden
set autoread

" Search Settings
set hlsearch
set ignorecase
set smartcase
set incsearch

let mapleader ="\<Space>"
let maplocalleader = "\,"
vnoremap < <gv
vnoremap > >gv

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

" plugins
call plug#begin('~/.vim/bundle')
    Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'
    Plug 'neomake/neomake'
    Plug 'ervandew/supertab'
    " Plug 'metakirby5/codi.vim'
call plug#end()
"---------------------------------------------------------------------------
" My functions
augroup vimrc
    " Automatic rename of tmux window
    if exists('$TMUX') && !exists('$NORENAME')
        au BufEnter * if empty(&buftype) | call system('tmux rename-window '.expand('%:t:S')) | endif
        au VimLeave * call system('tmux set-window automatic-rename on')
    endif
augroup END

":Root | Change directory to the root of the Git repository
function! s:root()
  let root = systemlist('git rev-parse --show-toplevel')[0]
  if v:shell_error
    echo 'Not in git repo'
  else
    execute 'lcd' root
    echo 'Changed directory to: '.root
  endif
endfunction
command! Root call s:root()

" Remove extra whitespace
function! Trim_trailing()
    if search('\s\+$', 'cnw')
        :%s/\s\+$//g
    endif
endfunction
nnoremap <silent><leader>zz :call Trim_trailing()<cr>


"" <Leader>?/! | Google it / Feeling lucky
function! s:goog(pat, lucky)
  let q = '"'.substitute(a:pat, '["\n]', ' ', 'g').'"'
  let q = substitute(q, '[[:punct:] ]',
       \ '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
  call system(printf('open "https://www.google.com/search?%sq=%s"',
                   \ a:lucky ? 'btnI&' : '', q))
endfunction

nnoremap <leader>? :call <SID>goog(expand("<cWORD>"), 0)<cr>
nnoremap <leader>! :call <SID>goog(expand("<cWORD>"), 1)<cr>
xnoremap <leader>? "gy:call <SID>goog(@g, 0)<cr>gv
xnoremap <leader>! "gy:call <SID>goog(@g, 1)<cr>gv

" ----------------------------------------------------------------------------
" ?ii / ?ai | indent-object
" ?io       | strictly-indent-object
function! s:indent_len(str)
  return type(a:str) == 1 ? len(matchstr(a:str, '^\s*')) : 0
endfunction

" ----------------------------------------------------------------------------
" #gi / #gpi | go to next/previous indentation level
function! s:go_indent(times, dir)
  for _ in range(a:times)
    let l = line('.')
    let x = line('$')
    let i = s:indent_len(getline(l))
    let e = empty(getline(l))

    while l >= 1 && l <= x
      let line = getline(l + a:dir)
      let l += a:dir
      if s:indent_len(line) != i || empty(line) != e
        break
      endif
    endwhile
    let l = min([max([1, l]), x])
    execute 'normal! '. l .'G^'
  endfor
endfunction
nnoremap <silent> gi :<c-u>call <SID>go_indent(v:count1, 1)<cr>
nnoremap <silent> gpi :<c-u>call <SID>go_indent(v:count1, -1)<cr>

"---------------------------------------------------------------------------
" If buffer modified, update any 'Last modified: ' in the first 20 lines.
function! LastModified()
  if &modified
    let save_cursor = getpos(".")
    let n = min([20, line("$")])
    keepjumps exe '1,' . n . 's#^\(.\{,10}Last modified: \).*#\1' .
          \ strftime('%a %b %d, %Y  %I:%M%p') . '#e'
    call histdel('search', -1)
    call setpos('.', save_cursor)
  endif
endfun
autocmd BufWritePre * call LastModified()

"---------------------------------------------------------------------------
"Shows a list of places where TODO/FIXME/XXX is written
function! s:todo() abort
  let entries = []
  for cmd in ['git grep -niI -e TODO -e FIXME -e XXX 2> /dev/null',
            \ 'grep -rniI -e TODO -e FIXME -e XXX * 2> /dev/null']
    let lines = split(system(cmd), '\n')
    if v:shell_error != 0 | continue | endif
    for line in lines
      let [fname, lno, text] = matchlist(line, '^\([^:]*\):\([^:]*\):\(.*\)')[1:3]
      call add(entries, { 'filename': fname, 'lnum': lno, 'text': text })
    endfor
    break
  endfor

  if !empty(entries)
    call setqflist(entries)
    copen
  endif
endfunction
command! Todo call s:todo()

" ----------------------------------------------------------------------------
" Close preview window
  if exists('##CompleteDone')
    au CompleteDone * pclose
  else
    au InsertLeave * if !pumvisible() && (!exists('*getcmdwintype') || empty(getcmdwintype())) | pclose | endif
  endif

" ------------------------------------------------------------------
" commandline settings
cnoremap        <C-A> <Home>
cnoremap        <C-B> <Left>
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-F> getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"
cnoremap        <M-b> <S-Left>
cnoremap        <M-f> <S-Right>
silent! exe "set <S-Left>=\<Esc>b"
silent! exe "set <S-Right>=\<Esc>f"

"---------------------------------------------------------------------------
" Status line settings
set statusline=%<[%n]\ %F\ %m%r%y\ %=%-14.(%l,%c%V%)\ %P\ %{exists('g:loaded_fugitive')?fugitive#statusline():''}

" Toggle laststatus between 1<->2
function! Toggle_laststatus()
  if &laststatus == 2
    set laststatus=1
  elseif &laststatus == 1
    set laststatus=2
  endif
  return
endfunction

" Toggle Status line
nnoremap <silent> <leader>l :call Toggle_laststatus()<cr>

" Toggle relative numbering
function! Number_toggle()
  if(&relativenumber == 1)
    set norelativenumber
  else
    set relativenumber
  endif
endfunction

"Spelling toggle
function! Spell()
  if !&spell
    set spell spelllang=en_gb
  else
    set nospell
  endif
endfunction

" Toggle relative number "
nnoremap <silent><localleader>r :call Number_toggle()<cr>

" Toggle spell settings
nnoremap <localleader>l :call Spell()<CR>

"create and edit file
nnoremap <localleader>e :edit <C-R>=expand('%:p:h').'/'<CR>

nnoremap <silent> <Leader>h :nohl<CR>

"turn on spell cheking for filetypes
autocmd FileType latex,tex,md,markdown,gitcommit setlocal spell spelllang=en_gb
"---------------------------------------------------------------------------
" " Themeing
hi Normal ctermbg=234
hi clear SpellBad
hi SpellBad term=standout ctermfg=1 term=underline cterm=underline
hi clear SpellCap
hi SpellCap term=underline cterm=underline ctermfg=green
hi clear SpellRare
hi SpellRare term=underline cterm=underline
hi clear SpellLocal
hi SpellLocal term=underline cterm=underline

hi clear SignColumn
hi LineNr ctermfg=237
hi Comment ctermfg=243
hi Identifier cterm=bold
hi Function cterm=bold

hi StatusLineNC ctermbg=237 ctermfg=235
hi StatusLine ctermbg=243 ctermfg=235
hi VertSplit cterm=NONE
hi SpecialKey  term=bold ctermfg=237
hi Search cterm=NONE ctermfg=245 ctermbg=237
hi visual cterm=NONE ctermfg=245 ctermbg=237


"---------------------------------------------------------------------------
" Plugin setttings

"fzf settings
let g:fzf_layout = { 'down': '~35%' }
let g:fzf_history_dir = '~/.conf/fzf-history'
"maps
" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
" Advanced customization using autoload functions
inoremap <expr> <c-x><c-k> fzf#complete('cat /usr/share/dict/words')

"fzf file completion and other functions
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

nnoremap <leader><leader> :Files<cr>
nnoremap <silent> <leader>b :Buffers<cr>
nnoremap <leader>t :Tags
nnoremap <silent> <Leader>` :Marks<CR>

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

nnoremap <leader>n :bn<cr>
nnoremap <leader>p :bp<cr>
nnoremap <localleader>p <esc>:tabprevious<CR>
nnoremap <localleader>n <esc>:tabnext<CR>
nmap     <Leader>g :Gstatus<CR>gg<c-n>
nnoremap <Leader>d :Gdiff<CR>

"for fugitive
set diffopt+=vertical

"Neomake
autocmd! BufWritePost * Neomake
highlight NeomakeErrorSign ctermfg=red
highlight NeomakeErrorMsg ctermfg=227
"ctermbg=237
" let g:neomake_verbose=3
let g:neomake_error_sign = {'texthl': 'NeomakeErrorSign', 'text': '✗'}
let g:neomake_warning_sign={'texthl': 'NeomakeErrorMsg', 'text': '⚠'}
let g:neomake_message_sign = {'texthl': 'NeomakeMessageSign', 'text': '¶'}
let g:neomake_info_sign = {'texthl': 'MyInfoMsg', 'text': '☂'}

let g:neomake_c_enabled_makers = ['gcc']
let g:neomake_cpp_enabled_makers = ['gcc']
let g:neomake_fortran_enabled_makers = ['gfortran']

let g:neomake_c_gcc_maker = {
            \'args':[
            \'-Os','-g',
            \'-Wall','-Wextra','-Wno-unused-parameter','-Wno-unused-variable','-pedantic',
            \'-I.', '-I./include/.', '-I../include/.'
        \]}

let g:neomake_fortran_gfortran_maker = {
            \ 'errorformat': '%-C %#,'.'%-C  %#%.%#,'.'%A%f:%l%[.:]%c:,'.
            \ '%Z%\m%\%%(Fatal %\)%\?%trror: %m,'.'%Z%tarning: %m,'.'%-G%.%#',
            \'args':['-fsyntax-only', '-cpp', '-Wall', '-Wextra',
            \'-I.', '-I./modules/.', '-I../modules/.'
        \],
        \}
