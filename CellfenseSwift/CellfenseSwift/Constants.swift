//
//  Constants.swift
//  CellfenseSwift
//
//  Created by Tincho on 10/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    
    
    struct zPosition {
        static let background : CGFloat = -2
        static let hudbackground : CGFloat = -1
    }
    
    struct NodeName {
        static let hudTower = "hudTower"
        static let hudBackground = "hudBackground"
        static let hudSwitch = "hudSwitch"
        static let hudRush = "hudRuch"
        static let enemy = "enemy"
    }
    
    struct Tower {
        static let opacity : CGFloat = 0.5
        static let range : CGFloat = 1.8
        static let getReadyDistance: CGFloat = 3
        static let rotateSpeed : Double = 0.3
        static let turboTime : Int = 2000
        static let defaultRate : CGFloat = 0.5
    }
    
    struct Enemy {
        static let rotateSpeed : Double = 0.2
    }
    
    struct direction {
        static let RIGHT : CGFloat = 1
        static let LEFT : CGFloat = -1
        static let DOWN : CGFloat = -1
        static let UP : CGFloat = 1
        static let STOP : CGFloat = 0
    }
}