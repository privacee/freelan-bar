freelan-bar
===========

A little statusbar for http://freelan.org/ on OSX

This was forked off a project called `syncthing-bar`, which you can find here: https://github.com/m0ppers/syncthing-bar

## What will it do?

`freelan-bar` has `freelan` bundled. When clicking on the statusbar icon it will offer quick access to basic `freelan` info and **some selected** functionality.

## Requirements

OS X 10.10 is required

**Everything** you need to run `freelan` is required for `freelan-bar`
http://www.freelan.org/download.html#osx

Since TUN/TAP is required for `freelan`, it is also required for `freelan-bar`
http://tuntaposx.sourceforge.net/index.xhtml


## To build/run

1. `git clone` the repository in X-Code or through the command-line
2. Download freelan from http://freelan.org/
3. Extract freelan from the provided package (e.g. using [pacifist](http://charlessoft.com))
4. Locate the `freelan` binary as well as the `freelan.cfg` config file and extract them
5. Copy the binary and config file to your `freelan-bar` source repository in the folder `freelan`
6. Adjust the config to your requirements (add contacts, etc.)
7. Open X-Code (binary/freelan should NOT be marked RED anymore)
8. Hit the fancy play button :S
9. it SHOULD run :S

## Demo :O

![alt tag](https://privacee.github.io/freelan-bar.gif)

## Caveats

`freelan-bar` is intended to provide quick access to common functionality and provide a simple user interface.
Generally, the intended `freelan` functionality should still be edited inside the `freelan` config file.
Please see the official `freelan` website for documentation of the latest features.

## Installation Package

The latest release can be found on the [releases tab](https://github.com/privacee/freelan-bar/releases)
