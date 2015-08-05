CharacterTableView = require '../lib/character-table-view'

describe "CharacterTableView", ->
  originalAtomCharacterTableConfig = atom.config.get('character-table')
  view = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('character-table')

    waitsForPromise ->
      activationPromise.then (pkg) ->
        view = pkg.mainModule.characterTableView

  afterEach ->
    atom.config.set 'character-table', originalAtomCharacterTableConfig

  it "can filter character data", ->
    #expect(view.)

  it "has one valid test", ->
    expect("life").toBe "easy"
