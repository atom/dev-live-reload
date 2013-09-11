_ = require 'underscore'
fs = require 'fs'
path = require 'path'
File = require 'file'
Directory = require 'directory'
EventEmitter = require 'event-emitter'

module.exports =
class Watcher
  _.extend @prototype, EventEmitter

  constructor: ->
    @entities = []

  destroy: =>
    @unwatch()
    @entities = null
    @off()

  watch: ->
    # override me

  unwatch: ->
    return unless @entities
    for entity in @entities
      entity.off '.dev-live-reload'

  loadStylesheet: (stylesheetPath) ->
    # override me

  loadAllStylesheets: ->
    # override me

  watchDirectory: (directoryPath) ->
    entity = new Directory(directoryPath)
    entity.on 'contents-changed.dev-live-reload', => @loadAllStylesheets()
    @entities.push(entity)

  watchGlobalFile: (filePath) ->
    entity = new File(filePath)
    entity.on 'contents-changed.dev-live-reload', => @trigger('globals-changed')
    @entities.push(entity)

  watchFile: (filePath) ->
    reloadFn = =>
      @loadStylesheet(entity.getPath())

    entity = new File(filePath)
    entity.on 'contents-changed.dev-live-reload', reloadFn
    entity.on 'removed.dev-live-reload', reloadFn
    entity.on 'moved.dev-live-reload', reloadFn
    @entities.push(entity)
