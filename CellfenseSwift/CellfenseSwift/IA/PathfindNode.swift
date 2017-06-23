//
//  PathFindNode.swift
//  CellfenseSwift
//
//  Created by Martin Gonzalez vega on 18/6/17.
//  Copyright © 2017 quitarts. All rights reserved.
//

import UIKit

class PathfindNode: NSObject {

    var x : Int = 0
    var y : Int = 0
    var cost : Int = 0
    var parentNode : PathfindNode?

    
    required init?(cost: Int, x: Int, y: Int){
        self.x = x
        self.y = y
        self.cost = cost        
    }
    
}
