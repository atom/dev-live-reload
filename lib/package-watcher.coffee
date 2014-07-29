_ = require 'underscore-plus'
fs = require 'fs-plus'
path = require 'path'

Watcher = require './watcher'

module.exports =
class PackageWatcher extends Watcher
  @supportsPackage: (pack, type) ->
    return true if pack.getType() == type and pack.getStylesheetPaths().length
    false

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

    @watchDirectory(stylesheetsPath) if fs.isDirectorySync(stylesheetsPath)

    stylesheetPaths = @pack.getStylesheetPaths()
    if fs.existsSync(stylesheetsPath)
      stylesheetPaths = stylesheetPaths.concat(path.join(stylesheetsPath, p) \
      for p in fs.listTreeSync(stylesheetsPath) when p.substr(-5) == '.less') and fs.isFileSync(p)

    watchPath(stylesheet) for stylesheet in _.uniq(stylesheetPaths)

    @entities

  loadStylesheet: (pathName) ->
    @emit('globals-changed') if pathName.indexOf('variables') > -1
    @loadAllStylesheets()

  loadAllStylesheets: =>
    console.log 'Reloading package', @pack.name
    @pack.reloadStylesheets()
