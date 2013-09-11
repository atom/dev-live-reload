_ = require 'underscore'
path = require 'path'
ThemeManager = require 'theme-manager'

UIWatcher = require '../lib/ui-watcher.coffee'

fdescribe "UIWatcher", ->
  themeManager = null
  uiWatcher = null

  beforeEach ->
    themeManager = new ThemeManager()
    uiWatcher = new UIWatcher({ themeManager })

  describe "when a base theme's file changes", ->
    it "reloads all the base styles", ->
      spyOn(atom, 'reloadBaseStylesheets')

      uiWatcher.baseTheme.entities[0].trigger('contents-changed')

      expect(atom.reloadBaseStylesheets).toHaveBeenCalled()
