{_} = require 'atom'
path = require 'path'

UIWatcher = require '../lib/ui-watcher.coffee'
PackageWatcher = require '../lib/package-watcher.coffee'

describe "UIWatcher", ->
  themeManager = null
  uiWatcher = null

  describe "when a base theme's file changes", ->
    beforeEach ->
      uiWatcher = new UIWatcher()

    it "reloads all the base styles", ->
      spyOn(atom, 'reloadBaseStylesheets')

      uiWatcher.baseTheme.entities[0].trigger('contents-changed')

      expect(atom.reloadBaseStylesheets).toHaveBeenCalled()

  describe "when a package stylesheet file changes", ->
    beforeEach ->
      atom.activatePackage("package-with-stylesheets-manifest")
      uiWatcher = new UIWatcher()

    it "reloads all package styles", ->
      pack = atom.getActivePackages()[0]
      spyOn(pack, 'reloadStylesheets')

      _.last(uiWatcher.watchers).entities[1].trigger('contents-changed')

      expect(pack.reloadStylesheets).toHaveBeenCalled()

  describe "when a package does not have a stylesheet", ->
    beforeEach ->
      atom.activatePackage("package-with-index")
      uiWatcher = new UIWatcher()

    it "does not create a PackageWatcher", ->
      expect(_.last(uiWatcher.watchers)).not.toBeInstanceOf PackageWatcher

  describe "theme packages", ->
    pack = null
    beforeEach ->
      atom.activatePackage("theme-with-multiple-imported-files")
      pack = atom.getActivePackages()[0]
      uiWatcher = new UIWatcher()

    it "reloads the theme when anything within the theme changes", ->
      spyOn(pack, 'reloadStylesheets')
      spyOn(atom, 'reloadBaseStylesheets')

      watcher = _.last(uiWatcher.watchers)

      expect(watcher.entities.length).toBe 6

      watcher.entities[2].trigger('contents-changed')
      expect(pack.reloadStylesheets).toHaveBeenCalled()
      expect(atom.reloadBaseStylesheets).not.toHaveBeenCalled()

      _.last(watcher.entities).trigger('contents-changed')
      expect(atom.reloadBaseStylesheets).toHaveBeenCalled()
