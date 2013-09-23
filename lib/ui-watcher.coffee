BaseThemeWatcher = require './base-theme-watcher'
PackageWatcher = require './package-watcher'

module.exports =
class UIWatcher
  constructor: () ->
    @watchers = []
    @baseTheme = @createWatcher(BaseThemeWatcher)
    @watchPackages()

  watchPackages: ->
    @watchedPackages = {}
    for pack in atom.themes.getActiveThemes()
      @watchedPackages[pack.name] = @createWatcher(PackageWatcher, pack) if PackageWatcher.supportsPackage(pack)

    for pack in atom.getActivePackages()
      @watchedPackages[pack.name] = @createWatcher(PackageWatcher, pack) if PackageWatcher.supportsPackage(pack)

  watchForPackageChanges: ->
    #config.observe 'core.themes', (themeNames) =>

  createWatcher: (type, object) ->
    watcher = new type(object)
    watcher.on 'globals-changed', @reloadAll
    watcher.on 'destroyed', =>
      @watchers = _.without(@watchers, watcher)
    @watchers.push(watcher)
    watcher

  reloadAll: =>
    @baseTheme.loadAllStylesheets()
    pack.reloadStylesheets() for pack in atom.getActivePackages() when PackageWatcher.supportsPackage(pack)

  destroy: ->
    @baseTheme.destroy()
    for name, watcher of @watchedPackages
      watcher.destroy()
