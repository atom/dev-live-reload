{_, fs} = require 'atom'
path = require 'path'

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
    watchedPaths = []
    watchPath = (stylesheet) =>
      @watchFile(stylesheet) unless _.contains(watchedPaths, stylesheet)
      watchedPaths.push(stylesheet)

    stylesheetsPath = @pack.getStylesheetsPath()

    @watchDirectory(stylesheetsPath)

    watchPath(stylesheet) for stylesheet in @pack.getStylesheetPaths()

    stylesheetPaths = (path.join(stylesheetsPath, p) for p in fs.readdirSync(stylesheetsPath))
    watchPath(stylesheet) for stylesheet in stylesheetPaths

    @entities

  loadStylesheet: (pathName) ->
    @trigger('globals-changed') if pathName.indexOf('ui-variables') > -1
    @loadAllStylesheets()

  loadAllStylesheets: =>
    @pack.reloadStylesheets()
