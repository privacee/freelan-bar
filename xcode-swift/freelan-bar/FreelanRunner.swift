//
//  FreelanRunner.swift
//  freelan-bar
//
//  Created by Andreas Streichardt on 13.12.14.
//  Copyright (c) 2014 mop. All rights reserved.
//
//  Adapted for freelan by Christoph Russ on 06. May 2015.
//

import Foundation

let TooManyErrorsNotification = "ccode.privacee.too-many-errors"
let HttpChanged = "ccode.privacee.http-changed"
let ContactsDetermined = "ccode.privacee.contacts-determined"

class FreelanRunner: NSObject {
    var portFinder : PortFinder = PortFinder(startPort: 12000)
    var path : NSString
    //var path : NSString = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"binaryname"]"/Users/mop/Downloads/freelan-macosx-amd64-v0.10.8/freelan"
    var task: NSTask?
    var port: NSInteger?
    var lastFail : NSDate?
    var failCount : NSInteger = 0
    var notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    var portOpenTimer : NSTimer?
    var repositoryCollectorTimer : NSTimer?
    var log : FreelanLog
    var buf : NSString = NSString()
    var apiKey: NSString?
    var version: [Int]?

    init(log: FreelanLog) {
        self.log = log
        path = NSBundle.mainBundle().pathForResource("freelan/freelan", ofType: "")!
        
        super.init()
    
        notificationCenter.addObserver(self, selector: "taskStopped:", name: NSTaskDidTerminateNotification, object: task)
        notificationCenter.addObserver(self, selector: "receivedOut:", name: NSFileHandleDataAvailableNotification, object: nil)
    }
    
    func registerVersion() -> Bool {
        var pipe : NSPipe = NSPipe()
        var versionTask = NSTask()
        versionTask.launchPath = path as String
        versionTask.arguments = ["--version"]
        versionTask.standardOutput = pipe
        versionTask.launch()
        versionTask.waitUntilExit()
        
        let versionOut = pipe.fileHandleForReading.readDataToEndOfFile()
        let versionString = NSString(data: versionOut, encoding: NSUTF8StringEncoding)
        
        var regex = NSRegularExpression(pattern: "^freelan (\\d+)\\.(\\d+)",
            options: nil, error: nil)
        var results = regex!.matchesInString(versionString! as String, options: nil, range: NSMakeRange(0, versionString!.length))
        if results.count == 1 {
            let major = versionString?.substringWithRange(results[0].rangeAtIndex(1)).toInt() as Int!
            let minor = versionString?.substringWithRange(results[0].rangeAtIndex(2)).toInt() as Int!
            
            version = [ major, minor ]
            println("Freelan version \(version![0]) \(version![1])")
            return true
        } else {
            return false
        }
    }
    
    func run() -> (String?) {
        // FOR NOW WE WILL NOT RUN FREELAN - it's better off started through LaunchDaeomon
        //
        //return self.run_with_priviliges()
        // cr: freelan requires sudo privileges as it wants to use tun/tap interface
        // NSTask is not up to this task
    }
    
    func run_with_priviliges() -> (String?) {
        var pipe : NSPipe = NSPipe()
        let readHandle = pipe.fileHandleForReading
        
        //task = NSTask()
        //task!.launchPath = path as String
        //task!.arguments = ["-d", "-f", "-c", "./freelan.cfg"]

        //var authorizationRef = AuthorizationRef();
        //var status = OSStatus();
        //status = AuthorizationCreate(nil, nil, kAuthorizationFlagDefaults, authorizationRef);
        //let authorized_task = AuthorizationExecuteWithPrivileges(authorizationRef, task?.launchPath,
        //                                kAuthorizationFlagDefaults, task?.arguments, pipe);    }

        let script = "do shell script \"\(inScript)\" with administrator privileges"
        var appleScript = NSAppleScript(source: script)
        var eventResult = appleScript.executeAndReturnError(nil)
        if !eventResult {
            return "ERROR"
        }else{
            return eventResult.stringValue
        }
        
    func run_without_priviliges() -> (String?) {
        var pipe : NSPipe = NSPipe()
        let readHandle = pipe.fileHandleForReading
        
        task = NSTask()
        task!.launchPath = path as String
        var environment = NSProcessInfo.processInfo().environment as! [String: String]
        environment["STNORESTART"] =  "1"
        task!.environment = environment

        let port = self.port!
        let httpData : [String: String] = ["host": "127.0.0.1", "port": String(port)];
        
        task!.arguments = ["-d", "-f", "-c", "./freelan.cfg"]
        task!.standardOutput = pipe
        readHandle.waitForDataInBackgroundAndNotify()
        task!.launch()
        
        // mop: wait until port is open :O
        portOpenTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkPortOpen:", userInfo: httpData, repeats: true)
        return nil
    }
    
    func receivedOut(notif : NSNotification) {
        // Unpack the FileHandle from the notification
        let fh:NSFileHandle = notif.object as! NSFileHandle
        // Get the data from the FileHandle
        let data = fh.availableData
        // Only deal with the data if it actually exists
        if data.length > 1 {
            // Since we just got the notification from fh, we must tell it to notify us again when it gets more data
            fh.waitForDataInBackgroundAndNotify()
            // Convert the data into a string
            let string = (buf as String) + (NSString(data: data, encoding: NSUTF8StringEncoding)! as String)
            var lines = string.componentsSeparatedByString("\n")
            buf = lines.removeLast()
            for line in lines {
                log.log("OUT: \(line)")
            }
        }
    }
    
    func ensureRunning() -> (String?) {
        if !registerVersion() {
            return "Could not determine freelan version"
        }
        let result = portFinder.findPort()
        // mop: ITS GO :O ZOMG!!111
        if (result.err != nil) {
            return "Could not find a port!"
        }
        self.port = result.port
        let err = run()
        return err
    }
    
    // mop: copy paste :D http://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift looks good to me
    func randomStringWithLength (len : Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    func createRequest(path: NSString) -> NSMutableURLRequest {
        var url = NSURL(string: "http://localhost:\(self.port!)\(path)")
        var request = NSMutableURLRequest(URL: url!)
        request.addValue(self.apiKey! as String, forHTTPHeaderField: "X-API-Key")
        return request
    }
    
    func collectContacts(timer: NSTimer) {
        // TODO: read info from config file
        /*
        if let info = timer.userInfo as? Dictionary<String,String> {
            let host = info["host"]
            let port = info["port"]
            
            var request: NSMutableURLRequest
            var idElement: NSString
            var pathElement: NSString
            var contactsElement: NSString
            
            let contactStructArr = contacts!.filter({(object: AnyObject) -> (Bool) in
                let id = object[idElement] as? String
                let path = object[pathElement] as? String
                
                return id != nil && path != nil
            }).map({(object: AnyObject) -> (FreelanContact) in
                let id = object[idElement] as? String
                let pathTemp = object[pathElement] as? String
                let path = pathTemp?.stringByExpandingTildeInPath
                
                return FreelanContact(id: id!, path: path!)
            })
            
            let contactData = ["contacts": contactStructArr]
            self.notificationCenter.postNotificationName(ContactsDetermined, object: self, userInfo: contactData)
            
        }
        */
        
        // TESTING ONLY >..<
        
        var contact = FreelanContact(id: "1234", address: "120.130.140.150:12001")
        var contactStructArr = [FreelanContact](count: 1, repeatedValue: contact)
        
        let contactData = ["contacts": contactStructArr]
        
        self.notificationCenter.postNotificationName(ContactsDetermined, object: self, userInfo: contactData)
        
        
    }
    
    func checkPortOpen(timer: NSTimer) {
        if (timer.valid) {
            if let info = timer.userInfo as? Dictionary<String,String> {
                let host = info["host"]
                let port = info["port"]
                let url = NSURL(string: "http://\(host!):\(port!)")
                let request = createRequest("")
                
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                    if (error == nil) {
                        var httpData = ["host": host!, "port": port!]
                        self.notificationCenter.postNotificationName(HttpChanged, object: self, userInfo: httpData)
                        if (self.portOpenTimer!.valid) {
                            self.portOpenTimer!.invalidate()
                        }
                        self.repositoryCollectorTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "collectContacts:", userInfo: info, repeats: true)
                        self.repositoryCollectorTimer!.fire()
                    }
                }
            }
        }
    }
    
    func taskStopped(sender: AnyObject) {
        let task = sender.object as! NSTask
        if (task != self.task) {
            return
        }
        
        var httpData = []
        self.notificationCenter.postNotificationName(HttpChanged, object: self)
        
        stopTimers()
        
        var current = NSDate()
        // mop: retry 5 times :S
        if (lastFail != nil) {
            let timeDiff = current.timeIntervalSinceDate(lastFail!)
            if (timeDiff > 5) {
                failCount = 0
            } else if (failCount <= 5) {
                failCount++
            } else {
                notificationCenter.postNotificationName(TooManyErrorsNotification, object: self)
                println("Too many errors. Stopping")
                return
            }
        }
        lastFail = current
        
        // cr: RESTARTING to see if it may work this time ...
        run()
    }
    
    func stopTimers() {
        if (portOpenTimer != nil && portOpenTimer!.valid) {
            portOpenTimer!.invalidate()
        }
        
        if (repositoryCollectorTimer != nil) {
            if (repositoryCollectorTimer!.valid) {
                repositoryCollectorTimer!.invalidate()
            }
        }
    }
    
    func stop() {
        if (task != nil) {
            task!.terminate();
        }
        stopTimers()
    }
}
