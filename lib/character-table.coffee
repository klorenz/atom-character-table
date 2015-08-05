CharacterTableView = require './character-table-view'
{CompositeDisposable} = require 'atom'

module.exports = CharacterTable =
  characterTableView: null
  modalPanel: null
  subscriptions: null

  config:
    enableCharacterMnemonics:
      type: "boolean"
      default: false
      description: """
        If enabled, you can use character mnemonics for inserting unicode
        characters as described in RFC 1345.  You may know this feature from
        VIM as "digraphs".
      """

    mnemonicKey:
      type: "string"
      description: """
        Key prefix for mnemonics.  If prefix is 'ctrl-k', 'ctrl-k a :' inserts 'ä'.
        Default mimics VIM digraphs.
      """
      default: "ctrl-k"

    mnemonicMnemonicMatch:
      type: "string"
      default: ""
      description: """
        Specify a regex to match against mnemonics, to use them.  If both
        mnemonic match and character name match do match, a character mnemonic
        is used.  Filtering reduces atom commands and speed things up.
      """

    mnemonicCharacterNameMatch:
      type: "string"
      default: ""
      description: """
        Specify name matches separated by ",".  If you e.g. specify
        "katakana, hiragana, latin", you can use digraphs for all latin
        and some japanese characters.
        Filtering reduces atom commands and speed things up.
      """

    mnemonicAllowReversed:
      type: "boolean"
      description: """
        If enabled you can also use reversed mnemonics for digraphs (two
        letter mnemonics), if not already used.  Then 'ctrl-k a :' and
        'ctrl-k : a' are equivalent.
        """
      default: true

  activate: (state) ->
    @characterTableView = new CharacterTableView(state.characterTableViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'character-table:toggle': =>
      @characterTableView.showAll()

    @subscriptions.add atom.commands.add 'atom-workspace', 'character-table:show-enabled-mnemonics': =>
      @characterTableView.showMnemonics()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @characterTableView.destroy()

  serialize: ->
    characterTableViewState: @characterTableView.serialize()
