const UIWatcher = require('./ui-watcher')

module.exports = {
  activate (state) {
    if (!atom.inDevMode() || atom.inSpecMode()) return

    let uiWatcher = null
    const activatedDisposable = atom.packages.onDidActivateInitialPackages(() => {
      uiWatcher = new UIWatcher({themeManager: atom.themes})
      activatedDisposable.dispose()
    })

    this.commandDisposable = atom.commands.add('atom-workspace', 'dev-live-reload:reload-all', () => uiWatcher && uiWatcher.reloadAll())
  },

  deactivate () {
    if (this.commandDisposable) this.commandDisposable.dispose()
  }
}
