function! DoRemoteFn(info)
    UpdateRemotePlugins
endfunction
let DoRemote = function('DoRemoteFn')

call plug#begin()
Plug 'altercation/vim-colors-solarized'
Plug 'ntpeters/vim-better-whitespace'
Plug 'bfredl/nvim-ipy', {'do': DoRemote}
Plug 'Shougo/deoplete.nvim', {'do': DoRemote}
Plug 'Shougo/neoinclude.vim'
Plug 'mtikekar/vim-bsv'
Plug 'dag/vim-fish'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-endwise'
Plug 'rickhowe/diffchar.vim'
Plug 'jiangmiao/auto-pairs'
call plug#end()

runtime! macros/matchit.vim

augroup init
    autocmd!
augroup END

" settings
let mapleader = "\<Space>"
let $vimrc = expand('<sfile>')
let $vim = expand('<sfile>:p:h')
let g:deoplete#enable_at_startup = 1
set shell=fish
set title

" solarized options
let g:solarized_termtrans=1
let g:solarized_italic=0
let g:solarized_contrast="high"
set background=dark
colorscheme solarized

set expandtab tabstop=4 softtabstop=4 shiftwidth=4
set foldmethod=indent foldlevel=99 foldtext= foldignore=
set clipboard=unnamedplus " copy/paste using system clipboard

set tabline=%!TabLine() " better titles in tabline
set undofile " presistent undo
set ruler " row/col number in statusline

" auto-pair mappings
let g:AutoPairsMapBS = 0
let g:AutoPairsMapCh = 0
let g:AutoPairsMapCR = 0
let g:AutoPairsMapSpace = 0
let g:AutoPairsShortcutToggle = ''
let g:AutoPairsShortcutFastWrap = ''
let g:AutoPairsShortcutJump = ''

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

map <F10> :echo 'hi<'.<SID>syn_name(1, 0).'> trans<'.<SID>syn_name(0, 0).'> lo<'.<SID>syn_name(1, 1).'>'<CR>
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
tnoremap <silent> <Esc> <C-\><C-n>G:call search('^.', 'bc')<CR>
tnoremap <Esc><Esc> <Esc>
tnoremap <silent> <S-Down> <C-\><C-n>:tabnew<CR>
tnoremap <silent> <C-Left> <C-\><C-n>:call <SID>nav_left()<CR>
tnoremap <silent> <C-Down> <C-\><C-n><C-w>j
tnoremap <silent> <C-Up> <C-\><C-n><C-w>k
tnoremap <silent> <C-Right> <C-\><C-n>:call <SID>nav_right()<CR>

nnoremap <silent> <S-Down> :tabnew<CR>
nnoremap <silent> <C-Left> :call <SID>nav_left()<CR>
nnoremap <silent> <C-Down> <C-w>j
nnoremap <silent> <C-Up> <C-w>k
nnoremap <silent> <C-Right> :call <SID>nav_right()<CR>

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

highlight ExtraWhitespace ctermbg=black
" color the 81st column of wide lines
autocmd init BufRead * if &buftype !=# 'terminal' | call matchadd('ColorColumn', '\%81v', 100) | endif

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
