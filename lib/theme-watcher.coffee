File = require 'file'
Directory = require 'directory'

### Internal ###

module.exports =
class ThemeWatcher
  theme: null
  entities: []

  constructor: (@theme) ->
    @theme.on 'deactivated', @destroy
    @watchTheme()

  destroy: =>
    @unwatchTheme()
    @theme = null
    @entities = null

  watchTheme: ->
    @createEntities()
    @watchEntity(entity) for entity in @entities

  unwatchTheme: ->
    for entity in @entities
      entity.off '.dev-live-reload'

  loadStylesheet: (stylesheetPath) ->
    @theme.loadStylesheet(stylesheetPath)

  createEntities: ->
    @entities.push(new Directory(theme.stylesheetPath)) unless theme.isFile()
    for stylesheet in theme.stylesheets
      @entities.push(new File(stylesheet))
    @entities

  watchEntity: (entity) ->
    reloadFn = _.bind(@reloadStylesheet, this, entity.getPath())
    entity.on 'contents-changed.dev-live-reload', reloadFn
    entity.on 'removed.dev-live-reload', reloadFn
    entity.on 'moved.dev-live-reload', reloadFn
