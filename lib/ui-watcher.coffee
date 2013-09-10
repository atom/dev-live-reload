ThemeWatcher = require './theme-watcher'

module.exports =
class UIWatcher
  constructor: ({@themeManager}) ->
    for theme in @themeManager.getThemes()
      new ThemeWatcher(theme)
    @themeManager.on 'theme-added', (theme) =>
      new ThemeWatcher(theme)
