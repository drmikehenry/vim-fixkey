" Fix key encodings for console Vim.

" Distributed under Vim's |license|; see |fixkey.txt| for details.

if exists("loaded_fixkey")
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

" Ensure keycode timeouts are enabled.
if &ttimeoutlen < 0
    set ttimeoutlen=50
endif

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

function! Fixkey_setMetaLetters()
    let c = 'a'
    while c <= 'z'
        let uc = toupper(c)
        call Fixkey_setKey("<M-" .  c . ">", "\e" . c)
        call Fixkey_setKey("<M-" . uc . ">", "\e" . uc)
        let c = nr2char(char2nr(c) + 1)
    endwhile
endfunction

function! Fixkey_resetMetaLetters()
    let c = 'a'
    while c <= 'z'
        let uc = toupper(c)
        call Fixkey_setKey("<M-" .  c . ">", nr2char(char2nr(c)  + 0x80))
        call Fixkey_setKey("<M-" . uc . ">", nr2char(char2nr(uc) + 0x80))
        let c = nr2char(char2nr(c) + 1)
    endwhile
endfunction

function! Fixkey_setXtermF1toF4()
    call Fixkey_setKey("<F1>", "\eOP")
    call Fixkey_setKey("<F2>", "\eOQ")
    call Fixkey_setKey("<F3>", "\eOR")
    call Fixkey_setKey("<F4>", "\eOS")
endfunction

function! Fixkey_setXtermShiftedF1toF4()
    call Fixkey_setKey("<S-F1>", "\e[1;2P")
    call Fixkey_setKey("<S-F2>", "\e[1;2Q")
    call Fixkey_setKey("<S-F3>", "\e[1;2R")
    call Fixkey_setKey("<S-F4>", "\e[1;2S")
endfunction

function! Fixkey_setXtermHomeEnd()
    call Fixkey_setKey("<Home>", "\eOH")
    call Fixkey_setKey("<End>", "\eOF")
endfunction

function! Fixkey_setXtermShiftedHomeEnd()
    call Fixkey_setKey("<S-Home>", "\e[1;2H")
    call Fixkey_setKey("<S-End>", "\e[1;2F")
endfunction

function! Fixkey_setXtermKeys()
    let g:Fixkey_termType = "xterm"
    call Fixkey_setMetaLetters()
    call Fixkey_setXtermF1toF4()
    call Fixkey_setXtermHomeEnd()
    call Fixkey_setXtermShiftedF1toF4()
    call Fixkey_setXtermShiftedHomeEnd()
    call Fixkey_setKey("<M-Enter>", "\e\r")
    " For KDE Konsole with TERM=xterm; true xterm doesn't work.
    call Fixkey_setNewKey("<S-Enter>", "\eOM")
endfunction

function! Fixkey_setGnomeTerminalKeys()
    let g:Fixkey_termType = "gnome"
    call Fixkey_setMetaLetters()
    call Fixkey_setXtermF1toF4()
    call Fixkey_setXtermHomeEnd()
    call Fixkey_setNewKey("<S-F1>", "\eO1;2P")
    call Fixkey_setNewKey("<S-F2>", "\eO1;2Q")
    call Fixkey_setNewKey("<S-F3>", "\eO1;2R")
    call Fixkey_setNewKey("<S-F4>", "\eO1;2S")
    " Can't get this to work:
    " call Fixkey_setKey("<M-Enter>", "\e\n")
endfunction

" setKey is "setKey" or "setNewKey".
function! Fixkey_setKonsoleShiftedF5toF12(setKey)
    let SetKeyFn = function("Fixkey_" . a:setKey)
    call SetKeyFn("<S-F5>", "\e[15;2~")
    call SetKeyFn("<S-F6>", "\e[17;2~")
    call SetKeyFn("<S-F7>", "\e[18;2~")
    call SetKeyFn("<S-F8>", "\e[19;2~")
    call SetKeyFn("<S-F9>", "\e[20;2~")
    call SetKeyFn("<S-F10>", "\e[21;2~")
    call SetKeyFn("<S-F11>", "\e[23;2~")
    call SetKeyFn("<S-F12>", "\e[24;2~")
endfunction

function! Fixkey_setKonsoleCtrlArrows()
    call Fixkey_setNewKey("<C-Up>", "\e[1;5A")
    call Fixkey_setNewKey("<C-Down>", "\e[1;5B")
    call Fixkey_setNewKey("<C-Left>", "\e[1;5D")
    call Fixkey_setNewKey("<C-Right>", "\e[1;5C")
endfunction

function! Fixkey_setKonsoleKeys()
    let g:Fixkey_termType = "konsole"
    call Fixkey_setMetaLetters()
    call Fixkey_setNewKey("<S-F1>", "\eO2P")
    call Fixkey_setNewKey("<S-F2>", "\eO2Q")
    call Fixkey_setNewKey("<S-F3>", "\eO2R")
    call Fixkey_setNewKey("<S-F4>", "\eO2S")
    call Fixkey_setKonsoleShiftedF5toF12("setNewKey")
    call Fixkey_setXtermShiftedHomeEnd()
    call Fixkey_setKonsoleCtrlArrows()
    call Fixkey_setKey("<M-Enter>", "\e\r")
    call Fixkey_setNewKey("<S-Enter>", "\eOM")
endfunction

function! Fixkey_setLinuxHomeEnd()
    call Fixkey_setKey("<Home>", "\e[1~")
    call Fixkey_setKey("<End>", "\e[4~")
endfunction

function! Fixkey_setLinuxKeys()
    let g:Fixkey_termType = "linux"
    call Fixkey_setMetaLetters()
    call Fixkey_setKey("<F1>", "\e[[A")
    call Fixkey_setKey("<F2>", "\e[[B")
    call Fixkey_setKey("<F3>", "\e[[C")
    call Fixkey_setKey("<F4>", "\e[[D")
    call Fixkey_setKey("<F5>", "\e[[E")
    call Fixkey_setKey("<F6>", "\e[17~")
    call Fixkey_setKey("<F7>", "\e[18~")
    call Fixkey_setKey("<F8>", "\e[19~")
    call Fixkey_setKey("<F9>", "\e[20~")
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
    call Fixkey_setLinuxHomeEnd()
    call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setPuttyShiftedF3toF10()
    call Fixkey_setNewKey("<S-F3>", "\e[25~")
    call Fixkey_setNewKey("<S-F4>", "\e[26~")
    call Fixkey_setNewKey("<S-F5>", "\e[28~")
    call Fixkey_setNewKey("<S-F6>", "\e[29~")
    call Fixkey_setNewKey("<S-F7>", "\e[31~")
    call Fixkey_setNewKey("<S-F8>", "\e[32~")
    call Fixkey_setNewKey("<S-F9>", "\e[33~")
    call Fixkey_setNewKey("<S-F10>", "\e[34~")
endfunction

function! Fixkey_setPuttyCtrlArrows()
    call Fixkey_setNewKey("<C-Up>", "\eOA")
    call Fixkey_setNewKey("<C-Down>", "\eOB")
    call Fixkey_setNewKey("<C-Left>", "\eOD")
    call Fixkey_setNewKey("<C-Right>", "\eOC")
endfunction

function! Fixkey_setPuttyKeys()
    let g:Fixkey_termType = "putty"
    call Fixkey_setMetaLetters()
    call Fixkey_setPuttyShiftedF3toF10()
    call Fixkey_setPuttyCtrlArrows()
    call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setPuttyScoKeys()
    let g:Fixkey_termType = "putty-sco"
    call Fixkey_setMetaLetters()
    call Fixkey_setNewKey("<S-F1>", "\e[Y")
    call Fixkey_setNewKey("<S-F2>", "\e[Z")
    call Fixkey_setNewKey("<S-F3>", "\e[a")
    call Fixkey_setNewKey("<S-F4>", "\e[b")
    call Fixkey_setNewKey("<S-F5>", "\e[c")
    call Fixkey_setNewKey("<S-F6>", "\e[d")
    call Fixkey_setNewKey("<S-F7>", "\e[e")
    call Fixkey_setNewKey("<S-F8>", "\e[f")
    call Fixkey_setNewKey("<S-F9>", "\e[g")
    call Fixkey_setNewKey("<S-F10>", "\e[h")
    call Fixkey_setNewKey("<S-F11>", "\e[i")
    call Fixkey_setNewKey("<S-F12>", "\e[j")
    call Fixkey_setPuttyCtrlArrows()
    call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setRxvtKeys()
    let g:Fixkey_termType = "rxvt"
    " <Undo> is \e[26~, which aliases <S-F4>.  Undefine it to avoid conflict.
    set <Undo>=
    " <Help> is \e28~, which aliases <S-F5>.  Undefine it to avoid conflict.
    set <Help>=
    call Fixkey_setMetaLetters()
    call Fixkey_setPuttyShiftedF3toF10()
    call Fixkey_setNewKey("<S-F11>", "\e[23$")
    call Fixkey_setNewKey("<S-F12>", "\e[24$")
    call Fixkey_setNewKey("<C-Up>", "\eOa")
    call Fixkey_setNewKey("<C-Down>", "\eOb")
    call Fixkey_setNewKey("<C-Left>", "\eOd")
    call Fixkey_setNewKey("<C-Right>", "\eOc")
    call Fixkey_setKey("<M-Enter>", "\e\r")
endfunction

function! Fixkey_setScreenKeys()
    let g:Fixkey_termType = "screen"
    call Fixkey_setMetaLetters()
    call Fixkey_setXtermShiftedF1toF4()
    call Fixkey_setKonsoleShiftedF5toF12("setKey")
    call Fixkey_setLinuxHomeEnd()
    call Fixkey_setXtermShiftedHomeEnd()
    call Fixkey_setKonsoleCtrlArrows()
    call Fixkey_setKey("<M-Enter>", "\e\r")
    " <S-Enter> works when hosted under konsole.
    call Fixkey_setNewKey("<S-Enter>", "\eOM")
endfunction

if $TERM =~# '^xterm\(-\d*color\)\?$'
    if $COLORTERM == "gnome-terminal"
        call Fixkey_setGnomeTerminalKeys()
    else
        call Fixkey_setXtermKeys()
    endif

elseif $TERM =~# '^gnome\(-\d*color\)\?$'
     call Fixkey_setGnomeTerminalKeys()

elseif $TERM =~# '^konsole\(-\d*color\)\?$'
    call Fixkey_setKonsoleKeys()

elseif $TERM == 'linux'
    call Fixkey_setLinuxKeys()

elseif $TERM == 'putty-sco'
    call Fixkey_setPuttyScoKeys()

elseif $TERM =~# '^putty\(-\d*color\)\?$'
    call Fixkey_setPuttyKeys()

elseif $TERM =~# '^rxvt\(-unicode\)\?\(-\d*color\)\?$'
    call Fixkey_setRxvtKeys()

elseif $TERM =~# '^screen\(-\d*color\)\?\(-bce\)\?\(-s\)\?$'
    call Fixkey_setScreenKeys()

else
    let g:Fixkey_termType = "unknown"
endif

" Restore saved 'cpoptions'.
let cpoptions = s:save_cpoptions
" vim: sts=4 sw=4 tw=80 et ai:
