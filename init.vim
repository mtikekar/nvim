call plug#begin()
Plug 'altercation/vim-colors-solarized'
call plug#end()

augroup init
    autocmd!
augroup end

let $vim = '~/.config/nvim'
let $vimrc = $vim . '/init.vim'

" solarized options
let g:solarized_termtrans=1
let g:solarized_italic=0
let g:solarized_contrast="high"
set background=dark
colorscheme solarized

set expandtab tabstop=4 softtabstop=4 shiftwidth=4
set foldmethod=indent foldlevel=99 foldtext= foldignore=
nnoremap <leader><space> za

" for working inside st
map <F1> <Del>
map! <F1> <Del>

" terminal options
let g:terminal_scrollback_buffer_size = 10000
tnoremap <Esc> <C-\><C-n>
autocmd init BufEnter * if &buftype ==# 'terminal' | startinsert | endif
tnoremap <silent> <S-Down> <C-\><C-n>:tabnew<CR>
tnoremap <silent> <C-Left> <C-\><C-n>:call <SID>winLeft()<CR>
tnoremap <silent> <C-Down> <C-\><C-n><C-w>j
tnoremap <silent> <C-Up> <C-\><C-n><C-w>k
tnoremap <silent> <C-Right> <C-\><C-n>:call <SID>winRight()<CR>

nnoremap <silent> <S-Down> :tabnew<CR>
nnoremap <silent> <C-Left> :call <SID>winLeft()<CR>
nnoremap <silent> <C-Down> <C-w>j
nnoremap <silent> <C-Up> <C-w>k
nnoremap <silent> <C-Right> :call <SID>winRight()<CR>

function! s:winLeft()
    " move one window left or if left-most, move one tab left
    let oldw = winnr()
    wincmd h
    if winnr() ==# oldw
        tabprevious
        " move to bottom-right window
        wincmd b
    endif
endfunction

function! s:winRight()
    let oldw = winnr()
    wincmd l
    if winnr() ==# oldw
        tabnext
        wincmd t
    endif
endfunction

" better titles in tabline
set tabline=%!TabLine()

nnoremap <silent> cd :exe 'cd ' . (&buftype ==# 'terminal'? '/proc/'.b:terminal_job_pid.'/cwd' : expand('%:p:h'))<CR>
command! W w
command! Q q
command! WQ wq
