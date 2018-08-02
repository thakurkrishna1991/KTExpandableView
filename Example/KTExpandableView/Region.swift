//
//  Region.swift
//  KTExpandableView_Example
//
//  Created by Krishna  Thakur on 02/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct Anchors {
    var x:Double?
    var y:Double?
    var type:Int?
}

class Region{
    
    var resolution_x:Int?
    var resolution_y:Int?
    var anchors = [Anchors]()
    
    required init(resolution_x:Int?,resolution_y:Int?,anchors:[Anchors]?){
        self.resolution_x = resolution_x!
        self.resolution_y = resolution_y!
        self.anchors = anchors!
    }
    
}
