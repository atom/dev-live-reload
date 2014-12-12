{File, Directory} = require 'pathwatcher'
{Emitter} = require 'atom'
path = require 'path'

module.exports =
class Watcher
  constructor: ->
    @emitter = new Emitter
    @entities = []

  onDidDestroy: (callback) ->
    @emitter.on 'did-destroy', callback

  onDidChangeGlobals: (callback) ->
    @emitter.on 'did-change-globals', callback

  destroy: =>
    @unwatch()
    @entities = null
    @emitter.emit('did-destroy')
    @emitter.dispose()

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

  emitGlobalsChanged: ->
    @emitter.emit('did-change-globals')

  watchDirectory: (directoryPath) ->
    entity = new Directory(directoryPath)
    entity.on 'contents-changed.dev-live-reload', => @loadAllStylesheets()
    @entities.push(entity)

  watchGlobalFile: (filePath) ->
    entity = new File(filePath)
    entity.on 'contents-changed.dev-live-reload', => @emitGlobalsChanged()
    @entities.push(entity)

  watchFile: (filePath) ->
    reloadFn = =>
      @loadStylesheet(entity.getPath())

    entity = new File(filePath)
    entity.on 'contents-changed.dev-live-reload', reloadFn
    entity.on 'removed.dev-live-reload', reloadFn
    entity.on 'moved.dev-live-reload', reloadFn
    @entities.push(entity)
