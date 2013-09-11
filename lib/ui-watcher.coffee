BaseThemeWatcher = require './base-theme-watcher'
ThemeWatcher = require './theme-watcher'
PackageWatcher = require './package-watcher'

module.exports =
class UIWatcher
  constructor: ({@themeManager}) ->
    @watchers = []
    @baseTheme = @createWatcher(BaseThemeWatcher)
    @watchThemes()
    @watchPackages()

  watchThemes: ->
    for theme in @themeManager.getActiveThemes()
      @createWatcher(ThemeWatcher, theme)

    @themeManager.on 'theme-activated', (theme) =>
      @createWatcher(ThemeWatcher, theme)

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
    theme.load() for theme in atom.themes.getActiveThemes()
    pack.reloadStylesheets() for pack in atom.getActivePackages() when PackageWatcher.supportsPackage(pack)
