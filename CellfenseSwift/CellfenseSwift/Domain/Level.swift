//
//  Level.swift
//  CellfenseSwift
//
//  Created by Tincho on 9/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import UIKit

class Level {
    
    var image = UIImage()
    var enemies = [Enemy]()
    var number : Int!
    
    static func randomLevel() -> Level{
        let newRandomLevel = Level()
        
        let newEnemy = Enemy(type: EnemyType.CATERPILLAR)
        newEnemy?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newEnemy?.position = CGPoint(x: 150, y: 840)
        newRandomLevel.enemies.append(newEnemy!)
        return newRandomLevel
    }
    
}