" shows the terminal title for terminal buffers
" and default title for normal buffers

augroup tabline
    autocmd!
    autocmd BufEnter * let t:currbufnr = bufnr('%')
augroup end

function! s:get_buf_name(n)
    let s = getbufvar(a:n, 'term_title')
    if !empty(s)
        return s
    endif
    if empty(bufname(a:n))
        return '[No Name]'
    endif
    return pathshorten(expand('#'.a:n.':~:.'))
endfunction

function! s:cram_str(s, maxlen)
    let l = strlen(a:s)
    if l < a:maxlen
        return a:s
    endif
    let l1 = (a:maxlen - 3) / 2
    let l2 = a:maxlen - 3 - l1
    return a:s[0:l1-1].'...'.a:s[l-l2:l-1]
endfunction

function! TabLine(maxlen)
    let maxlen = eval(a:maxlen)
    let s = ''
    for i in range(1, tabpagenr('$'))
        " select the highlighting
        let s .= i == tabpagenr()? '%#TabLineSel#': '%#TabLine#'

        " set the tab page number (for mouse clicks)
        let s .= '%'.i.'T '

        " the actual label
        let bufnum = gettabvar(i, 'currbufnr')
        if empty(bufnum)
             let bufnum = tabpagebuflist(i)[0]
        endif
        let numwins = tabpagewinnr(i, '$')
        let s .= numwins == 1? '': (numwins.' ')
        let s .= s:cram_str(s:get_buf_name(bufnum), maxlen) . ' '
        let s .= getbufvar(bufnum, '&modified')? '[+] ': ''
    endfor

    " after the last tab fill with TabLineFill
    let s .= '%#TabLineFill#%T'

    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLine#%999X[x]'
    endif

    return s
endfunction
