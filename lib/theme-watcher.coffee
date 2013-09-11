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
      dir = new Directory(@theme.stylesheetPath)
      @watchDirectoryEntity(dir)
      @entities.push(dir)

      uiVarsPath = path.join(@theme.stylesheetPath, 'ui-variables.less')
      if fs.existsSync(uiVarsPath)
        global = new File(uiVarsPath)
        @watchGlobalEntity(global)
        @entities.push(global)

    for stylesheet in @theme.stylesheets
      file = new File(stylesheet)
      @watchFileEntity(file)
      @entities.push(file)
    @entities

  unwatchTheme: ->
    return unless @entities
    for entity in @entities
      entity.off '.dev-live-reload'

  loadStylesheet: (stylesheetPath) ->
    @theme.loadStylesheet(stylesheetPath)

  watchDirectoryEntity: (entity) ->
    reloadFn = =>
      for stylesheet in @theme.stylesheets
        @loadStylesheet(stylesheet)
    entity.on 'contents-changed.dev-live-reload', reloadFn

  watchGlobalEntity: (entity) ->
    entity.on 'contents-changed.dev-live-reload', => @trigger('globals-changed')

  watchFileEntity: (entity) ->
    reloadFn = =>
      @loadStylesheet(entity.getPath())

    entity.on 'contents-changed.dev-live-reload', reloadFn
    entity.on 'removed.dev-live-reload', reloadFn
    entity.on 'moved.dev-live-reload', reloadFn
