UIWatcher = require './ui-watcher'

module.exports =
  activate: (state) ->
    return unless atom.inDevMode() and not atom.inSpecMode()

    uiWatcher = null

    atom.packages.once 'activated', ->
      uiWatcher = new UIWatcher
        themeManager: atom.themes

    rootView.command 'dev-live-reload:reload-all', ->
      console.log 'Reloading all styles!'
      uiWatcher.reloadAll()
