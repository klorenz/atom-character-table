Q = require "q"
fs = require 'fs'
path = require 'path'

class CharacterData
  constructor: (opts) ->
    {autoload} = opts || {}
    autoload ?= true
    @initialize() if autoload

  initialize: ->
    @initialized = @loadCharacters().then (chardata) =>
      @characterData = chardata
      true

  slugify: (s) ->
    s.replace(/[^A-Za-z0-9_]/g, "-").toLowerCase()

  getAll: (filter) ->
    if filter?
      @characterData.filter filter
    else
      @characterData

  getMnemonics: ->
    @characterData.filter (item) -> item.isMnemonic

  setupMnemonics: (opts) ->

    @initialized.then =>

      {mnemonicRegex, charNameRegex, addCommand} = opts
      {addKeymap, digraphKey, allowReversed, count} = opts

      mnemonics = @mnemonics

      reverse_mnemonic = null

      _getReverseMnemonic = (char2, char1) ->
        result = null

        if allowReversed
          result = char2+char1
          if result of mnemonics
            result = null
        return result

      _mnemonicMatch = (item, reverse_mnemonic) ->
        result = true

        if mnemonicRegex
          result = item.mnemonic.match mnemonicRegex
          if reverse_mnemonic?
            result |= reverse_mnemonic.match mnemonicRegex

        return result

      _charNameMatch = (item) ->
        result = true
        if charNameRegex
          result = item.name.match charNameRegex
        return result

      _getExtraChars = (char3, char4) ->
        result = ""

        if char3 is " "
          result += " space"
        else if char3
          result += " #{char3}"

        if char4 is " "
          result += " space"
        else if char4
          result += " #{char4}"

        return result

      keymap = {}
      lastIndex = @characterData.length - 1

      @characterData.forEach (item,i) =>
        return unless item.mnemonic

        if count?
          return unless i < count

        [char1, char2, char3, char4] = item.mnemonic.split("")

        reverse_mnemonic = _getReverseMnemonic(char2, char1)

        mnemonicMatched = _mnemonicMatch item, reverse_mnemonic
        charNameMatched = _charNameMatch item

        item.isMnemonic = false

        return unless charNameMatched and mnemonicMatched

        item.isMnemonic = true

        slugname = @slugify(item.name)
        commandName = "character-table:insert-#{slugname}"

        addCommand commandName, item

        char1 = "space" if char1 is " "
        char2 = "space" if char2 is " "
        extra = _getExtraChars(char3, char4)

        keymap["#{digraphKey} #{char1} #{char2}#{extra}"] = commandName

        unless extra
          if reverse_mnemonic?
            keymap["#{digraphKey} #{char2} #{char1}"] = commandName

      try
        addKeymap keymap
      catch e
        console.log e

  loadCharacters: ->
    Q.fcall =>
      rfc1345_data = fs.readFileSync path.resolve __dirname, "..", "rfc1345.txt"
      unicode_data = fs.readFileSync path.resolve __dirname, "..", "UnicodeData.txt"

      rfc1345_data = rfc1345_data.toString()
      unicode_data = unicode_data.toString()

      char_data = []

      @mnemonics = {}
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

        @mnemonics[char] = mnemonic

      for line in unicode_data.split /\n/
        row = line.split /;/
        [codePoint, name, category] = row[..2]
        #canonClass, bidiCategory, decomp, decimal,
        #digit, numeric, unicode1, comment, upperMapping, lowerMapping, titleMapping]

        unless category
          continue

        continue if category.match /^C/

        try
          char = String.fromCodePoint("0x"+codePoint)
        catch e
          console.warn "Error decoding #{number}, #{iso_name}"
          continue

        mnemonic = ""
        if char of @mnemonics
          mnemonic = @mnemonics[char]

        codePoint = "U+"+codePoint

        key = "#{codePoint} #{mnemonic} #{name}"

        char_data.push {char, codePoint, mnemonic, name, key}

      char_data

module.exports = {CharacterData}
