BaseThemeWatcher = require './base-theme-watcher'
PackageWatcher = require './package-watcher'

module.exports =
class UIWatcher
  constructor: () ->
    @watchers = []
    @baseTheme = @createWatcher(BaseThemeWatcher)
    @watchPackages()

  watchPackages: ->
    for pack in atom.getActivePackages()
      @createWatcher(PackageWatcher, pack) if PackageWatcher.supportsPackage(pack)

  createWatcher: (type, object) ->
    watcher = new type(object)
    watcher.on 'globals-changed', @reloadAll
    watcher.on 'destroyed', =>
      @watchers = _.without(@watchers, watcher)
    @watchers.push(watcher)
    watcher

  reloadAll: =>
    @baseTheme.reloadStylesheet()
    pack.reloadStylesheets() for pack in atom.getActivePackages() when PackageWatcher.supportsPackage(pack)
