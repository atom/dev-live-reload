{File, Directory} = require 'atom'
{CompositeDisposable, Emitter} = require 'atom'
path = require 'path'

module.exports =
class Watcher
  constructor: ->
    @emitter = new Emitter
    @disposables = new CompositeDisposable
    @entities = []

  onDidDestroy: (callback) ->
    @emitter.on 'did-destroy', callback

  onDidChangeGlobals: (callback) ->
    @emitter.on 'did-change-globals', callback

  destroy: =>
    @disposables.dispose()
    @entities = null
    @emitter.emit('did-destroy')
    @emitter.dispose()

  watch: ->
    # override me

  loadStylesheet: (stylesheetPath) ->
    # override me

  loadAllStylesheets: ->
    # override me

  emitGlobalsChanged: ->
    @emitter.emit('did-change-globals')

  watchDirectory: (directoryPath) ->
    return if @isInAsarArchive(directoryPath)
    entity = new Directory(directoryPath)
    @disposables.add entity.onDidChange => @loadAllStylesheets()
    @entities.push(entity)

  watchGlobalFile: (filePath) ->
    entity = new File(filePath)
    @disposables.add entity.onDidChange => @emitGlobalsChanged()
    @entities.push(entity)

  watchFile: (filePath) ->
    return if @isInAsarArchive(filePath)
    reloadFn = =>
      @loadStylesheet(entity.getPath())

    entity = new File(filePath)
    @disposables.add entity.onDidChange(reloadFn)
    @disposables.add entity.onDidDelete(reloadFn)
    @disposables.add entity.onDidRename(reloadFn)
    @entities.push(entity)

  isInAsarArchive: (pathToCheck) ->
    {resourcePath} = atom.getLoadSettings()
    pathToCheck.startsWith("#{resourcePath}#{path.sep}") and path.extname(resourcePath) is '.asar'
