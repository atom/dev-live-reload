UIWatcher = require './ui-watcher'

module.exports =
  activate: (state) ->
    return unless atom.inDevMode() and not atom.inSpecMode()

    uiWatcher = null
    atom.packages.once 'activated', ->
      uiWatcher = new UIWatcher(themeManager: atom.themes)
      themes = (k for k, __ of uiWatcher.watchedThemes)
      packages = (k for k, __ of uiWatcher.watchedPackages)

    atom.workspaceView.command 'dev-live-reload:reload-all', ->
      uiWatcher.reloadAll()
