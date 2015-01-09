_ = require 'underscore-plus'
BaseThemeWatcher = require './base-theme-watcher'
PackageWatcher = require './package-watcher'

module.exports =
class UIWatcher
  constructor: ->
    @watchers = []
    @baseTheme = @createWatcher(BaseThemeWatcher)
    @watchPackages()

  watchPackages: ->
    @watchedThemes = {}
    @watchedPackages = {}
    @watchTheme(theme) for theme in atom.themes.getActiveThemes()
    @watchPackage(pack) for pack in atom.packages.getLoadedPackages()
    @watchForPackageChanges()

  watchForPackageChanges: ->
    atom.themes.onDidChangeActiveThemes =>
      # we need to destroy all watchers as all theme packages are destroyed when a
      # theme changes.
      watcher.destroy() for name, watcher of @watchedThemes

      @watchedThemes = {}
      # Rewatch everything!
      @watchTheme(theme) for theme in atom.themes.getActiveThemes()

      themes = (k for k, __ of @watchedThemes)

      null

  watchTheme: (theme) ->
    @watchedThemes[theme.name] = @createWatcher(PackageWatcher, theme) if PackageWatcher.supportsPackage(theme, 'theme')

  watchPackage: (pack) ->
    @watchedPackages[pack.name] = @createWatcher(PackageWatcher, pack) if PackageWatcher.supportsPackage(pack, 'atom')

  createWatcher: (type, object) ->
    watcher = new type(object)
    watcher.onDidChangeGlobals =>
      console.log 'Global changed, reloading all styles'
      @reloadAll()
    watcher.onDidDestroy =>
      @watchers = _.without(@watchers, watcher)
    @watchers.push(watcher)
    watcher

  reloadAll: =>
    @baseTheme.loadAllStylesheets()
    pack.reloadStylesheets() for pack in atom.packages.getActivePackages() when PackageWatcher.supportsPackage(pack, 'atom')
    pack.reloadStylesheets() for pack in atom.themes.getActiveThemes() when PackageWatcher.supportsPackage(pack, 'theme')

  destroy: ->
    @baseTheme.destroy()
    watcher.destroy() for name, watcher of @watchedPackages
    watcher.destroy() for name, watcher of @watchedThemes
