const _ = require('underscore-plus')
const BaseThemeWatcher = require('./base-theme-watcher')
const PackageWatcher = require('./package-watcher')

module.exports =
class UIWatcher {
  constructor() {
    this.reloadAll = this.reloadAll.bind(this)
    this.watchers = []
    this.baseTheme = this.createWatcher(BaseThemeWatcher)
    this.watchPackages()
  }

  watchPackages() {
    this.watchedThemes = {}
    this.watchedPackages = {}
    for (const theme of atom.themes.getActiveThemes()) { this.watchTheme(theme) }
    for (const pack of atom.packages.getLoadedPackages()) { this.watchPackage(pack) }
    this.watchForPackageChanges()
  }

  watchForPackageChanges() {
    atom.themes.onDidChangeActiveThemes(() => {
      // we need to destroy all watchers as all theme packages are destroyed when a
      // theme changes.
      for (const name in this.watchedThemes) { this.watchedThemes[name].destroy() }

      this.watchedThemes = {}
      // Rewatch everything!
      for (const theme of atom.themes.getActiveThemes()) { this.watchTheme(theme) }
    })
  }

  watchTheme(theme) {
    if (PackageWatcher.supportsPackage(theme, 'theme')) this.watchedThemes[theme.name] = this.createWatcher(PackageWatcher, theme)
  }

  watchPackage(pack) {
    if (PackageWatcher.supportsPackage(pack, 'atom')) this.watchedPackages[pack.name] = this.createWatcher(PackageWatcher, pack)
  }

  createWatcher(type, object) {
    const watcher = new type(object)
    watcher.onDidChangeGlobals(() => {
      console.log('Global changed, reloading all styles')
      this.reloadAll()
    })
    watcher.onDidDestroy(() => this.watchers = _.without(this.watchers, watcher))
    this.watchers.push(watcher)
    return watcher
  }

  reloadAll() {
    this.baseTheme.loadAllStylesheets()
    for (const pack of atom.packages.getActivePackages()) {
      if (PackageWatcher.supportsPackage(pack, 'atom')) pack.reloadStylesheets()
    }

    for (const theme of atom.themes.getActiveThemes()) {
      if (PackageWatcher.supportsPackage(theme, 'theme')) theme.reloadStylesheets()
    }
  }

  destroy() {
    this.baseTheme.destroy()
    for (const name in this.watchedPackages) { this.watchedPackages[name].destroy() }
    for (const name in this.watchedThemes) { this.watchedThemes[name].destroy() }
  }
}
