//
//  GameWorldNode.swift
//  CellfenseSwift
//
//  Created by Tincho on 9/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import SpriteKit

class GameWorldNode: SKNode{
   
    var towers = [Tower]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withLevel: String){
        super.init()
        
        //Create background
        let background = SKSpriteNode(imageNamed: "sceneBackground")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        //Force to render on back
        background.zPosition = -2
        self.addChild(background)
    }
    
    func addTower(position: CGPoint){
        
        let newTower = Tower(type: TowerType.TURRET)
        newTower?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newTower?.position = position
        self.towers.append(newTower!)
        self.addChild(newTower!)
        
    }
    
    func towerAtLocation(position: CGPoint) -> Tower?{
        for tower in self.towers {
            var rectArea = CGRect()
            rectArea.size = tower.size
            rectArea.origin = CGPoint(x: tower.position.x - rectArea.size.width/2, y: tower.position.y - rectArea.size.height/2)
            if CGRectContainsPoint(rectArea, position){
                return tower
            }
        }
        return nil
    }

    
}