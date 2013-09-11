_ = require 'underscore'
path = require 'path'
ThemeManager = require 'theme-manager'

UIWatcher = require '../lib/ui-watcher.coffee'
PackageWatcher = require '../lib/package-watcher.coffee'

describe "UIWatcher", ->
  themeManager = null
  uiWatcher = null

  describe "when a base theme's file changes", ->
    beforeEach ->
      themeManager = new ThemeManager()
      uiWatcher = new UIWatcher({ themeManager })

    it "reloads all the base styles", ->
      spyOn(atom, 'reloadBaseStylesheets')

      uiWatcher.baseTheme.entities[1].trigger('contents-changed')

      expect(atom.reloadBaseStylesheets).toHaveBeenCalled()

  describe "when a package stylesheet file changes", ->
    beforeEach ->
      atom.activatePackage("package-with-stylesheets-manifest")
      themeManager = new ThemeManager()
      uiWatcher = new UIWatcher({ themeManager })

    it "reloads all package styles", ->
      pack = atom.getActivePackages()[0]
      spyOn(pack, 'reloadStylesheets')

      _.last(uiWatcher.watchers).entities[1].trigger('contents-changed')

      expect(pack.reloadStylesheets).toHaveBeenCalled()

  describe "when a package does not have a stylesheet", ->
    beforeEach ->
      atom.activatePackage("package-with-index")
      themeManager = new ThemeManager()
      uiWatcher = new UIWatcher({ themeManager })

    it "does not create a PackageWatcher", ->
      expect(_.last(uiWatcher.watchers)).not.toBeInstanceOf PackageWatcher
