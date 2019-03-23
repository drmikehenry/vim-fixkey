****************************************
Fixkey - fixes key codes for console Vim
****************************************

Fixkey helps Vim use the non-ASCII keys of a terminal emulator, permitting
mapping of several classes of characters, including:

- Alt-numbers (<M-0> - <M-9>).
- Alt-lowercase letters (<M-a> - <M-z>).
- Alt-uppercase letters (<M-A> - <M-Z>), except <M-O> due to keycode
  ambiguity).
- Function keys with no modifiers or combinations of shift, control, and alt:
  <F1> - <F12>, <S-F1> - <S-F12>, ..., <M-C-S-F1> - <M-C-S-F12>.
  *Note* not all combination of terminal and environment send all of these.
- Arrow keys with no modifiers or combinations of shift, control, and alt:
  <Up>, <Down>, <Left>, <Right>, <S-Up>, <S-Down>, <S-Left>, <S-Right>, ..., 
  <M-C-S-Up>, <M-C-S-Down>, <M-C-S-Left>, <M-C-S-Right>.
- Home and End keys with no modifiers or combinations of shift, control, and
  alt: <Home>, <End>, <S-Home>, <S-End>, ..., <M-C-S-Home>, <M-C-S-End>.
- <S-Enter> (few terminals).
- <M-Enter> (not all terminals).

Now, console Vim users can map keys like Gvim users, e.g.::

  " Map Alt-q to re-wrap a paragraph.
  :nnoremap <M-q> gqap

See documentation in doc/fixkey.txt for installation instructions and
terminal setup.

**NOTE** Unexpected results may occur when using macros with fixkey, because
macros do not maintain the original timings between key codes, causing Vim's
timing-based algorithms to become confused.  See the documentation for more
details.

Developed by Michael Henry (vim at drmikehenry.com).

Distributed under Vim's license.

Git repository:   https://github.com/drmikehenry/vim-fixkey
