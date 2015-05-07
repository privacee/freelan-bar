//
//  FreelanFolder.swift
//  freelan-bar
//
//  Created by Andreas Streichardt on 14.12.14.
//  Copyright (c) 2014 mop. All rights reserved.
//
//  Adapted for freelan by Christoph Russ on 07 May 2015.
//

import Foundation

class FreelanContact {
    var id: NSString
    var address: NSString
    
    init(id: NSString, address: NSString) {
        self.id = id
        self.address = address
    }
}