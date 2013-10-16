{$} = require 'atom'
UIWatcher = require './ui-watcher'

module.exports =
  activate: (state) ->
    return unless atom.inDevMode()

    uiWatcher = null

    # HACK: I need an actvation event when the ui or packages are all loaded.
    # It cant watch all the packages until they are all loaded.
    createUIWatcher = ->
      uiWatcher = new UIWatcher
        themeManager: atom.themes
      $(window).off 'focus', createUIWatcher
    $(window).on 'focus', createUIWatcher

    rootView.command 'dev-live-reload:reload-all', ->
      console.log 'Reloading all styles!'
      uiWatcher.reloadAll()
