const UIWatcher = require('./ui-watcher')

module.exports = {
  activate (state) {
    if (!atom.inDevMode() || atom.inSpecMode()) return

    let uiWatcher = null
    this.activatedDisposable = atom.packages.onDidActivateInitialPackages(() => {
      uiWatcher = new UIWatcher({themeManager: atom.themes})
      this.commandDisposable = atom.commands.add('atom-workspace', 'dev-live-reload:reload-all', () => uiWatcher.reloadAll())
      this.activatedDisposable.dispose()
    })
  },

  deactivate () {
    if (this.activatedDisposable) this.activatedDisposable.dispose()
    if (this.commandDisposable) this.commandDisposable.dispose()
  }
}
