# character-table package

With character table you can lookup any Unicode Character (except control characters) to insert into your document.

Hit `alt-l` to open the selection view and then find it either via
unicode code point or ISO name of the character.

![A screenshot of character table](https://raw.githubusercontent.com/klorenz/atom-character-table/master/character-table.png)


## Character Mnemonics or Vim-like digraph support

You can enable VIM-like digraph support.  If enabled, you can hit
your digraphKey (default is `ctrl-k`) and a character mnemonic to
insert a character.  E.g. hit `ctrl-k a :` for inserting "ä".

Character Mnemonics are defined in [RFC1345](https://tools.ietf.org/html/rfc1345).  They are also
displayed in Character Table you get with `alt-l` right after the
unicode codepoint.

Caveat: There is one caveat.  In atom you can connect keybindings only
with commands and all commands are displayed in command palette.  This
feature adds ~1800 commands, which makes command palette behaviour a
bit slow.  Need to hide these commands from it.
