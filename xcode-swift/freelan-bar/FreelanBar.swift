//
//  FreelanBar.swift
//  freelan-bar
//
//  Created by Andreas Streichardt on 14.12.14.
//  Copyright (c) 2014 mop. All rights reserved.
//

import Cocoa

let ContactTag = 1

class FreelanBar: NSObject {
    var statusBar: NSStatusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu : NSMenu = NSMenu()
    var openUIItem: NSMenuItem
    var url: NSString?
    var controller: LogWindowController?
    var log : FreelanLog
    
    init(log : FreelanLog) {
        self.log = log
        //Add statusBarItem
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        
        var size = NSSize(width: 18, height: 18)
        var icon = NSImage(named: "freelan-bar")
        // mop: that is the preferred way but the image is currently not drawn as it has to be and i am not an artist :(
        //icon?.setTemplate(true)
        icon?.size = size
        statusBarItem.image = icon
        
        menu.autoenablesItems = false
        
        openUIItem = NSMenuItem()
        openUIItem.title = "Open UI"
        openUIItem.action = Selector("openUIAction:")
        openUIItem.enabled = false
        menu.addItem(openUIItem)
        
        menu.addItem(NSMenuItem.separatorItem())
        
        var openLogItem : NSMenuItem = NSMenuItem()
        openLogItem.title = "Show Log"
        openLogItem.action = Selector("openLogAction:")
        openLogItem.enabled = true
        menu.addItem(openLogItem)
        
        var quitItem : NSMenuItem = NSMenuItem()
        quitItem.title = "Quit"
        quitItem.action = Selector("quitAction:")
        quitItem.enabled = true
        menu.addItem(quitItem)
        
        super.init()
        // mop: todo: move the remaining actions as well
        openUIItem.target = self
        openLogItem.target = self
    }
    
    func enableUIOpener(uiUrl: NSString) {
        url = uiUrl
        openUIItem.enabled = true
    }
    
    func disableUIOpener() {
        openUIItem.enabled = false
    }
    
    func setContacts(contacts: Array<FreelanContact>) {
        // mop: should probably check if anything changed ... but first simple stupid :S
        var item = menu.itemWithTag(ContactTag)
        while (item != nil) {
            menu.removeItem(item!)
            item = menu.itemWithTag(ContactTag)
        }
        
        // mop: maybe findByTag instead of hardcoded number?
        var startInsertIndex = 2
        var contactCount = 0
        for contact in contacts {
            var contactItem : NSMenuItem = NSMenuItem()
            contactItem.title = "Open \(contact.id) in Finder"
            contactItem.representedObject = contact
            contactItem.action = Selector("openContactAction:")
            contactItem.enabled = true
            contactItem.tag = ContactTag
            contactItem.target = self
            menu.insertItem(contactItem, atIndex: startInsertIndex + contactCount++)
        }
        
        // mop: only add if there were contacts (we already have a separator after "Open UI")
        if (contactCount > 0) {
            var lowerSeparator = NSMenuItem.separatorItem()
            // mop: well a bit hacky but we need to clear this one as well ;)
            lowerSeparator.tag = ContactTag
            menu.insertItem(lowerSeparator, atIndex: startInsertIndex + contactCount)
        }
    }
    
    func openUIAction(sender: AnyObject) {
        if (url != nil) {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: url! as String)!)
        }
    }
    
    func openContactAction(sender: AnyObject) {
        let contact = (sender as! NSMenuItem).representedObject as! FreelanContact
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "file://\(contact.address)")!)
    }
    
    func openLogAction(sender: AnyObject) {
        // mop: recreate even if it exists (not sure if i manually need to close and cleanup :S)
        // seems wrong to me but works (i want to view current log output :S)
        controller = LogWindowController(log: log)
        controller?.showWindow(self)
        controller?.window?.makeKeyAndOrderFront(self)
    }
}