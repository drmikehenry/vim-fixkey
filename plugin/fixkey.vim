" Fix key encodings for console Vim.

" Distributed under Vim's |license|; see |fixkey.txt| for details.

" Neovim does not require Fixkey.  If Neovim is detected, quietly bail out
" to smooth the user experience for users that switch between Vim and Neovim.
if exists("loaded_fixkey") || has('nvim')
    finish
endif
let loaded_fixkey = 1

" No need to map keys for gvim.
if has("gui_running")
    finish
endif

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

if !exists('g:Fixkey_useTimestamps')
    let g:Fixkey_useTimestamps = 0
endif

function! Fixkey_timestamp(message)
    if g:Fixkey_useTimestamps
        " This results in a `stat()` system call with a filename
        " based on the message, allowing timing measurements via
        " `strace -tt` on Linux.
        call filereadable('FIXKEY_TIMESTAMP_' . a:message)
    endif
endfunction

function! Fixkey_setKey(key, keyCode)
    execute "set " . a:key . "=" . a:keyCode
endfunction

function! Fixkey_mapKey(key, value)
    execute "map  " . a:key . " " . a:value
    execute "map! " . a:key . " " . a:value
endfunction

let g:Fixkey_numSpareKeys = 50
let g:Fixkey_spareKeysUsed = 0

" Allocate a new key, set it to use the passed-in keyCode, then map it to
" the passed-in key.
" New keys are taken from <F13> through <F37> and <S-F13> through <S-F37>,
" for a total of 50 keys.
function! Fixkey_setNewKey(key, keyCode)
    if g:Fixkey_spareKeysUsed >= g:Fixkey_numSpareKeys
        echohl WarningMsg
        echomsg "Unable to map " . a:key . ": ran out of spare keys"
        echohl None
        return
    endif
    let fn = g:Fixkey_spareKeysUsed
    let half = g:Fixkey_numSpareKeys / 2
    let shift = ""
    if fn >= half
        let fn -= half
        let shift = "S-"
    endif
    let newKey = "<" . shift . "F" . (13 + fn) . ">"
    call Fixkey_setKey(newKey, a:keyCode)
    call Fixkey_mapKey(newKey, a:key)
    let g:Fixkey_spareKeysUsed += 1
endfunction

function! Fixkey_setMetaNumbers()
    let c = '0'
    while c <= '9'
        call Fixkey_setKey("<M-" .  c . ">", "\e" . c)
        let c = nr2char(char2nr(c) + 1)
    endwhile
endfunction

function! Fixkey_resetMetaNumbers()
    let c = '0'
    while c <= '9'
        call Fixkey_setKey("<M-" .  c . ">", nr2char(char2nr(c)  + 0x80))
        let c = nr2char(char2nr(c) + 1)
    endwhile
endfunction

function! Fixkey_setMetaShiftNumbers()
    for c in split('!@#$%^&*()', '\zs')
        if c == '@'
            " For some reason, M-@ is special in console Vim.
            " See https://github.com/vim/vim/issues/5759 for some details.
            call Fixkey_setNewKey("<M-" . c . ">", "\e" . c)
        else
            call Fixkey_setKey("<M-" . c . ">", "\e" . c)
        endif
        " On XTerm with modifyOtherKeys in use, keys like <M-!> are recognized
        " as <M-S-!> (with a redundant shift modifier).  Map these back to
        " their canonical form.
        execute 'map <m-s-' . c . '> <m-' . c . '>'
        execute 'map! <m-s-' . c . '> <m-' . c . '>'
    endfor
endfunction

function! Fixkey_resetMetaShiftNumbers()
    for c in split('!@#$%^&*()', '\zs')
        call Fixkey_setKey("<M-" . c . ">", nr2char(char2nr(c)  + 0x80))
    endfor
endfunction

function! Fixkey_setMetaLetters()
    let c = 'a'
    while c <= 'z'
        let uc = toupper(c)
        call Fixkey_setKey("<M-" .  c . ">", "\e" . c)
        " Since many keycodes have "\eO" in them, we can't use "\eO" for <M-O>.
        if uc != 'O'
            call Fixkey_setKey("<M-" . uc . ">", "\e" . uc)
        endif
        let c = nr2char(char2nr(c) + 1)
    endwhile
endfunction

function! Fixkey_resetMetaLetters()
    let c = 'a'
    while c <= 'z'
        let uc = toupper(c)
        call Fixkey_setKey("<M-" .  c . ">", nr2char(char2nr(c)  + 0x80))
        if uc != 'O'
            call Fixkey_setKey("<M-" . uc . ">", nr2char(char2nr(uc) + 0x80))
        endif
        let c = nr2char(char2nr(c) + 1)
    endwhile
endfunction

function! Fixkey_unsetKey(key)
    try
        execute "set <" . a:key . ">="
    catch /E518/
        " Ignore unknown keys.
    endtry
endfunction

function! Fixkey_unsetFunctionKeys()
    let n = 1
    while n <= 37
        if n <= 4
            call Fixkey_unsetKey("xF" . n)
        endif
        if n <= 12
            call Fixkey_unsetKey("S-F" . n)
        endif
        call Fixkey_unsetKey("F" . n)
        let n = n + 1
    endwhile
endfunction

function! Fixkey_setXtermF1toF4()
    call Fixkey_setKey("<F1>", "\e[1;*P")
    call Fixkey_setKey("<F2>", "\e[1;*Q")
    call Fixkey_setKey("<F3>", "\e[1;*R")
    call Fixkey_setKey("<F4>", "\e[1;*S")
endfunction

function! Fixkey_setVt100ExtraF1toF4()
    call Fixkey_setKey("<xF1>", "\eO*P")
    call Fixkey_setKey("<xF2>", "\eO*Q")
    call Fixkey_setKey("<xF3>", "\eO*R")
    call Fixkey_setKey("<xF4>", "\eO*S")
endfunction

function! Fixkey_setXtermFunctionKeys()
    call Fixkey_setXtermF1toF4()
    call Fixkey_setVt100ExtraF1toF4()
    call Fixkey_setKey("<F5>",  "\e[15;*~")
    call Fixkey_setKey("<F6>",  "\e[17;*~")
    call Fixkey_setKey("<F7>",  "\e[18;*~")
    call Fixkey_setKey("<F8>",  "\e[19;*~")
    call Fixkey_setKey("<F9>",  "\e[20;*~")
    call Fixkey_setKey("<F10>", "\e[21;*~")
    call Fixkey_setKey("<F11>", "\e[23;*~")
    call Fixkey_setKey("<F12>", "\e[24;*~")
endfunction

function! Fixkey_setXtermHomeEnd()
    call Fixkey_setKey("<Home>",  "\e[1;*H")
    call Fixkey_setKey("<End>",   "\e[1;*F")
endfunction

function! Fixkey_setVt100ExtraHomeEnd()
    call Fixkey_setKey("<xHome>", "\eO*H")
    call Fixkey_setKey("<xEnd>",  "\eO*F")
endfunction

function! Fixkey_setXtermArrows()
    call Fixkey_setKey("<Up>",     "\e[1;*A")
    call Fixkey_setKey("<Down>",   "\e[1;*B")
    call Fixkey_setKey("<Left>",   "\e[1;*D")
    call Fixkey_setKey("<Right>",  "\e[1;*C")
endfunction

function! Fixkey_setVt100ExtraArrows()
    " Oddly, Vim sets <Up> to \eO*A and <xUp> to \e[1;*A, which seems
    " backward compared to <F1>=\e[1;*P and <xF1>=\eO*P.  This seems
    " to cause trouble with Konsole's use of these arrow keys.  Switching
    " to the vt100-compatible keycodes on <xArrows> allows Konsole
    " to use these codes directly.
    call Fixkey_setKey("<xUp>",    "\eO*A")
    call Fixkey_setKey("<xDown>",  "\eO*B")
    call Fixkey_setKey("<xLeft>",  "\eO*D")
    call Fixkey_setKey("<xRight>", "\eO*C")
endfunction

function! Fixkey_setXtermNavigationKeys()
    call Fixkey_setXtermHomeEnd()
    call Fixkey_setVt100ExtraHomeEnd()
    call Fixkey_setXtermArrows()
    call Fixkey_setVt100ExtraArrows()
endfunction

function! Fixkey_setXtermKeys()
    call Fixkey_setMetaNumbers()
    call Fixkey_setMetaShiftNumbers()
    call Fixkey_setMetaLetters()
    call Fixkey_setXtermFunctionKeys()
    call Fixkey_setXtermNavigationKeys()

    " In case this is actually konsole:
    call Fixkey_setNewKey("<S-Enter>", "\eOM")
    " For both xterm and konsole.
    call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setGnomeTerminalKeys()
    call Fixkey_setMetaNumbers()
    call Fixkey_setMetaShiftNumbers()
    call Fixkey_setMetaLetters()
    call Fixkey_setXtermFunctionKeys()
    call Fixkey_setXtermNavigationKeys()
    " Can't get this to work:
    " call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setKonsoleKeys()
    call Fixkey_setMetaNumbers()
    call Fixkey_setMetaShiftNumbers()
    call Fixkey_setMetaLetters()
    call Fixkey_setXtermFunctionKeys()
    call Fixkey_setXtermNavigationKeys()
    call Fixkey_setNewKey("<S-Enter>", "\eOM")
    call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setLinuxKeys()
    call Fixkey_setMetaNumbers()
    call Fixkey_setMetaShiftNumbers()
    call Fixkey_setMetaLetters()
    call Fixkey_setKey("<F1>",  "\e[[A")
    call Fixkey_setKey("<F2>",  "\e[[B")
    call Fixkey_setKey("<F3>",  "\e[[C")
    call Fixkey_setKey("<F4>",  "\e[[D")
    call Fixkey_setKey("<F5>",  "\e[[E")
    call Fixkey_setKey("<F6>",  "\e[17~")
    call Fixkey_setKey("<F7>",  "\e[18~")
    call Fixkey_setKey("<F8>",  "\e[19~")
    call Fixkey_setKey("<F9>",  "\e[20~")
    call Fixkey_setKey("<F10>", "\e[21~")
    call Fixkey_setKey("<F11>", "\e[23~")
    call Fixkey_setKey("<F12>", "\e[24~")
    call Fixkey_setNewKey("<S-F1>", "\e[25~")
    call Fixkey_setNewKey("<S-F2>", "\e[26~")
    call Fixkey_setNewKey("<S-F3>", "\e[28~")
    call Fixkey_setNewKey("<S-F4>", "\e[29~")
    call Fixkey_setNewKey("<S-F5>", "\e[31~")
    call Fixkey_setNewKey("<S-F6>", "\e[32~")
    call Fixkey_setNewKey("<S-F7>", "\e[33~")
    call Fixkey_setNewKey("<S-F8>", "\e[34~")
    call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setPuttyF1toF12()
    call Fixkey_setKey("<F1>",  "\e[11~")
    call Fixkey_setKey("<F2>",  "\e[12~")
    call Fixkey_setKey("<F3>",  "\e[13~")
    call Fixkey_setKey("<F4>",  "\e[14~")
    call Fixkey_setKey("<F5>",  "\e[15~")
    call Fixkey_setKey("<F6>",  "\e[17~")
    call Fixkey_setKey("<F7>",  "\e[18~")
    call Fixkey_setKey("<F8>",  "\e[19~")
    call Fixkey_setKey("<F9>",  "\e[20~")
    call Fixkey_setKey("<F10>", "\e[21~")
    call Fixkey_setKey("<F11>", "\e[23~")
    call Fixkey_setKey("<F12>", "\e[24~")
endfunction

function! Fixkey_setPuttyShiftF3toF10()
    call Fixkey_setNewKey("<S-F3>",  "\e[25~")
    call Fixkey_setNewKey("<S-F4>",  "\e[26~")
    call Fixkey_setNewKey("<S-F5>",  "\e[28~")
    call Fixkey_setNewKey("<S-F6>",  "\e[29~")
    call Fixkey_setNewKey("<S-F7>",  "\e[31~")
    call Fixkey_setNewKey("<S-F8>",  "\e[32~")
    call Fixkey_setNewKey("<S-F9>",  "\e[33~")
    call Fixkey_setNewKey("<S-F10>", "\e[34~")
endfunction

function! Fixkey_setPuttyMetaF1toF12()
    call Fixkey_setNewKey("<M-F1>",  "\e\e[11~")
    call Fixkey_setNewKey("<M-F2>",  "\e\e[12~")
    call Fixkey_setNewKey("<M-F3>",  "\e\e[13~")
    call Fixkey_setNewKey("<M-F4>",  "\e\e[14~")
    call Fixkey_setNewKey("<M-F5>",  "\e\e[15~")
    call Fixkey_setNewKey("<M-F6>",  "\e\e[17~")
    call Fixkey_setNewKey("<M-F7>",  "\e\e[18~")
    call Fixkey_setNewKey("<M-F8>",  "\e\e[19~")
    call Fixkey_setNewKey("<M-F9>",  "\e\e[20~")
    call Fixkey_setNewKey("<M-F10>", "\e\e[21~")
    call Fixkey_setNewKey("<M-F11>", "\e\e[23~")
    call Fixkey_setNewKey("<M-F12>", "\e\e[24~")
endfunction

function! Fixkey_setPuttyMetaShiftF3toF10()
    call Fixkey_setNewKey("<M-S-F3>",  "\e\e[25~")
    call Fixkey_setNewKey("<M-S-F4>",  "\e\e[26~")
    call Fixkey_setNewKey("<M-S-F5>",  "\e\e[28~")
    call Fixkey_setNewKey("<M-S-F6>",  "\e\e[29~")
    call Fixkey_setNewKey("<M-S-F7>",  "\e\e[31~")
    call Fixkey_setNewKey("<M-S-F8>",  "\e\e[32~")
    call Fixkey_setNewKey("<M-S-F9>",  "\e\e[33~")
    call Fixkey_setNewKey("<M-S-F10>", "\e\e[34~")
endfunction

function! Fixkey_setPuttyCtrlArrows()
    call Fixkey_setNewKey("<C-Up>",    "\eOA")
    call Fixkey_setNewKey("<C-Down>",  "\eOB")
    call Fixkey_setNewKey("<C-Left>",  "\eOD")
    call Fixkey_setNewKey("<C-Right>", "\eOC")
endfunction

function! Fixkey_setPuttyMetaArrows()
    call Fixkey_setNewKey("<M-Up>",    "\e\e[A")
    call Fixkey_setNewKey("<M-Down>",  "\e\e[B")
    call Fixkey_setNewKey("<M-Left>",  "\e\e[D")
    call Fixkey_setNewKey("<M-Right>", "\e\e[C")
endfunction

function! Fixkey_setPuttyMetaCtrlArrows()
    call Fixkey_setNewKey("<M-C-Up>",    "\e\eOA")
    call Fixkey_setNewKey("<M-C-Down>",  "\e\eOB")
    call Fixkey_setNewKey("<M-C-Left>",  "\e\eOD")
    call Fixkey_setNewKey("<M-C-Right>", "\e\eOC")
endfunction

function! Fixkey_setPuttyMetaHomeEnd()
    call Fixkey_setNewKey("<M-Home>",    "\e\e[1~")
    call Fixkey_setNewKey("<M-End>",     "\e\e[4~")
endfunction

function! Fixkey_setPuttyKeys()
    call Fixkey_unsetFunctionKeys()
    call Fixkey_setMetaNumbers()
    call Fixkey_setMetaShiftNumbers()
    call Fixkey_setMetaLetters()
    call Fixkey_setPuttyF1toF12()
    call Fixkey_setPuttyShiftF3toF10()
    call Fixkey_setPuttyMetaF1toF12()
    call Fixkey_setPuttyMetaShiftF3toF10()
    call Fixkey_setPuttyCtrlArrows()
    call Fixkey_setPuttyMetaArrows()
    call Fixkey_setPuttyMetaCtrlArrows()
    call Fixkey_setPuttyMetaHomeEnd()
    call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setPuttyScoF1toF12()
    call Fixkey_setKey("<F1>",  "\e[M")
    call Fixkey_setKey("<F2>",  "\e[N")
    call Fixkey_setKey("<F3>",  "\e[O")
    call Fixkey_setKey("<F4>",  "\e[P")
    call Fixkey_setKey("<F5>",  "\e[Q")
    call Fixkey_setKey("<F6>",  "\e[R")
    call Fixkey_setKey("<F7>",  "\e[S")
    call Fixkey_setKey("<F8>",  "\e[T")
    call Fixkey_setKey("<F9>",  "\e[U")
    call Fixkey_setKey("<F10>", "\e[V")
    call Fixkey_setKey("<F11>", "\e[W")
    call Fixkey_setKey("<F12>", "\e[X")
endfunction

function! Fixkey_setPuttyScoShiftF1toF12()
    call Fixkey_setNewKey("<S-F1>",  "\e[Y")
    call Fixkey_setNewKey("<S-F2>",  "\e[Z")
    call Fixkey_setNewKey("<S-F3>",  "\e[a")
    call Fixkey_setNewKey("<S-F4>",  "\e[b")
    call Fixkey_setNewKey("<S-F5>",  "\e[c")
    call Fixkey_setNewKey("<S-F6>",  "\e[d")
    call Fixkey_setNewKey("<S-F7>",  "\e[e")
    call Fixkey_setNewKey("<S-F8>",  "\e[f")
    call Fixkey_setNewKey("<S-F9>",  "\e[g")
    call Fixkey_setNewKey("<S-F10>", "\e[h")
    call Fixkey_setNewKey("<S-F11>", "\e[i")
    call Fixkey_setNewKey("<S-F12>", "\e[j")
endfunction

function! Fixkey_setPuttyScoCtrlF1toF12()
    call Fixkey_setNewKey("<C-F1>",  "\e[k")
    call Fixkey_setNewKey("<C-F2>",  "\e[l")
    call Fixkey_setNewKey("<C-F3>",  "\e[m")
    call Fixkey_setNewKey("<C-F4>",  "\e[n")
    call Fixkey_setNewKey("<C-F5>",  "\e[o")
    call Fixkey_setNewKey("<C-F6>",  "\e[p")
    call Fixkey_setNewKey("<C-F7>",  "\e[q")
    call Fixkey_setNewKey("<C-F8>",  "\e[r")
    call Fixkey_setNewKey("<C-F9>",  "\e[s")
    call Fixkey_setNewKey("<C-F10>", "\e[t")
    call Fixkey_setNewKey("<C-F11>", "\e[u")
    call Fixkey_setNewKey("<C-F12>", "\e[v")
endfunction

function! Fixkey_setPuttyScoCtrlShiftF1toF12()
    call Fixkey_setNewKey("<C-S-F1>",  "\e[w")
    call Fixkey_setNewKey("<C-S-F2>",  "\e[x")
    call Fixkey_setNewKey("<C-S-F3>",  "\e[y")
    call Fixkey_setNewKey("<C-S-F4>",  "\e[z")
    call Fixkey_setNewKey("<C-S-F5>",  "\e[@")
    call Fixkey_setNewKey("<C-S-F6>",  "\e[[")
    call Fixkey_setNewKey("<C-S-F7>",  "\e[\\")
    call Fixkey_setNewKey("<C-S-F8>",  "\e[]")
    call Fixkey_setNewKey("<C-S-F9>",  "\e[^")
    call Fixkey_setNewKey("<C-S-F10>", "\e[_")
    call Fixkey_setNewKey("<C-S-F11>", "\e[`")
    call Fixkey_setNewKey("<C-S-F12>", "\e[{")
endfunction

function! Fixkey_setPuttyScoMetaF1toF12()
    call Fixkey_setNewKey("<M-F1>",  "\e\e[M")
    call Fixkey_setNewKey("<M-F2>",  "\e\e[N")
    call Fixkey_setNewKey("<M-F3>",  "\e\e[O")
    call Fixkey_setNewKey("<M-F4>",  "\e\e[P")
    call Fixkey_setNewKey("<M-F5>",  "\e\e[Q")
    call Fixkey_setNewKey("<M-F6>",  "\e\e[R")
    call Fixkey_setNewKey("<M-F7>",  "\e\e[S")
    call Fixkey_setNewKey("<M-F8>",  "\e\e[T")
    call Fixkey_setNewKey("<M-F9>",  "\e\e[U")
    call Fixkey_setNewKey("<M-F10>", "\e\e[V")
    call Fixkey_setNewKey("<M-F11>", "\e\e[W")
    call Fixkey_setNewKey("<M-F12>", "\e\e[X")
endfunction

function! Fixkey_setPuttyScoMetaHomeEnd()
    call Fixkey_setNewKey("<M-Home>",    "\e\e[H")
    call Fixkey_setNewKey("<M-End>",     "\e\e[F")
endfunction

function! Fixkey_setPuttyScoKeys()
    call Fixkey_unsetFunctionKeys()
    call Fixkey_setMetaNumbers()
    call Fixkey_setMetaShiftNumbers()
    call Fixkey_setMetaLetters()
    call Fixkey_setPuttyScoF1toF12()
    call Fixkey_setPuttyScoShiftF1toF12()
    call Fixkey_setPuttyScoCtrlF1toF12()
    " Not working yet (seems like too many "setNewKey" calls):
    "call Fixkey_setPuttyScoCtrlShiftF1toF12()
    call Fixkey_setPuttyScoMetaF1toF12()
    call Fixkey_setPuttyCtrlArrows()
    call Fixkey_setPuttyMetaArrows()
    call Fixkey_setPuttyMetaCtrlArrows()
    call Fixkey_setPuttyScoMetaHomeEnd()
    call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setRxvtShiftF3toF12()
    call Fixkey_setKey("<S-F3>",  "\e[25~")
    call Fixkey_setKey("<S-F4>",  "\e[26~")
    call Fixkey_setKey("<S-F5>",  "\e[28~")
    call Fixkey_setKey("<S-F6>",  "\e[29~")
    call Fixkey_setKey("<S-F7>",  "\e[31~")
    call Fixkey_setKey("<S-F8>",  "\e[32~")
    call Fixkey_setKey("<S-F9>",  "\e[33~")
    call Fixkey_setKey("<S-F10>", "\e[34~")
    call Fixkey_setKey("<S-F11>", "\e[23$")
    call Fixkey_setKey("<S-F12>", "\e[24$")
endfunction

function! Fixkey_setRxvtCtrlF1toF12()
    call Fixkey_setNewKey("<C-F1>",  "\e[11^")
    call Fixkey_setNewKey("<C-F2>",  "\e[12^")
    call Fixkey_setNewKey("<C-F3>",  "\e[13^")
    call Fixkey_setNewKey("<C-F4>",  "\e[14^")
    call Fixkey_setNewKey("<C-F5>",  "\e[15^")
    call Fixkey_setNewKey("<C-F6>",  "\e[17^")
    call Fixkey_setNewKey("<C-F7>",  "\e[18^")
    call Fixkey_setNewKey("<C-F8>",  "\e[19^")
    call Fixkey_setNewKey("<C-F9>",  "\e[20^")
    call Fixkey_setNewKey("<C-F10>", "\e[21^")
    call Fixkey_setNewKey("<C-F11>", "\e[23^")
    call Fixkey_setNewKey("<C-F12>", "\e[24^")
endfunction

function! Fixkey_setRxvtMetaF1toF12()
    call Fixkey_setNewKey("<M-F1>",  "\e\e[11~")
    call Fixkey_setNewKey("<M-F2>",  "\e\e[12~")
    call Fixkey_setNewKey("<M-F3>",  "\e\e[13~")
    call Fixkey_setNewKey("<M-F4>",  "\e\e[14~")
    call Fixkey_setNewKey("<M-F5>",  "\e\e[15~")
    call Fixkey_setNewKey("<M-F6>",  "\e\e[17~")
    call Fixkey_setNewKey("<M-F7>",  "\e\e[18~")
    call Fixkey_setNewKey("<M-F8>",  "\e\e[19~")
    call Fixkey_setNewKey("<M-F9>",  "\e\e[20~")
    call Fixkey_setNewKey("<M-F10>", "\e\e[21~")
    call Fixkey_setNewKey("<M-F11>", "\e\e[23~")
    call Fixkey_setNewKey("<M-F12>", "\e\e[24~")
endfunction

function! Fixkey_setRxvtShiftArrows()
    call Fixkey_setKey("<S-Up>",    "\e[a")
    call Fixkey_setKey("<S-Down>",  "\e[b")
    call Fixkey_setKey("<S-Left>",  "\e[d")
    call Fixkey_setKey("<S-Right>", "\e[c")
endfunction

function! Fixkey_setRxvtCtrlArrows()
    call Fixkey_setNewKey("<C-Up>",    "\eOa")
    call Fixkey_setNewKey("<C-Down>",  "\eOb")
    call Fixkey_setNewKey("<C-Left>",  "\eOd")
    call Fixkey_setNewKey("<C-Right>", "\eOc")
endfunction

function! Fixkey_setRxvtMetaArrows()
    call Fixkey_setNewKey("<M-Up>",    "\e\eOA")
    call Fixkey_setNewKey("<M-Down>",  "\e\eOB")
    call Fixkey_setNewKey("<M-Left>",  "\e\eOD")
    call Fixkey_setNewKey("<M-Right>", "\e\eOC")
endfunction

function! Fixkey_setRxvtMetaShiftArrows()
    call Fixkey_setNewKey("<M-S-Up>",    "\e\e[a")
    call Fixkey_setNewKey("<M-S-Down>",  "\e\e[b")
    call Fixkey_setNewKey("<M-S-Left>",  "\e\e[d")
    call Fixkey_setNewKey("<M-S-Right>", "\e\e[c")
endfunction

function! Fixkey_setRxvtMetaCtrlArrows()
    call Fixkey_setNewKey("<M-C-Up>",    "\e\eOa")
    call Fixkey_setNewKey("<M-C-Down>",  "\e\eOb")
    call Fixkey_setNewKey("<M-C-Left>",  "\e\eOd")
    call Fixkey_setNewKey("<M-C-Right>", "\e\eOc")
endfunction

function! Fixkey_setRxvtCtrlHomeEnd()
    call Fixkey_setNewKey("<C-Home>",  "\e[7^")
    call Fixkey_setNewKey("<C-End>",   "\e[8^")
endfunction

function! Fixkey_setRxvtCtrlShiftHomeEnd()
    call Fixkey_setNewKey("<C-S-Home>",  "\e[7@")
    call Fixkey_setNewKey("<C-S-End>",   "\e[8@")
endfunction

function! Fixkey_setRxvtMetaHomeEnd()
    call Fixkey_setNewKey("<M-Home>",  "\e\e[7~")
    call Fixkey_setNewKey("<M-End>",   "\e\e[8~")
endfunction

function! Fixkey_setRxvtMetaShiftHomeEnd()
    call Fixkey_setNewKey("<M-S-Home>",  "\e\e[7$")
    call Fixkey_setNewKey("<M-S-End>",   "\e\e[8$")
endfunction

function! Fixkey_setRxvtMetaCtrlHomeEnd()
    call Fixkey_setNewKey("<M-C-Home>",  "\e\e[7^")
    call Fixkey_setNewKey("<M-C-End>",   "\e\e[8^")
endfunction

function! Fixkey_setRxvtMetaCtrlShiftHomeEnd()
    call Fixkey_setNewKey("<M-C-S-Home>",  "\e\e[7@")
    call Fixkey_setNewKey("<M-C-S-End>",   "\e\e[8@")
endfunction

function! Fixkey_setRxvtKeys()
    " <Undo> is \e[26~, which aliases <S-F4>.  Undefine it to avoid conflict.
    set <Undo>=
    " <Help> is \e28~, which aliases <S-F5>.  Undefine it to avoid conflict.
    set <Help>=
    call Fixkey_setMetaNumbers()
    call Fixkey_setMetaShiftNumbers()
    call Fixkey_setMetaLetters()
    call Fixkey_setRxvtShiftF3toF12()
    call Fixkey_setRxvtCtrlF1toF12()
    call Fixkey_setRxvtMetaF1toF12()
    call Fixkey_setRxvtShiftArrows()
    call Fixkey_setRxvtCtrlArrows()
    call Fixkey_setRxvtMetaArrows()
    call Fixkey_setRxvtMetaShiftArrows()
    call Fixkey_setRxvtMetaCtrlArrows()
    call Fixkey_setRxvtCtrlHomeEnd()
    call Fixkey_setRxvtCtrlShiftHomeEnd()
    call Fixkey_setRxvtMetaHomeEnd()
    call Fixkey_setRxvtMetaShiftHomeEnd()
    call Fixkey_setRxvtMetaCtrlHomeEnd()
    " Not enough mappable keys:
    "call Fixkey_setRxvtMetaCtrlShiftHomeEnd()
    call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setScreenExtraHomeEnd()
    " These are the same codes TERM=linux used.
    call Fixkey_setKey("<xHome>", "\e[1~")
    call Fixkey_setKey("<xEnd>", "\e[4~")
endfunction

function! Fixkey_setScreenCompatibleKeys()
    call Fixkey_setMetaNumbers()
    call Fixkey_setMetaShiftNumbers()
    call Fixkey_setMetaLetters()
    call Fixkey_setXtermFunctionKeys()
    call Fixkey_setXtermHomeEnd()
    call Fixkey_setScreenExtraHomeEnd()
    call Fixkey_setXtermArrows()
    call Fixkey_setVt100ExtraArrows()
    call Fixkey_setKey("<M-Enter>", "\e\r")
    " <S-Enter> works when hosted under konsole.
    call Fixkey_setNewKey("<S-Enter>", "\eOM")
endfunction

function! Fixkey_setScreenKeys()
    call Fixkey_setScreenCompatibleKeys()
endfunction

function! Fixkey_setTmuxKeys()
    call Fixkey_setScreenCompatibleKeys()
endfunction

function! Fixkey_detect()
    if $TERM =~# '^xterm\(-\d*color\)\?$'
        if $COLORTERM == "gnome-terminal"
            let termType = "gnome"
        else
            let termType = "xterm"
        endif

    elseif $TERM =~# '^gnome\(-\d*color\)\?$'
        let termType = "gnome"

    elseif $TERM =~# '^konsole\(-\d*color\)\?$'
        let termType = "konsole"

    elseif $TERM =~# 'linux\(-\d*color\)\?$'
        let termType = "linux"

    elseif $TERM == 'putty-sco'
        let termType = "putty-sco"

    elseif $TERM =~# '^putty\(-\d*color\)\?$'
        let termType = "putty"

    elseif $TERM =~# '^rxvt\(-unicode\)\?\(-\d*color\)\?$'
        let termType = "rxvt"

    elseif $TERM =~# '\v^screen([-.].*)?$'
        let termType = "screen"

    elseif $TERM =~# '\v^tmux(-\d*color|-bce|-it|-s)*$'
        let termType = "tmux"
    else
        let termType = "unknown"
    endif
    return termType
endfunction

function! Fixkey_setup()
    call Fixkey_timestamp('setup() start')
    if !exists('g:Fixkey_termType')
        let g:Fixkey_termType = Fixkey_detect()
    endif
    if g:Fixkey_termType == '' || g:Fixkey_termType == 'unknown'
        return
    endif

    " Ensure keycode timeouts are enabled.
    if &ttimeoutlen < 0
        set ttimeoutlen=5
    endif

    if g:Fixkey_termType == 'xterm'
        call Fixkey_setXtermKeys()
    elseif g:Fixkey_termType == 'gnome'
        call Fixkey_setGnomeTerminalKeys()
    elseif g:Fixkey_termType == 'konsole'
        call Fixkey_setKonsoleKeys()
    elseif g:Fixkey_termType == 'linux'
        call Fixkey_setLinuxKeys()
    elseif g:Fixkey_termType == 'putty-sco'
        call Fixkey_setPuttyScoKeys()
    elseif g:Fixkey_termType == 'putty'
        call Fixkey_setPuttyKeys()
    elseif g:Fixkey_termType == 'rxvt'
        call Fixkey_setRxvtKeys()
    elseif g:Fixkey_termType == 'screen'
        call Fixkey_setScreenKeys()
    elseif g:Fixkey_termType == 'tmux'
        call Fixkey_setTmuxKeys()
        " When TERM begins with "screen", Vim helpfully sets 'ttymouse' to
        " "xterm".  This same logic is required for tmux to work correctly, but
        " Vim lacks support for it before v8.0.0030.  As a work-around for this
        " problem, we ensure 'ttymouse' is set to Vim's default if it's
        " currently empty (otherwise, we leave it alone).
        if &ttymouse == ''
            set ttymouse=xterm
        endif
    else
        echoerr "Unsupported terminal: g:Fixkey_termType=" . g:Fixkey_termType
    endif
endfunction

" Invoked when `TermResponse` is received.
function! Fixkey_termResponse()
    call Fixkey_timestamp('TermResponse')
    if exists('*timer_start') && g:Fixkey_setupDelay > 0
        function! Fixkey_setupCallback(timerId)
            call Fixkey_setup()
        endfunction
        call timer_start(g:Fixkey_setupDelay, 'Fixkey_setupCallback')
    else
        " Without Vim's timer feature, we perform setup immediately and
        " hope that waiting for `TermResponse` has delayed enough.
        call Fixkey_setup()
    endif
endfunction

" With newer Xterm, Vim enters an extended negotiation during startup.  First
" Vim queries for Xterm's version and receives the response into v:termresponse.
" When Xterm's patchlevel is 141 or higher, Vim continues querying for Xterm's
" key codes.  These negotiations happen after fixkey.vim is sourced.  With
" Fixkey's mappings in place, Vim misinterprets Xterm's startup responses.  To
" avoid this, Fixkey attempts to delay its setup until after Xterm negotiations
" have completed.

if !exists("g:Fixkey_setupDelay")
    " With newer Vim, responses for terminal queries about cursor styles and the
    " like can arrive significantly after `TermResponse` has been received.
    " Performing setup before these responses have been processed can cause
    " Vim to misinterpret the responses.  Measurements have shown the need
    " for delays up to 400 ms in some cases.
    let g:Fixkey_setupDelay = 400
endif

call Fixkey_timestamp('prepare for setup()')
if g:Fixkey_setupDelay == 0
    call Fixkey_setup()
else
    " Delay at least until `TermResponse`.
    augroup Fixkey
        autocmd!
        autocmd TermResponse * call Fixkey_termResponse()
    augroup END
endif

" Restore saved 'cpoptions'.
let &cpoptions = s:save_cpoptions
" vim: sts=4 sw=4 tw=80 et ai:
