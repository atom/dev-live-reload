const _ = require('underscore-plus')
const fs = require('fs-plus')

const Watcher = require('./watcher')

module.exports =
class PackageWatcher extends Watcher {
  static supportsPackage(pack, type) {
    if (pack.getType() === type && pack.getStylesheetPaths().length) return true
    return false
  }

  constructor(pack) {
    super()
    this.pack = pack
    this.pack.onDidDeactivate(this.destroy)
    this.watch()
  }

  watch() {
    const watchedPaths = []
    const watchPath = stylesheet => {
      if (!_.contains(watchedPaths, stylesheet)) this.watchFile(stylesheet)
      watchedPaths.push(stylesheet)
    }

    const stylesheetsPath = this.pack.getStylesheetsPath()

    if (fs.isDirectorySync(stylesheetsPath)) this.watchDirectory(stylesheetsPath)

    const stylesheetPaths = this.pack.getStylesheetPaths()
    const onFile = stylesheetPath => stylesheetPaths.push(stylesheetPath)
    const onFolder = () => true
    fs.traverseTreeSync(stylesheetsPath, onFile, onFolder)

    for (let stylesheet of _.uniq(stylesheetPaths)) {
      watchPath(stylesheet)
    }

    return this.entities
  }

  loadStylesheet(pathName) {
    if (pathName.indexOf('variables') > -1) this.emitGlobalsChanged()
    this.loadAllStylesheets()
  }

  loadAllStylesheets() {
    console.log('Reloading package', this.pack.name)
    this.pack.reloadStylesheets()
  }
}
