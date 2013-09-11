ThemeWatcher = require './theme-watcher'
BaseThemeWatcher = require './base-theme-watcher'

module.exports =
class UIWatcher
  constructor: ({@themeManager}) ->
    @baseTheme = new BaseThemeWatcher()
    for theme in @themeManager.getActiveThemes()
      @createThemeWatcher(theme)
    @themeManager.on 'theme-activated', (theme) =>
      @createThemeWatcher(theme)

  createThemeWatcher: (theme) ->
    watcher = new ThemeWatcher(theme)
    watcher.on 'globals-changed', @reloadAll
    watcher

  reloadAll: =>
    @baseTheme.reloadStylesheet()
    theme.load() for theme in atom.themes.getThemes()
