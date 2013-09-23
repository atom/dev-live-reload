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

    afterEach ->
      uiWatcher.destroy()

    it "reloads all the base styles", ->
      spyOn(atom, 'reloadBaseStylesheets')

      expect(uiWatcher.baseTheme.entities[1].getPath()).toContain '/static/'

      uiWatcher.baseTheme.entities[0].trigger('contents-changed')
      expect(atom.reloadBaseStylesheets).toHaveBeenCalled()

  describe "when a package stylesheet file changes", ->
    beforeEach ->
      atom.activatePackage("package-with-stylesheets-manifest")
      uiWatcher = new UIWatcher()

    afterEach ->
      uiWatcher.destroy()

    it "reloads all package styles", ->
      pack = atom.getActivePackages()[0]
      spyOn(pack, 'reloadStylesheets')

      _.last(uiWatcher.watchers).entities[1].trigger('contents-changed')

      expect(pack.reloadStylesheets).toHaveBeenCalled()

  describe "when a package does not have a stylesheet", ->
    beforeEach ->
      atom.activatePackage("package-with-index")
      uiWatcher = new UIWatcher()

    afterEach ->
      uiWatcher.destroy()

    it "does not create a PackageWatcher", ->
      expect(_.last(uiWatcher.watchers)).not.toBeInstanceOf PackageWatcher

  describe "theme packages", ->
    pack = null
    beforeEach ->
      config.set('core.themes', ["theme-with-multiple-imported-files"])
      atom.themes.load()
      pack = atom.themes.getActiveThemes()[0]
      uiWatcher = new UIWatcher()

    afterEach ->
      uiWatcher.destroy()

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

    it "unwatches when a theme is deactivated", ->
      config.set('core.themes', [])
      expect(uiWatcher.watchedThemes["theme-with-multiple-imported-files"]).not.toBeDefined()

    it "watches a new theme when it is deactivated", ->
      config.set('core.themes', ["theme-with-package-file"])
      expect(uiWatcher.watchedThemes["theme-with-package-file"]).toBeDefined()

      pack = atom.themes.getActiveThemes()[0]
      spyOn(pack, 'reloadStylesheets')

      expect(pack.name).toBe "theme-with-package-file"

      watcher = uiWatcher.watchedThemes["theme-with-package-file"]
      watcher.entities[2].trigger('contents-changed')
      expect(pack.reloadStylesheets).toHaveBeenCalled()
