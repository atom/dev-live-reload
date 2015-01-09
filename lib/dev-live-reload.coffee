UIWatcher = require './ui-watcher'

module.exports =
  commandDisposable: null
  activate: (state) ->
    return unless atom.inDevMode() and not atom.inSpecMode()

    uiWatcher = null
    activatedDisposable = atom.packages.onDidActivateInitialPackages ->
      uiWatcher = new UIWatcher(themeManager: atom.themes)
      themes = (k for k, __ of uiWatcher.watchedThemes)
      packages = (k for k, __ of uiWatcher.watchedPackages)
      activatedDisposable.dispose()

    @commandDisposable = atom.commands.add 'atom-workspace', 'dev-live-reload:reload-all', ->
      uiWatcher.reloadAll()

  deactivate: ->
    @commandDisposable?.dispose()
