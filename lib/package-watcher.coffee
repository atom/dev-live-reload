fsUtils = require 'fs-utils'
AtomPackage = require 'atom-package'

Watcher = require './watcher'

module.exports =
class PackageWatcher extends Watcher
  @supportsPackage: (pack) ->
    pack instanceof AtomPackage and fsUtils.isDirectorySync(pack.getStylesheetsPath())

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
