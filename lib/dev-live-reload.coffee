UIWatcher = require './ui-watcher'

module.exports =
  activate: (state) ->
    new UIWatcher
      themeManager: atom.themes

