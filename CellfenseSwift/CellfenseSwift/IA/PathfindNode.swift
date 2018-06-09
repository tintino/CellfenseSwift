//
//  PathFindNode.swift
//  CellfenseSwift
//
//  Created by Martin Gonzalez vega on 18/6/17.
//  Copyright © 2017 quitarts. All rights reserved.
//

import UIKit

class PathfindNode: NSObject {

    var posX: Int = 0
    var posY: Int = 0
    var cost: Int = 0
    var parentNode: PathfindNode?

    required init?(cost: Int, posX: Int, posY: Int) {
        self.posX = posX
        self.posY = posY
        self.cost = cost
    }
}
