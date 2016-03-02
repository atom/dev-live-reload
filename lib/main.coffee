UIWatcher = require './ui-watcher'

module.exports =
  commandDisposable: null
  activate: (state) ->
    return unless atom.inDevMode() and not atom.inSpecMode()

    uiWatcher = null
    activatedDisposable = atom.packages.onDidActivateInitialPackages ->
      uiWatcher = new UIWatcher(themeManager: atom.themes)
      themes = Object.keys(uiWatcher.watchedThemes)
      packages = Object.keys(uiWatcher.watchedPackages)
      activatedDisposable.dispose()

    @commandDisposable = atom.commands.add 'atom-workspace', 'dev-live-reload:reload-all', ->
      uiWatcher?.reloadAll()

  deactivate: ->
    @commandDisposable?.dispose()
