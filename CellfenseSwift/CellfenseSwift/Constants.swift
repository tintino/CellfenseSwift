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

    struct Zposition {
        static let background: CGFloat = -2
        static let hudbackground: CGFloat = -1
    }

    struct NodeName {
        static let hudTower = "hudTower"
        static let hudBackground = "hudBackground"
        static let hudSwitch = "hudSwitch"
        static let hudRush = "hudRush"
        static let enemy = "enemy"
    }

    struct Tower {
        static let opacity: CGFloat = 0.5
        static let range: Double = 1.8
        static let getReadyDistance: CGFloat = 3
        static let rotateSpeed: Double = 0.3
        static let turboTime: Int = 2000
        static let defaultRate: Double = 0.5
    }

    struct Tank {
        static let opacity: CGFloat = 0.5
        static let range: Double = 1.8
        static let getReadyDistance: CGFloat = 3
        static let rotateSpeed: Double = 0.3
        static let turboTime: Int = 2000
        static let defaultRate: Double = 0.5
    }

    struct Enemy {
        static let rotateSpeed: Double = 0.2
        static let startLife: Double = 100
        static let criticPercentageLife: Double = 25
        static let energyBarHeight: CGFloat = 2
        static let energyBarPadding: CGFloat = 1

    }

    struct Direction {
        static let RIGHT: CGFloat = 1
        static let LEFT: CGFloat = -1
        static let DOWN: CGFloat = -1
        static let UPWARD: CGFloat = 1
        static let STOP: CGFloat = 0
    }

    struct Color {
        //Enemy
        static let energyBarGreen =  UIColor(red: 43/255, green: 180/255, blue: 9/255, alpha: 1.0)
        static let energyBarYellow =  UIColor(red: 214/255, green: 0/255, blue: 48/255, alpha: 1.0)
        //GameControl
        static let hudBackground = UIColor.black
    }
}
