_ = require 'underscore'
fs = require 'fs'
path = require 'path'
File = require 'file'
Directory = require 'directory'
EventEmitter = require 'event-emitter'

module.exports =
class ThemeWatcher
  _.extend @prototype, EventEmitter

  theme: null
  entities: []

  constructor: (@theme) ->
    @theme.on 'deactivated', @destroy
    @watchTheme()

  destroy: =>
    @unwatchTheme()
    @theme = null
    @entities = null
    @off()

  watchTheme: ->
    unless @theme.isFile()
      themePath = @theme.getPath()
      @watchDirectory(themePath)

      uiVarsPath = path.join(themePath, 'ui-variables.less')
      @watchGlobalFile(uiVarsPath) if fs.existsSync(uiVarsPath)

    @watchFile(stylesheet) for stylesheet in @theme.getLoadedStylesheetPaths()

    @entities

  unwatchTheme: ->
    return unless @entities
    for entity in @entities
      entity.off '.dev-live-reload'

  loadStylesheet: (stylesheetPath) ->
    @theme.loadStylesheet(stylesheetPath)

  watchDirectory: (directoryPath) ->
    entity = new Directory(directoryPath)
    entity.on 'contents-changed.dev-live-reload', =>
      @loadStylesheet(stylesheet) for stylesheet in @theme.getLoadedStylesheetPaths()
    @entities.push(entity)

  watchGlobalFile: (filePath) ->
    entity = new File(filePath)
    entity.on 'contents-changed.dev-live-reload', => @trigger('globals-changed')
    @entities.push(entity)

  watchFile: (filePath) ->
    reloadFn = => @loadStylesheet(entity.getPath())

    entity = new File(filePath)
    entity.on 'contents-changed.dev-live-reload', reloadFn
    entity.on 'removed.dev-live-reload', reloadFn
    entity.on 'moved.dev-live-reload', reloadFn
    @entities.push(entity)
