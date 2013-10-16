{_, fs, File, Directory, EventEmitter} = require 'atom'
{Emitter} = require 'emissary'
path = require 'path'

module.exports =
class Watcher
  Emitter.includeInto(this)

  constructor: ->
    @entities = []

  destroy: =>
    @unwatch()
    @entities = null
    @off()
    @emit('destroyed')

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
    entity.on 'contents-changed.dev-live-reload', => @emit('globals-changed')
    @entities.push(entity)

  watchFile: (filePath) ->
    reloadFn = =>
      @loadStylesheet(entity.getPath())

    entity = new File(filePath)
    entity.on 'contents-changed.dev-live-reload', reloadFn
    entity.on 'removed.dev-live-reload', reloadFn
    entity.on 'moved.dev-live-reload', reloadFn
    @entities.push(entity)
