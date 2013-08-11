****************************************
Fixkey - fixes key codes for console Vim
****************************************

Fixkey helps Vim use the non-ASCII keys of a terminal emulator, permitting
mapping of several classes of characters, including:

- Function keys (<F1> - <F12>).
- Shifted function keys (<S-F1> - <S-F12>).
- Alt-lowercase letters (<M-a> - <M-z>).
- Alt-uppercase letters (<M-A> - <M-Z>).
- <Home>, <End>, <S-Home>, <S-End>.

Now, console Vim users can map keys like Gvim users, e.g.::

  " Map Alt-Q to re-wrap a paragraph.
  :nnoremap <M-Q> gqap

See documentation in doc/fixkey.txt for installation instructions and
terminal setup.

Developed by Michael Henry (vim at drmikehenry.com).

Distributed under Vim's license.

Git repository:   https://github.com/drmikehenry/vim-fixkey
