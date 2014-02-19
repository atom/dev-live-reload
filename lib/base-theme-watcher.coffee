fs = require 'fs-plus'
path = require 'path'
Watcher = require './watcher'

module.exports =
class BaseThemeWatcher extends Watcher
  constructor: ->
    super()
    @stylesheetsPath = path.dirname(atom.themes.resolveStylesheet('../static/atom.less'))
    @watch()

  watch: ->
    filePaths = fs.readdirSync(@stylesheetsPath).filter (filePath) ->
      path.extname(filePath).indexOf('less') > -1

    @watchFile(path.join(@stylesheetsPath, filePath)) for filePath in filePaths

  loadStylesheet: ->
    @loadAllStylesheets()

  loadAllStylesheets: ->
    atom.themes.reloadBaseStylesheets()
