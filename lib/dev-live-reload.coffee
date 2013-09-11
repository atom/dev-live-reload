UIWatcher = require './ui-watcher'

module.exports =
  activate: (state) ->
    new UIWatcher
      themeManager: atom.themes

    rootView.command 'dev-live-reload:reload-all', ->
      uiWatcher.reloadAll()

