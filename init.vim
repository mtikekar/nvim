call plug#begin()
Plug 'altercation/vim-colors-solarized'
call plug#end()

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
tnoremap <Esc> <C-\><C-n>
autocmd BufEnter * if &buftype ==# 'terminal' | startinsert | endif
tnoremap <S-Down> <C-\><C-n>:tabnew<CR>
tnoremap <C-Left> <C-\><C-n>:call WinLeft()<CR>
tnoremap <C-Down> <C-\><C-n><C-w>j
tnoremap <C-Up> <C-\><C-n><C-w>k
tnoremap <C-Right> <C-\><C-n>:call WinRight()<CR>

nnoremap <S-Down> :tabnew<CR>
nnoremap <C-Left> :call WinLeft()<CR>
nnoremap <C-Down> <C-w>j
nnoremap <C-Up> <C-w>k
nnoremap <C-Right> :call WinRight()<CR>

function! WinLeft()
    " move one window left or if left-most, move one tab left
    let oldw = winnr()
    wincmd h
    if winnr() ==# oldw
        tabprevious
        " move to bottom-right window
        wincmd b
    endif
endfunction

function! WinRight()
    let oldw = winnr()
    wincmd l
    if winnr() ==# oldw
        tabnext
        wincmd t
    endif
endfunction

" better titles in tabline
set tabline=%!TabLine()
