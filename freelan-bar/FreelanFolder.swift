//
//  FreelanFolder.swift
//  freelan-bar
//
//  Created by Andreas Streichardt on 14.12.14.
//  Copyright (c) 2014 mop. All rights reserved.
//

import Foundation

class FreelanFolder {
    var id: NSString
    var path: NSString
    
    init(id: NSString, path: NSString) {
        self.id = id
        self.path = path
    }
}