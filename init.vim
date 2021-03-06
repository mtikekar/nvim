call plug#begin()
Plug 'altercation/vim-colors-solarized'
Plug 'ntpeters/vim-better-whitespace' " highlight and strip trailing whitespace
Plug 'mtikekar/nvim-send-to-term', {'do': ':UpdateRemotePlugins'}
Plug 'mtikekar/vim-bsv'
Plug 'dag/vim-fish'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-endwise' " insert `end` after `begin`
Plug 'rickhowe/diffchar.vim' " highlight exact differences in diff mode
Plug 'JuliaEditorSupport/julia-vim'
Plug 'lifepillar/vim-mucomplete' " manage completion sources and show matches automatically
Plug 'ap/vim-buftabline' " show buffers in tabline, use buffers not tabs
Plug 'jeetsukumaran/vim-pythonsense' " ac, af, ad text objects
Plug 'python/black' " format python files
Plug 'davidhalter/jedi-vim' " completions for python
Plug 'bfredl/nvim-miniyank' " fix clipboard=unnamedplus with block paste
call plug#end()

" use % to also go between `begin/end`. default is just () {} []
runtime! macros/matchit.vim

augroup init
    autocmd!
augroup END

" settings
let mapleader = "\<Space>"
set shell=fish
set title
set mouse=a

" solarized options
let g:solarized_termtrans = 1
let g:solarized_italic = 0
let g:solarized_contrast = "high"
set background=dark
colorscheme solarized

set expandtab tabstop=4 softtabstop=4 shiftwidth=4
set foldmethod=indent foldlevel=99 foldtext= foldignore=
set clipboard=unnamedplus " copy/paste using system clipboard
map p <Plug>(miniyank-autoput)
map P <Plug>(miniyank-autoPut)

if has("macunix")
    " gui applications don't get bash-initialized env
    let $PATH = "/usr/local/bin:" . $PATH
endif

set nofixeol " don't add eol to existing files
set undofile " presistent undo
set ruler " row/col number in statusline
set confirm " for w, wq, bd, etc., ask for confirmation instead of failing
set hidden  " abandoned buffers get hidden
" TODO: reconsider hidden and confirm

" more consistent colors for ap/vim-buftabline
hi link BufTabLineActive TabLine

" commands
command! -complete=help -nargs=? Help vert help <args>
cnoreabbrev vt vsp +term
cnoreabbrev ht split +term
" write without sudo
cmap w!! w !sudo tee > /dev/null %
command! Bd call <SID>bufDelete()

function! s:bufDelete()
    " Delete current buffer and switch to next buffer in list (or previous
    " buffer if current buffer is last in list)
    if bufnr('') == buftabline#user_buffers()[-1]
        bprevious
    else
        bnext
    endif
    bdelete #
endfunction

if has("macunix")
    function! s:terminalCwd()
        let cmd = ['/usr/sbin/lsof', '-Fn', '-a', '-d', 'cwd', '-p', b:terminal_job_pid]
        let f = systemlist(cmd)
        " last element in list f is 'n<cwd>'. Remove 'n' and return
        return strcharpart(f[-1], 1)
    endfunction
else
    function! s:terminalCwd()
        return '/proc/' . b:terminal_job_pid . '/cwd'
    endfunction
end

" key mappings
" fold
nnoremap <leader><space> za
nnoremap <silent> cd :exe 'cd ' . (&buftype ==# 'terminal'? <SID>terminalCwd() : expand('%:p:h'))<CR>
" Y like D
map Y y$
" clear search highlights
nnoremap <silent> , :nohlsearch<cr>

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

" for working inside st
if $TERM =~# '^st'
    map <F1> <Del>
    map! <F1> <Del>
    tmap <F1> <Del>
endif

" terminal options
set scrollback=10000
" enter insert mode on starting a terminal
autocmd init TermOpen * startinsert

inoremap jk <Esc>
tnoremap jk <C-\><C-n>
cnoremap jk <C-c>

" navigation
tnoremap <silent> <C-J> <C-\><C-n>:bprev<CR>
tnoremap <silent> <C-L> <C-\><C-n><C-w>w
tnoremap <silent> <C-H> <C-\><C-n><C-w>W
tnoremap <silent> <C-K> <C-\><C-n>:bnext<CR>

nnoremap <silent> <C-J> :bprev<CR>
nnoremap <silent> <C-L> <C-w>w
nnoremap <silent> <C-H> <C-w>W
nnoremap <silent> <C-K> :bnext<CR>

inoremap <silent> <C-J> <C-o>:bprev<CR>
inoremap <silent> <C-L> <C-o><C-w>w
inoremap <silent> <C-H> <C-o><C-w>W
inoremap <silent> <C-K> <C-o>:bnext<CR>

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
inoremap """ """
inoremap <expr> ' <SID>sameCompl("'")
inoremap '' '
inoremap ''' '''

highlight ExtraWhitespace ctermbg=black
" color the 81st column of wide lines
autocmd init BufRead * if &buftype !=# 'terminal' | call matchadd('ColorColumn', '\%81v', 100) | endif
set textwidth=0

function! s:bsv_set_path(srcdir)
    let pathfile = a:srcdir . '/bsvpath'
    if filereadable(pathfile)
        let path = []
        for line in readfile(pathfile)
            if line =~# '^[^$/~]'
                let line = a:srcdir . '/' . line
            endif
            call add(path, expand(line))
        endfor
        let &path = join(path, ',')
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

" julia
let g:default_julia_version = '1.0'
let g:latex_to_unicode_auto = 1

" override mapping for single quote
function! s:unmapQuotes()
    inoremap <buffer> <nowait> ' '
endfunction

autocmd init FileType verilog,systemverilog,bsv,julia call <SID>unmapQuotes()

" mucomplete options
set completeopt-=preview
set completeopt+=longest,menuone,noinsert
set shortmess+=c    " Shut off completion messages

let g:jedi#popup_on_dot = 0

let g:mucomplete#always_use_completeopt = 1
let g:mucomplete#buffer_relative_paths = 1
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#no_mappings = 1
" Tab to request completion and select+insert next suggestion
" up/down to select suggestion without inserting it
" enter to insert selected suggestion and end completion
imap <expr> <Tab> pumvisible()? "\<down>" : mucomplete#tab_complete(1)
inoremap <silent> <plug>(MUcompleteFwdKey) <right>
imap <right> <plug>(MUcompleteCycFwd)
inoremap <silent> <plug>(MUcompleteBwdKey) <left>
imap <left> <plug>(MUcompleteCycBwd)
" TODO: consider using standard keybindings if such a standard exists

command! -nargs=? -complete=file SetPyEnv call <SID>pyEnv(<f-args>)
command PyEnv py3 print(jedi_vim.current_environment)
function! s:pyEnv(...)
    if a:0 == 0
        py3 os.environ.pop("VIRTUAL_ENV", None)
    else
        call py3eval('os.environ.__setitem__("VIRTUAL_ENV", "' . a:1 . '")')
    endif
    py3 jedi_vim.current_environment = (None, None)
endfunction

autocmd init FileType python setlocal completefunc=SendComplete
let g:mucomplete#can_complete = {'python' : {'user' : { t -> SendCanComplete(t)}}}
let g:mucomplete#chains = {'python' : ['path', 'omni', 'user', 'keyn', 'dict', 'uspl']}
" run once to register the function
autocmd init FileType python call SendCanComplete('')
