# character-table-plus package

The character-table-plus package is a fork of the character-table package
written by [klorenz](https://github.com/klorenz). This fork, made solely to
include some essential upgrades, may be merged back into the original package
by its author, or live on independently. There are currently no plans to
further develop the functionality of the plus package, but pull requests that
address reproducible bugs are very welcome and will be merged.

With character-table-plus you can lookup any Unicode Character (except control
characters) to insert into your document.

Hit `alt-l` to open the selection view and then find it either via
unicode code point or ISO name of the character.

![A screenshot of character table](https://raw.githubusercontent.com/threadless-screw/atom-character-table-plus/master/character-table.png)


## Character Mnemonics or Vim-like digraph support

You can enable VIM-like digraph support.  If enabled, you can hit
your Mnemonic Key (default is `ctrl-k`) and a character mnemonic to
insert a character.  E.g. hit `ctrl-k a :` for inserting "ä".

Character Mnemonics are defined in [RFC1345](https://tools.ietf.org/html/rfc1345).  They are also
displayed in Character Table you get with `alt-l` right after the
unicode codepoint.

Caveat: There is one caveat.  In atom you can connect keybindings only
with commands and all commands are displayed in command palette.  This
feature adds ~1800 commands, which makes command palette behaviour a
bit slow.  Need to hide these commands from it.

For minimizing added command, you can specify which mnemonics you want
to use with two configuration options:

- Mnemonic Mnemonic Match
- Mnemonic Character Name Match

### Enable Character Mnemonics

Enable use of character mnemonics.

### Mnemonic Key

Hit your Mnemonic Key (default is `ctrl-k`) and a character mnemonic to
insert a character.  E.g. hit `ctrl-k a :` for inserting "ä".

### Mnemonic Match

*Mnemonic Match* specifies a regular expression, which is matched against
mnemonic characters.

### Character Name Match

*Character Name Match* specifies a regular expression with following difference:

For more readability alternatives can be separated by "," with
surrounding whitespace and whitespace means any character.

If you specify `latin diaresis, arrow` as Character Name Match you
can use latin character diaresis mnemonics and arrow character mnemonics.

Technically `latin diaresis, arrow` is translated into `latin.*diaresis|arrow`.

### Allow Reversed Mnemonics

From Vim I am used to `ctrl-k : a` for inserting.
