### This package is now a part of the [core Atom repository](https://github.com/atom/atom/tree/master/packages/dev-live-reload), please direct all issues and pull requests there in the future!

---

# Dev Live Reload package
[![OS X Build Status](https://travis-ci.org/atom/dev-live-reload.svg?branch=master)](https://travis-ci.org/atom/dev-live-reload) [![Windows Build Status](https://ci.appveyor.com/api/projects/status/g3sd27ylba1fun1v/branch/master?svg=true)](https://ci.appveyor.com/project/Atom/dev-live-reload/branch/master) [![Dependency Status](https://david-dm.org/atom/dev-live-reload.svg)](https://david-dm.org/atom/dev-live-reload)

This live reloads the Atom `.less` files. You edit styles and they are magically reflected in any running Atom windows. Magic! :tophat: :sparkles: :rabbit2:

Installed by default on Atom windows running in dev mode. Use the "Application: Open Dev" command to open a new dev mode window.

Use <kbd>meta-shift-ctrl-r</kbd> to reload all core and package stylesheets.

This package is __experimental__, it does not handle the following:

* File additions to a theme. New files will not be watched.

![gif](https://f.cloud.github.com/assets/69169/1387004/d2dc45f2-3b84-11e3-877e-cac8c51e9702.gif)
