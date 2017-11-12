const BaseThemeWatcher = require('./base-theme-watcher')
const PackageWatcher = require('./package-watcher')

module.exports =
class UIWatcher {
  constructor () {
    this.reloadAll = this.reloadAll.bind(this)
    this.watchers = []
    this.baseTheme = this.createWatcher(new BaseThemeWatcher())
    this.watchPackages()
  }

  watchPackages () {
    this.watchedThemes = new Map()
    this.watchedPackages = new Map()
    for (const theme of atom.themes.getActiveThemes()) { this.watchTheme(theme) }
    for (const pack of atom.packages.getLoadedPackages()) { this.watchPackage(pack) }
    this.watchForPackageChanges()
  }

  watchForPackageChanges () {
    atom.themes.onDidChangeActiveThemes(() => {
      // we need to destroy all watchers as all theme packages are destroyed when a
      // theme changes.
      for (const theme of this.watchedThemes.values()) { theme.destroy() }

      this.watchedThemes.clear()
      // Rewatch everything!
      for (const theme of atom.themes.getActiveThemes()) { this.watchTheme(theme) }
    })
  }

  watchTheme (theme) {
    if (PackageWatcher.supportsPackage(theme, 'theme')) this.watchedThemes.set(theme.name, this.createWatcher(new PackageWatcher(theme)))
  }

  watchPackage (pack) {
    if (PackageWatcher.supportsPackage(pack, 'atom')) this.watchedPackages.set(pack.name, this.createWatcher(new PackageWatcher(pack)))
  }

  createWatcher (watcher) {
    watcher.onDidChangeGlobals(() => {
      console.log('Global changed, reloading all styles')
      this.reloadAll()
    })
    watcher.onDidDestroy(() => this.watchers.splice(this.watchers.indexOf(watcher), 1))
    this.watchers.push(watcher)
    return watcher
  }

  reloadAll () {
    this.baseTheme.loadAllStylesheets()
    for (const pack of atom.packages.getActivePackages()) {
      if (PackageWatcher.supportsPackage(pack, 'atom')) pack.reloadStylesheets()
    }

    for (const theme of atom.themes.getActiveThemes()) {
      if (PackageWatcher.supportsPackage(theme, 'theme')) theme.reloadStylesheets()
    }
  }

  destroy () {
    this.baseTheme.destroy()
    for (const pack of this.watchedPackages.values()) { pack.destroy() }
    for (const theme of this.watchedThemes.values()) { theme.destroy() }
  }
}
