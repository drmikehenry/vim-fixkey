" Test key encodings for console Vim.

" Distributed under Vim's |license|; see |fixkey.txt| for details.

" Source this at invocation, then press keys to see what's mapped:
"
"   vim '+runtime bundle/fixkey/scripts/fixkeytest.vim'

function! MapTestKey(key)
    execute "map  <" . a:key . "> :echo '" . a:key . "'<CR>"
    execute "map! <" . a:key . ">        " . a:key . "\r"
endfunction

function! MapModifiedTestKey(key)
    call MapTestKey("C-" . a:key)
    call MapTestKey("S-" . a:key)
    call MapTestKey("C-S-" . a:key)
    call MapTestKey("M-" . a:key)
    call MapTestKey("M-C-" . a:key)
    call MapTestKey("M-S-" . a:key)
    call MapTestKey("M-C-S-" . a:key)
endfunction

function! MapTestKeyWithModifiers(key)
    call MapTestKey(a:key)
    call MapModifiedTestKey(a:key)
endfunction

let c = 'a'
while c <= 'z'
    call MapTestKey("M-" . c)
    call MapTestKey("M-" . toupper(c))
    let c = nr2char(char2nr(c) + 1)
endwhile

let n = 1
while n <= 12
    call MapTestKeyWithModifiers("F" . n)
    let n = n + 1
endwhile

call MapTestKeyWithModifiers("Up")
call MapTestKeyWithModifiers("Down")
call MapTestKeyWithModifiers("Left")
call MapTestKeyWithModifiers("Right")
call MapTestKeyWithModifiers("PageUp")
call MapTestKeyWithModifiers("PageDown")
call MapTestKeyWithModifiers("Home")
call MapTestKeyWithModifiers("End")
call MapTestKeyWithModifiers("Insert")
call MapTestKeyWithModifiers("Delete")
call MapTestKey("S-Enter")
call MapTestKey("M-Enter")
"call MapModifiedTestKey("kEnter")

" vim:tw=80:ts=4:sts=4:sw=4:et:ai
