{SelectListView, $} = require "atom-space-pen-views"
{CompositeDisposable} = require "atom"
{CharacterData} = require "./character-data.coffee"
fuzzaldrin = require 'fuzzaldrin'

Q = require "q"
path = require "path"
fs = require "fs"

slugify = (s) ->
  s.replace(/[^A-Za-z0-9_]/g, "-").toLowerCase()

htmlEnc = (s) -> s.replace(/&/, '&amp;').replace(/</g, "&lt;").replace(/>/g, "&gt;")


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

  populateList: ->
    return unless @items

    filterQuery = @getFilterQuery()

    if filterQuery.length
      scoredCandidates = []
      for candidate in @items
        scores = {total: 0}
        for field in ["codePoint", "mnemonic", "name"]
          scores[field] = 0
          s = candidate[field]
          continue unless s
          score = fuzzaldrin.score s, filterQuery
          scores.total += score
          scores[field] = score

        scoredCandidates.push {candidate, scores} if scores.total > 0
        scores.total /= 3
      scoredCandidates.sort (a,b) -> b.scores.total - a.scores.total
    else
      scoredCandidates = @items.map (candidate) => {candidate}

    count = 0

    @list.empty()
    if scoredCandidates.length
      @setError(null)

      count = Math.min(scoredCandidates.length, @maxItems)
      for i in [0...count]
        item = scoredCandidates[i]
        itemView = $(@viewForItem(item))
        itemView.data('select-list-item', item)
        @list.append(itemView)

      @selectItemView @list.find('li:first')
    else
      @setError @getEmptyMessage(@items.length, scoredCandidates.length)


  viewForItem: (item) ->
    {char} = item.candidate
    filterQuery = @getFilterQuery()

    view =  """<li class="two-lines">\n"""
    view += """  <span class="ct-char">#{char}</span>\n"""
    view += """  <span class="ct-info">\n"""

    for name in ['codePoint', 'mnemonic', 'name']
      value = item.candidate[name]
      continue unless value

      if item.scores?[name]
        matches = fuzzaldrin.match value, filterQuery

        parts = []
        prev = 0
        for i in matches
          parts.push htmlEnc value[prev...i]
          parts.push "<b>" + htmlEnc(value[i]) + "</b>"
          prev = i+1
        parts.push value[i+1...]

        value = parts.join ''
      else
        value = htmlEnc value

      nameLower = name.toLowerCase()
      view += """    <span class="ct-#{nameLower}">#{value}</span>"""

    view += """  </span>\n"""
    view += """</li>\n"""


    # <li class="two-lines">
    #   <span class="ct-char">#{char}</span>
    #   <span class="ct-info">
    #     <span class="ct-codepoint">#{codePoint}</span>
    #     <span class="ct-mnemonic">#{mnemonic}</span>
    #     <span class="ct-name">#{name}</span>
    #   </span>
    # </li>



    # key has the form "#{codePoint} #{mnemonic} #{name}"



    # filterQuery     = @getFilterQuery()
    # matches         = fuzzaldrin.match key, filterQuery
    # codePoint_parts = []
    # mnemonic_parts  = []
    # name_parts      = []
    #
    # i = 0
    # prev  = 0
    # parts = codePoint_parts
    # part = codePoint
    #
    # endCodePoint = codePoint.length
    # endMnemonic = codePoint.length + mnemonic.length + 1
    #
    # for i in matches
    #   if part is codePoint and i >= endCodePoint
    #     parts.push htmlEnc key[prev...endCodePoint]
    #     part = mnemonic
    #     parts = mnemonic_parts
    #     prev = endCodePoint+1
    #
    #   if part is mnemonic and i >= endMnemonic
    #     parts.push htmlEnc key[prev...endMnemonic]
    #     part = name
    #     parts = name_parts
    #     prev = endMnemonic+1
    #
    #   parts.push htmlEnc key[prev...i]
    #   parts.push "<b>"+htmlEnc(key[i])+"</b>"
    #   prev = i+1
    #
    # if i < endCodePoint
    #   codePoint_parts.push key[prev...endCodePoint]
    #   prev = endCodePoint+1
    #
    # if i < endMnemonic
    #   mnemonic_parts.push key[prev...endMnemonic]
    #   prev = endMnemonic+1
    #
    # name_parts.push key[prev...]
    #
    # name = name_parts.join('')
    # codePoint = codePoint_parts.join('')
    # mnemonic  = mnemonic_parts.join('')
    #
    # """
    # <li class="two-lines">
    #   <span class="ct-char">#{char}</span>
    #   <span class="ct-info">
    #     <span class="ct-codepoint">#{codePoint}</span>
    #     <span class="ct-mnemonic">#{mnemonic}</span>
    #     <span class="ct-name">#{name}</span>
    #   </span>
    # </li>
    # """

  confirmed: (item) ->
    atom.workspace.getActiveTextEditor().insertText(item.candidate.char)
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
