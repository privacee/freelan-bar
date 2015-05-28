#!/usr/bin/env python

import sys
import rumps

import freelan_configurator

class FreelanStatusBarApp(rumps.App):
    #def __init__(self):
    #    super(CloudCryptorStatusBarApp, self).__init__("CloudCryptor")
    #    self.title="CloudCryptor"
    #    self.icon="cloudcryptor20x20.png"
    #    self.menu = ["Active", "Preferences", "Status"]

    @rumps.clicked("Active")
    def onoff(self, sender):
        sender.state = not sender.state

    @rumps.clicked("Preferences")
    def prefs(self, _):
        rumps.alert("No preferences available!")

    @rumps.clicked("Status")
    def status(self, _):
        rumps.notification("Freelan", "Status Notification", "Nothing to say")

def main(argv):
    fl_app = FreelanStatusBarApp("Freelan")

    fl_app.icon="freelan-bar_st_bw.png"
    #fl_app.icon="freelan-bar_st.png"
    #fl_app.icon="freelan-bar.png"

    fl_app.run()


if __name__ == "__main__":
    main(sys.argv[1:])

