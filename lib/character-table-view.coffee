{SelectListView, $$} = require "atom-space-pen-views"

module.exports =
class CharacterTableView extends SelectListView
  initialize: ->
    super
    @addClass "character-table"
    @setMaxItems 100
    @characterData = @loadCharacters()
    @setItems @characterData

    # @css "width", "30em"
    # @css "max-width", "30em"
    # @css "min-width", "30em"
    # # Create root element
    # @element = document.createElement('div')
    # @element.classList.add('character-table')
    #
    # # Create message element
    # message = document.createElement('div')
    # message.textContent = "The CharacterTable package is Alive! It's ALIVE!"
    # message.classList.add('message')
    # @element.appendChild(message)

  loadCharacters: ->
    rfc1345_data = fs.readFileSync path.resolve __dirname, "..", "rfc1345.txt"
    unicode_data = fs.readFileSync path.resolve __dirname, "..", "UnicodeData.txt"

    rfc1345_data = rfc1345_data.toString()
    unicode_data = unicode_data.toString()

    char_data = []

    mnemonics = {}
    for line in rfc1345_data.split /\n/
      continue if line.length < 4
      continue if line[0] != " "
      continue if line[1] == " "

      [mnemonic, number, iso_name] = line[1..].split(/\s+/, 2)

      mnemonic += " " if mnemonic.length == 1
      try
        char = String.fromCodePoint("0x"+number)
      catch e
        console.warn "Error decoding #{number}, #{iso_name}"
        continue

      mnemonics[char] = mnemonic

    for line in unicode_data.split /\n/
      row = line.split /;/
      [codePoint, name, category] = row[..2]

      unless category
        console.log "row", row
        console.log "category evals to false"
        continue
      continue if category.match /^C/

      try
        char = String.fromCodePoint("0x"+codePoint)
      catch e
        console.warn "Error decoding #{number}, #{iso_name}"
        continue

      mnemonic = "  "
      if char of mnemonics
        mnemonic = mnemonics[char]

      codePoint = "U+"+codePoint

      key = "#{codePoint} #{mnemonic} #{name}"

      char_data.push {char, codePoint, mnemonic, name, key}

    char_data

  getFilterKey: -> 'key'

  # Tear down any state and detach
  destroy: ->
    @cancel()
    @panel?.destroy()

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
    @hide()
    atom.workspace.getActiveEditor().insertText(item.char)
    @restoreFocus()

  cancelled: ->
    @hide()
    @restoreFocus()

  show: ->

    @panel ?= atom.workspace.addModalPanel(item: this)

    #@list.css("width", "30em")
  #  debugger
    #@width(@list.outerWidth())

    #view = atom.views.getView(@panel)
    #jdebugger
    #view.width(@list.outerWidth())

    @panel.show()

    console.log @panel
    console.log @


    @storeFocusedElement()

    @focusFilterEditor()

  hide: ->
    @panel?.hide()
