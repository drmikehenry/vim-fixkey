" Test key encodings for console Vim.

" Distributed under Vim's |license|; see |fixkey.txt| for details.

" Source this at invocation, then press keys to see what's mapped:
"
"   vim '+runtime bundle/vim-fixkeys/scripts/fixkeytest.vim'

function! MapTestKey(key)
    execute "map  <" . a:key . "> :echo '" . a:key . "'<CR>"
    execute "map! <" . a:key . ">        " . a:key . "\r"
endfunction

function! MapTestKeyWithShifted(key)
    call MapTestKey(a:key)
    call MapTestKey("S-" . a:key)
endfunction

let c = 'a'
while c <= 'z'
    call MapTestKey("M-" . c)
    call MapTestKey("M-" . toupper(c))
    let c = nr2char(char2nr(c) + 1)
endwhile

let n = 1
while n <= 12
    call MapTestKeyWithShifted("F" . n)
    let n = n + 1
endwhile

call MapTestKeyWithShifted("Up")
call MapTestKeyWithShifted("Down")
call MapTestKeyWithShifted("Left")
call MapTestKeyWithShifted("Right")
call MapTestKeyWithShifted("PageUp")
call MapTestKeyWithShifted("PageDown")
call MapTestKeyWithShifted("Home")
call MapTestKeyWithShifted("End")
call MapTestKeyWithShifted("Insert")
call MapTestKeyWithShifted("Delete")

" vim:tw=80:ts=4:sts=4:sw=4:et:ai
