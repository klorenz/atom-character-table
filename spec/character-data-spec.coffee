{CharacterData} = require "../lib/character-data.coffee"


describe "CharacterData", ->
  charData = null

  beforeEach ->
    charData = new CharacterData

  it "can load all character data", ->
    waitsForPromise ->
      charData.initialized

    runs ->
      expect(charData.characterData.length).toBe 24212

  it "can setup mnemonics", ->
    waitsForPromise ->
      charData.initialized

    ourKeymap = null
    ourCommands = []

    _addKeymap = (keymap) ->
      ourKeymap = keymap

    _addCommand = (name, item) ->
      ourCommands.push {name, item}

    runs ->
      charData.setupMnemonics {
          mnemonicRegex: null
          charNameRegex: /hiragana/i
          addCommand: _addCommand
          addKeymap: _addKeymap
        }

      expect(ourCommands.length).toBe 89
