_ = require 'underscore'
fs = require 'fs'
path = require 'path'
File = require 'file'

module.exports =
class BaseThemeWatcher
  entities: []

  constructor: (name) ->
    @stylesheetsPath = path.dirname(window.resolveStylesheet('atom.less'))
    @watch()

  reloadStylesheet: =>
    atom.reloadBaseStylesheets()

  watch: ->
    filePaths = fs.readdirSync(@stylesheetsPath).filter (filePath) ->
      path.extname(filePath).indexOf('less') > -1

    for filePath in filePaths
      @watchFilePath(filePath)

  watchFilePath: (filePath) ->
    entity = new File(filePath)
    @entities.push(entity)

    entity.on 'contents-changed.dev-live-reload', @reloadStylesheet
    entity.on 'removed.dev-live-reload', @reloadStylesheet
    entity.on 'moved.dev-live-reload', @reloadStylesheet

