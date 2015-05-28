#!/bin/sh

xcodebuild install
pkgbuild --analyze --root /tmp/freelan-bar.dst freelan-bar.plist
pkgbuild --root /tmp/freelan-bar.dst --component-plist freelan-bar.plist --scripts scripts --version $1 syncthing-bar-$1.pkg
