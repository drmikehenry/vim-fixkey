****************************************
Fixkey - fixes key codes for console Vim
****************************************

Fixkey helps Vim use the non-ASCII keys of a terminal emulator, permitting
mapping of several classes of characters, including:

- Function keys (<F1> - <F12>).
- Shifted function keys (<S-F1> - <S-F12>).
- Alt-lowercase letters (<M-a> - <M-z>).
- Alt-uppercase letters (<M-A> - <M-Z>).
- Arrow keys (<Up>, <Down>, <Left>, <Right>).
- Shifted Arrow keys (<S-Up>, <S-Down>, <S-Left>, <S-Right>).
- Control Arrow keys (<C-Up>, <C-Down>, <C-Left>, <C-Right>).
- <Home>, <End>, <S-Home>, <S-End>.
- <M-Enter> (not all terminals).
- <S-Enter> (few terminals).

Now, console Vim users can map keys like Gvim users, e.g.::

  " Map Alt-q to re-wrap a paragraph.
  :nnoremap <M-q> gqap

See documentation in doc/fixkey.txt for installation instructions and
terminal setup.

Developed by Michael Henry (vim at drmikehenry.com).

Distributed under Vim's license.

Git repository:   https://github.com/drmikehenry/vim-fixkey
