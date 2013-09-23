{_} = require 'atom'
BaseThemeWatcher = require './base-theme-watcher'
PackageWatcher = require './package-watcher'

module.exports =
class UIWatcher
  constructor: () ->
    @watchers = []
    @baseTheme = @createWatcher(BaseThemeWatcher)
    @watchPackages()

  watchPackages: ->
    @watchedThemes = {}
    @watchedPackages = {}
    @watchTheme(theme) for theme in atom.themes.getActiveThemes()
    @watchPackage(pack) for pack in atom.getActivePackages()
    @watchForPackageChanges()

  watchForPackageChanges: ->
    config.observe 'core.themes', (themeNames) =>
      # we need to destroy all watchers as all theme packages are destroyed when a
      # theme changes.
      watcher.destroy() for name, watcher of @watchedThemes

      @watchedThemes = {}

      # Rewatch everything!
      @watchTheme(theme) for theme in atom.themes.getActiveThemes()

      null

  watchTheme: (theme) ->
    @watchedThemes[theme.name] = @createWatcher(PackageWatcher, theme) if PackageWatcher.supportsPackage(theme)

  watchPackage: (pack) ->
    @watchedPackages[pack.name] = @createWatcher(PackageWatcher, pack) if PackageWatcher.supportsPackage(pack)

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
    pack.reloadStylesheets() for pack in atom.themes.getActiveThemes() when PackageWatcher.supportsPackage(pack)

  destroy: ->
    @baseTheme.destroy()
    watcher.destroy() for name, watcher of @watchedPackages
    watcher.destroy() for name, watcher of @watchedThemes
