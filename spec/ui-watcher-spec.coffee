_ = require 'underscore-plus'
path = require 'path'

UIWatcher = require '../lib/ui-watcher'
PackageWatcher = require '../lib/package-watcher'

describe "UIWatcher", ->
  themeManager = null
  uiWatcher = null

  beforeEach ->
    atom.packages.packageDirPaths.push path.join(__dirname, 'fixtures')

  afterEach ->
    uiWatcher?.destroy()

  describe "when a base theme's file changes", ->
    beforeEach ->
      uiWatcher = new UIWatcher()

    it "reloads all the base styles", ->
      spyOn(atom.themes, 'reloadBaseStylesheets')

      expect(uiWatcher.baseTheme.entities[1].getPath()).toContain "#{path.sep}static#{path.sep}"

      uiWatcher.baseTheme.entities[0].emitter.emit('did-change')
      expect(atom.themes.reloadBaseStylesheets).toHaveBeenCalled()

  it "watches all the style sheets in the theme's styles folder", ->
    packagePath = path.join(__dirname, 'fixtures', 'package-with-styles-folder')

    waitsForPromise ->
      atom.packages.activatePackage(packagePath)

    runs ->
      uiWatcher = new UIWatcher()
      expect(_.last(uiWatcher.watchers).entities.length).toBe 4
      expect(_.last(uiWatcher.watchers).entities[0].getPath()).toBe path.join(packagePath, 'styles')
      expect(_.last(uiWatcher.watchers).entities[1].getPath()).toBe path.join(packagePath, 'styles', '3.css')
      expect(_.last(uiWatcher.watchers).entities[2].getPath()).toBe path.join(packagePath, 'styles', 'sub', '1.css')
      expect(_.last(uiWatcher.watchers).entities[3].getPath()).toBe path.join(packagePath, 'styles', 'sub', '2.less')

  describe "when a package stylesheet file changes", ->
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage(path.join(__dirname, 'fixtures', 'package-with-styles-manifest'))

      runs ->
        uiWatcher = new UIWatcher()

    it "reloads all package styles", ->
      pack = atom.packages.getActivePackages()[0]
      spyOn(pack, 'reloadStylesheets')

      _.last(uiWatcher.watchers).entities[1].emitter.emit('did-change')

      expect(pack.reloadStylesheets).toHaveBeenCalled()

  describe "when a package does not have a stylesheet", ->
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage("package-with-index")

      runs ->
        uiWatcher = new UIWatcher()

    it "does not create a PackageWatcher", ->
      expect(uiWatcher.watchedPackages['package-with-index']).toBeUndefined()

  describe "when a package global file changes", ->
    beforeEach ->
      atom.config.set('core.themes', ["theme-with-ui-variables", "theme-with-multiple-imported-files"])

      waitsForPromise ->
        atom.themes.activateThemes()

      runs ->
        uiWatcher = new UIWatcher()

    afterEach ->
      atom.themes.deactivateThemes()

    it "reloads every package when the variables file changes", ->
      for pack in atom.themes.getActiveThemes()
        spyOn(pack, 'reloadStylesheets')

      for entity in uiWatcher.watchedThemes['theme-with-multiple-imported-files'].entities
        varEntity = entity if entity.getPath().indexOf('variables') > -1
      varEntity.emitter.emit('did-change')

      for pack in atom.themes.getActiveThemes()
        expect(pack.reloadStylesheets).toHaveBeenCalled()

  describe "minimal theme packages", ->
    pack = null
    beforeEach ->
      atom.config.set('core.themes', ["theme-with-syntax-variables", "theme-with-index-less"])
      waitsForPromise ->
        atom.themes.activateThemes()
      runs ->
        uiWatcher = new UIWatcher()
        pack = atom.themes.getActiveThemes()[0]

    afterEach ->
      atom.themes.deactivateThemes()

    it "watches themes without a styles directory", ->
      spyOn(pack, 'reloadStylesheets')
      spyOn(atom.themes, 'reloadBaseStylesheets')

      watcher = uiWatcher.watchedThemes['theme-with-index-less']

      expect(watcher.entities.length).toBe 1

      watcher.entities[0].emitter.emit('did-change')
      expect(pack.reloadStylesheets).toHaveBeenCalled()
      expect(atom.themes.reloadBaseStylesheets).not.toHaveBeenCalled()

  describe "theme packages", ->
    pack = null
    beforeEach ->
      atom.config.set('core.themes', ["theme-with-syntax-variables", "theme-with-multiple-imported-files"])

      waitsForPromise ->
        atom.themes.activateThemes()
      runs ->
        uiWatcher = new UIWatcher()
        pack = atom.themes.getActiveThemes()[0]

    afterEach ->
      atom.themes.deactivateThemes()

    it "reloads the theme when anything within the theme changes", ->
      spyOn(pack, 'reloadStylesheets')
      spyOn(atom.themes, 'reloadBaseStylesheets')

      watcher = uiWatcher.watchedThemes['theme-with-multiple-imported-files']

      expect(watcher.entities.length).toBe 6

      watcher.entities[2].emitter.emit('did-change')
      expect(pack.reloadStylesheets).toHaveBeenCalled()
      expect(atom.themes.reloadBaseStylesheets).not.toHaveBeenCalled()

      _.last(watcher.entities).emitter.emit('did-change')
      expect(atom.themes.reloadBaseStylesheets).toHaveBeenCalled()

    it "unwatches when a theme is deactivated", ->
      atom.config.set('core.themes', [])
      waitsFor ->
        not uiWatcher.watchedThemes["theme-with-multiple-imported-files"]

    it "watches a new theme when it is deactivated", ->
      atom.config.set('core.themes', ["theme-with-syntax-variables", "theme-with-package-file"])
      waitsFor ->
        uiWatcher.watchedThemes["theme-with-package-file"]

      runs ->
        pack = atom.themes.getActiveThemes()[0]
        spyOn(pack, 'reloadStylesheets')

        expect(pack.name).toBe "theme-with-package-file"

        watcher = uiWatcher.watchedThemes["theme-with-package-file"]
        watcher.entities[2].emitter.emit('did-change')
        expect(pack.reloadStylesheets).toHaveBeenCalled()
