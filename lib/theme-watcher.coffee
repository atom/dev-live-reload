fs = require 'fs'
path = require 'path'

Watcher = require './watcher'

module.exports =
class ThemeWatcher extends Watcher
  constructor: (@theme) ->
    super()
    @theme.on 'deactivated', @destroy
    @watch()

  destroy: =>
    super()
    @theme = null

  watch: ->
    unless @theme.isFile()
      themePath = @theme.getPath()
      @watchDirectory(themePath)

      uiVarsPath = path.join(themePath, 'ui-variables.less')
      @watchGlobalFile(uiVarsPath) if fs.existsSync(uiVarsPath)

    @watchFile(stylesheet) for stylesheet in @theme.getStylesheetPaths()

    @entities

  loadStylesheet: (stylesheetPath) ->
    @theme.loadStylesheet(stylesheetPath)

  loadAllStylesheets: =>
    @loadStylesheet(stylesheet) for stylesheet in @theme.getStylesheetPaths()
