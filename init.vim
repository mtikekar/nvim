call plug#begin()
Plug 'altercation/vim-colors-solarized'
Plug 'ntpeters/vim-better-whitespace'
Plug 'hkupty/iron.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'vim-scripts/L9' | Plug 'othree/vim-autocomplpop'
Plug 'mtikekar/vim-bsv'
Plug 'dag/vim-fish'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-endwise'
Plug 'rickhowe/diffchar.vim'
Plug 'zyedidia/literate.vim'
Plug 'JuliaEditorSupport/julia-vim'
call plug#end()

runtime! macros/matchit.vim

augroup init
    autocmd!
augroup END

" settings
let mapleader = "\<Space>"
let $vimrc = expand('<sfile>')
let $vim = expand('<sfile>:p:h')
set shell=fish
set title
set mouse=a

" solarized options
let g:solarized_termtrans=1
let g:solarized_italic=0
let g:solarized_contrast="high"
set background=dark
colorscheme solarized

set expandtab tabstop=4 softtabstop=4 shiftwidth=4
set foldmethod=indent foldlevel=99 foldtext= foldignore=
set clipboard=unnamedplus " copy/paste using system clipboard

set tabline=%!TabLine(30) " better titles in tabline
set undofile " presistent undo
set ruler " row/col number in statusline

" commands
command! W w
command! Q q
command! WQ wq
command! -complete=help -nargs=? H vert help <args>

" key mappings
" fold
nnoremap <leader><space> za
nnoremap <silent> cd :exe 'cd ' . (&buftype ==# 'terminal'? '/proc/'.b:terminal_job_pid.'/cwd' : expand('%:p:h'))<CR>
" Y like D
map Y y$
" clear search highlights
nnoremap <silent> , :nohlsearch<cr>
nnoremap <silent> <leader>, :ToggleWhitespace<cr>

" iron.nvim mappings
nmap cap ctrap
nmap cc 0ctr$

" show syntax information of character under cursor
function! s:syn_name(transparent, translate)
    let s = synID(line('.'), col('.'), a:transparent)
    if a:translate
        let s = synIDtrans(s)
    endif
    return synIDattr(s, 'name')
endfunction

function! s:syn_stack()
    let s = synstack(line('.'), col('.'))
    return join(map(s, 'synIDattr(v:val, "name")'), ' > ')
endfunction

map <F10> :echo printf('hi<%s> trans<%s> lo<%s>', <SID>syn_name(1,0), <SID>syn_name(0,0), <SID>syn_name(1,1))<CR>
map <leader><F10> :echo <SID>syn_stack()<CR>

" tag navigation
nmap <C-p> <C-t>
" for working inside st
if $TERM =~# '^st'
    map <F1> <Del>
    map! <F1> <Del>
    tmap <F1> <Del>
endif

" terminal options
let g:terminal_scrollback_buffer_size = 10000
autocmd init BufEnter * if &buftype ==# 'terminal' | startinsert | endif
" q to exit normal mode inside terminal. like less
autocmd init TermOpen * nnoremap <buffer> q i
tnoremap <silent> <Esc><Esc> <C-\><C-n>G:call search('^.', 'bc')<CR>
tnoremap <silent> <C-H> <C-\><C-n>:call <SID>nav_left()<CR>
tnoremap <silent> <C-J> <C-\><C-n><C-w>j
tnoremap <silent> <C-K> <C-\><C-n><C-w>k
tnoremap <silent> <C-L> <C-\><C-n>:call <SID>nav_right()<CR>

nnoremap <silent> <C-H> :call <SID>nav_left()<CR>
nnoremap <silent> <C-J> <C-w>j
nnoremap <silent> <C-K> <C-w>k
nnoremap <silent> <C-L> :call <SID>nav_right()<CR>

inoremap <silent> <C-H> <C-o>:call <SID>nav_left()<CR>
inoremap <silent> <C-J> <C-o><C-w>j
inoremap <silent> <C-K> <C-o><C-w>k
inoremap <silent> <C-L> <C-o>:call <SID>nav_right()<CR>

inoremap <Left> <Nop>
inoremap <Right> <Nop>
nnoremap <Left> <Nop>
nnoremap <Down> <Nop>
nnoremap <Up> <Nop>
nnoremap <Right> <Nop>

function! s:nav_left()
    " move one window left or if left-most, move one tab left
    let oldw = winnr()
    wincmd h
    if winnr() ==# oldw
        tabprevious
        " move to bottom-right window
        wincmd b
    endif
endfunction

function! s:nav_right()
    let oldw = winnr()
    wincmd l
    if winnr() ==# oldw
        tabnext
        wincmd t
    endif
endfunction

" Insert mappings for ( [ { ' "
" [ -> [], [[ -> [, [] -> [], ] -> ]
" ' -> '', '' -> '
function! s:isCurrChar(c)
    return getline(".")[col(".") - 1] == a:c
endfunction

function! s:sameCompl(c)
    return s:isCurrChar(a:c)? "\<Right>" : (a:c . a:c . "\<Left>")
endfunction

function! s:endCompl(e)
    return s:isCurrChar(a:e)? "\<Right>" : a:e
endfunction

function! s:genCompl(b, e)
    execute "inoremap " . a:b . " " . a:b . a:e . "<Left>"
    execute "inoremap " . a:b . a:b . " " . a:b
    execute "inoremap " . a:b . a:e . " " . a:b . a:e
    execute "inoremap <expr> " . a:e . " <SID>endCompl('" . a:e . "')"
endfunction

call s:genCompl('[', ']')
call s:genCompl('(', ')')
call s:genCompl('{', '}')
inoremap <expr> " <SID>sameCompl('"')
inoremap "" "
inoremap <expr> ' <SID>sameCompl("'")
inoremap '' '

highlight ExtraWhitespace ctermbg=black
" color the 81st column of wide lines
autocmd init BufRead * if &buftype !=# 'terminal' | call matchadd('ColorColumn', '\%81v', 100) | endif
set textwidth=0

function! s:bsv_set_path(srcdir)
    let pathfile = a:srcdir . '/bsvpath'
    if filereadable(pathfile)
        set path=
        for line in readfile(pathfile)
            if line =~# '^[^$/]'
                let line = a:srcdir . '/' . line
            endif
            execute "set path+=" . simplify(line)
        endfor
    endif
endfunction

" New BSV files use tabs, in existing files check for tabs
autocmd init BufNewFile *.bsv setlocal noet sw=2 ts=2 sts=2
autocmd init BufReadPost *.bsv if search('^\t', 'nw') | setlocal noet sw=2 ts=2 sts=2 | endif
autocmd init FileType bsv call <SID>bsv_set_path(expand('<afile>:p:h'))

autocmd init BufNewFile *.* call <SID>read_template(expand("<afile>:e"))
function! s:read_template(ext)
    " read in template files and  parse special text
    silent! exe '0r $vim/templates/template.'.a:ext
    %s/\v:VIM_EVAL:(.{-}):END_EVAL:/\=eval(submatch(1))/ge
endfunction
