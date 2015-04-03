CharacterTableView = require './character-table-view'
{CompositeDisposable} = require 'atom'

module.exports = CharacterTable =
  characterTableView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @characterTableView = new CharacterTableView(state.characterTableViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'character-table:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @characterTableView.destroy()

  serialize: ->
    characterTableViewState: @characterTableView.serialize()

  toggle: ->
    console.log 'CharacterTable was toggled!'

    @characterTableView.show()

    # @characterTableView = new CharacterTableView(state.characterTableViewState)
    #
    # if @modalPanel.isVisible()
    #   @modalPanel.hide()
    # else
    #   @modalPanel.show()
