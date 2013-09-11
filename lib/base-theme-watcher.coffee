fs = require 'fs'
path = require 'path'

Watcher = require './watcher'

module.exports =
class BaseThemeWatcher extends Watcher
  constructor: ->
    super()
    @stylesheetsPath = path.dirname(window.resolveStylesheet('atom.less'))
    @watch()

  watch: ->
    filePaths = fs.readdirSync(@stylesheetsPath).filter (filePath) ->
      path.extname(filePath).indexOf('less') > -1

    @watchFile(filePath) for filePath in filePaths

  loadStylesheet: ->
    @loadAllStylesheets()

  loadAllStylesheets: ->
    atom.reloadBaseStylesheets()
