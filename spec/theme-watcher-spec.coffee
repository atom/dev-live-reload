_ = require 'underscore'
$ = require 'jquery'
fsUtils = require 'fs-utils'
path = require 'path'
Theme = require 'theme'

ThemeWatcher = require '../lib/theme-watcher.coffee'

fdescribe "ThemeWatcher", ->
  theme = null
  watcher = null

  describe "when the theme does not have ui-variables", ->
    beforeEach ->
      themePath = project.resolve('themes/theme-with-package-file')
      theme = new Theme(themePath)
      theme.load()
      watcher = new ThemeWatcher(theme)

    afterEach ->
      theme.deactivate()

    it "does not have a ui-variables entity", ->
      entity = null
      for e in watcher.entities
        entity = e if e.getPath().indexOf('ui-variables.less') > -1
      expect(entity).toBe null

  describe "when the theme has ui-variables", ->
    beforeEach ->
      themePath = project.resolve('themes/theme-with-ui-variables')
      theme = new Theme(themePath)
      theme.load()
      watcher = new ThemeWatcher(theme)

    afterEach ->
      theme.deactivate()

    describe "when file is updated", ->
      it "reloads applied css", ->
        spyOn(window, 'applyStylesheet')

        entity = _.last(watcher.entities)
        entity.trigger('contents-changed')

        expect(window.applyStylesheet).toHaveBeenCalled()
        expect(window.applyStylesheet.mostRecentCall.args[0]).toBe entity.getPath()

      it "fires globals-changed event when ui-variables is modified", ->
        spyOn(window, 'applyStylesheet')
        watcher.on 'globals-changed', handler = jasmine.createSpy()

        entity = null
        for e in watcher.entities
          entity = e if e.getPath().indexOf('ui-variables.less') > -1

        entity.trigger('contents-changed')

        expect(window.applyStylesheet).not.toHaveBeenCalled()
        expect(handler).toHaveBeenCalled()

    describe "theme is destroyed", ->
      it "removes all the subscriptions from the entity", ->
        entity = _.last(watcher.entities)

        expect(entity.subscriptionCount()).toBe 3
        theme.deactivate()
        expect(entity.subscriptionCount()).toBe 0
