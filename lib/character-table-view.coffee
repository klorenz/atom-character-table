{SelectListView, $$} = require "atom-space-pen-views"
{CompositeDisposable} = require "atom"
{CharacterData} = require "./character-data.coffee"
Q = require "q"
path = require "path"
fs = require "fs"

slugify = (s) ->
  s.replace(/[^A-Za-z0-9_]/g, "-").toLowerCase()

module.exports =
class CharacterTableView extends SelectListView

  initialize: ->
    super
    @addClass "character-table"
    @setMaxItems 100
    @updateDelay = 1000
    @updating = false
    @needUpdate = false

    @characterData = new CharacterData()

    @characterData.initialized.then =>

      @setItems @characterData.getAll()

      if atom.config.get('character-table.enableCharacterMnemonics')
        @updateMnemonics()

      atom.config.onDidChange 'character-table.enableCharacterMnemonics', ({newValue,oldValue}) =>
        @updateMnemonics()

      # do this delayed
      atom.config.onDidChange 'character-table.mnemonicMnemonicMatch', ({newValue, oldValue}) =>
        @delayedUpdateMnemonics()

      atom.config.onDidChange 'character-table.mnemonicCharacterNameMatch', ({newValue, oldValue}) =>
        @delayedUpdateMnemonics()

      atom.config.onDidChange 'character-table.mnemonicKey', ({newValue, oldValue}) =>
        @delayedUpdateMnemonics()



  # change event happens on keystroke, so we delay the updating a second
  delayedUpdateMnemonics: ->
    if @updateScheduled
      @updateScheduled = clearTimeout @updateScheduled

    doUpdate = =>
      @updateMnemonics()
      @updateScheduled = null

    @updateScheduled = setTimeout doUpdate, @updateDelay

    # @css "max-width", "30em"
    # @css "min-width", "30em"
    # # Create root element
    # @element = document.createElement('div')
    # @element.classList.add('character-table')
    #⌂
    # # Create message element
    # message = document.createElement('div')
    # message.textContent = "The CharacterTable package is Alive! It's ALIVE!"
    # message.classList.add('message')
    # @element.appendChild(message)
  updateMnemonics: ->
    if @updating
      @needUpdate = true
      return

    @disableMnemonics()
    if atom.config.get('character-table.enableCharacterMnemonics')
      @enableMnemonics()

    @updating = false
    if @needUpdate
      @updateMnemonics()

  enableMnemonics: ->
    mnemonicRegex = atom.config.get 'character-table.mnemonicMnemonicMatch'
    charNameRegex = atom.config.get 'character-table.mnemonicCharacterNameMatch'
    allowReversed = atom.config.get 'character-table.mnemonicAllowReversed'

    if mnemonicRegex
      mnemonicRegex = new RegExp mnemonicMatch

    if charNameRegex
      charNameRegex = charNameRegex.replace(/\s*,\s*/g, '|').replace(/\s+/g, '.*')
      charNameRegex = new RegExp charNameRegex, "i"

    @mnemonics = new CompositeDisposable

    @characterData.setupMnemonics
      mnemonicRegex: mnemonicRegex
      charNameRegex: charNameRegex
      allowReversed: allowReversed

      digraphKey: atom.config.get('character-table.mnemonicKey')

      addCommand: (commandName, item) =>
        @mnemonics.add atom.commands.add "atom-workspace", commandName, =>
          atom.workspace.getActiveTextEditor().insertText item.char

      addKeymap: (keymap) =>
        @mnemonics.add atom.keymaps.add("character-table/mnemonics", {"atom-workspace": keymap})

  disableMnemonics: ->
    @mnemonics?.dispose()

  getFilterKey: -> 'key'

  # Tear down any state and detach
  destroy: ->
    @cancel()
    @panel?.destroy()
    @disableMnemonics()

  viewForItem: ({char, codePoint, mnemonic, name}) ->
    $$ ->
      @li class: 'two-lines', =>
        @span class: 'ct-char', char
        @span class: 'ct-info', =>
          @span class: 'ct-codepoint', codePoint
          @text " "
          @span class: 'ct-mnemonic', mnemonic
          @text " "
          @span class: 'ct-name', name

  confirmed: (item) ->
    atom.workspace.getActiveTextEditor().insertText(item.char)
    @cancelled()

  cancelled: ->
    @hide()
    @restoreFocus()

  showMnemonics: ->
    @setItems @characterData.getMnemonics()
    @show()

  showAll: ->
    @setItems @characterData.getAll()
    @show()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)

    # @panel.getItem().parent().css
    #   width: '30em'
    #   leftMargin: '-15em'

    @panel.show()

    @storeFocusedElement()

    @focusFilterEditor()


  hide: ->
    @panel?.hide()
