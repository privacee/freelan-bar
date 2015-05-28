//
//  AppDelegate.swift
//  freelan-bar
//
//  Created by Andreas Streichardt on 12.12.14.
//  Copyright (c) 2014 Andreas Streichardt. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    //lazy var settingsWindowController = SettingsWindowController(windowNibName: "Settings")
    var runner : UnisonRunner?
    var unisonBar : UnisonBar?
    var log : UnisonLog = UnisonLog()
    
    func applicationWillFinishLaunching(aNotification: NSNotification?) {
        NSApp.setActivationPolicy(NSApplicationActivationPolicy.Accessory)
    }
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        unisonBar = UnisonBar(log: log)
        runner = UnisonRunner(log: log)
        let result = runner!.ensureRunning()
        if (result != nil) {
            let alert = NSAlert()
            alert.addButtonWithTitle("Ok :(")
            alert.messageText = "Got a fatal error: \(result!) :( Exiting"
            alert.alertStyle = NSAlertStyle.WarningAlertStyle
            let response = alert.runModal()
            self.quit()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tooManyErrors:", name: TooManyErrorsNotification, object: runner)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contactsDetermined:", name: ContactsDetermined, object: runner)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "httpChanged:", name: HttpChanged, object: runner)
    }
    
    func stop() {
        runner?.stop()
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // mop: i don't get it .... this will only get called when quitting via UI. SIGTERM will NOT land here and i fail installing a proper signal handler :|
        self.stop()
    }
        
    func settingsAction(sender : AnyObject) {
        //settingsWindowController.showWindow(sender)
    }
    
    func quitAction(sender : AnyObject) {
        let alert = NSAlert()
        alert.addButtonWithTitle("Yes")
        alert.addButtonWithTitle("Cancel")
        alert.messageText = "Are you sure you want to quit?"
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        
        let response = alert.runModal()
        if (response == NSAlertFirstButtonReturn) {
            self.quit()
        }
    }
    
    func tooManyErrors(sender : AnyObject) {
        let alert = NSAlert()
        alert.addButtonWithTitle("Ok :(")
        alert.messageText = "Freelan could not run. There were too many errors. Check log, and restart :("
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        
        let response = alert.runModal()
    }
    
    func httpChanged(notification: NSNotification) {
        if let info = notification.userInfo {
            var host = notification.userInfo!["host"] as! NSString
            var port = notification.userInfo!["port"] as! NSString
            
            freelanBar!.enableUIOpener("http://\(host):\(port)")
        } else {
            freelanBar!.disableUIOpener()
        }
    }
    
    func contactsDetermined(notification: NSNotification) {
        if let contacts = notification.userInfo!["contacts"] as? Array<FreelanContact> {
            freelanBar!.setContacts(contacts)
        }
    }
    
    func quit() {
        NSApplication.sharedApplication().terminate(self)
    }

}
