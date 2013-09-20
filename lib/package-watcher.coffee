{fs} = require 'atom'

Watcher = require './watcher'

module.exports =
class PackageWatcher extends Watcher
  @supportsPackage: (pack) ->
    pack.getType() == 'atom' and fs.isDirectorySync(pack.getStylesheetsPath())

  constructor: (@pack) ->
    super()
    @pack.on 'deactivated', @destroy
    @watch()

  watch: ->
    @watchDirectory(@pack.getStylesheetsPath())
    @watchFile(stylesheet) for stylesheet in @pack.getStylesheetPaths()
    @entities

  loadStylesheet: ->
    @loadAllStylesheets()

  loadAllStylesheets: =>
    @pack.reloadStylesheets()
