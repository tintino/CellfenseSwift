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
    var enemies = [Enemy]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withLevel: Level){
        super.init()
        
        //Create background
        let background = SKSpriteNode(imageNamed: "sceneBackground")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        //Force to render on back
        background.zPosition = Constants.zPosition.background
        self.addChild(background)
        
        for enemy in withLevel.enemies {
            self.enemies.append(enemy)
            self.addChild(enemy)
        }
    }
    
    func addTower(position: CGPoint){
        
        let newTower = Tower(type: TowerType.TURRET)
        newTower?.position = position
        self.towers.append(newTower!)
        newTower?.name
        self.addChild(newTower!)
    }
    
    func removeTowerAtLocation(position: CGPoint){
        //TODO: Analize best solution for towers type
        /*
         To avoid iteration just to remove a tower, we can use NSMutableArray for self.towers, will be easy to handle the remove action,
         but on the other hand, the compiler will bridged NSMutableArray to a Swift array of type [AnyObject]:  cast and check
         problems started.
         For actual faster processors and not so many towers on this old game, we can iterate sacrificing a little performance.
         Other solution, a hacky one, will be to save tower index on a new var (tower.number) and use that value on removeAtIndex method
        */
        
        var arrayIndex = 0
        
        for tower in self.towers {
            var rectArea = CGRect()
            rectArea.size = tower.size
            rectArea.origin = CGPoint(x: tower.position.x - rectArea.size.width/2, y: tower.position.y - rectArea.size.height/2)
            if CGRectContainsPoint(rectArea, position){
                self.towers.removeAtIndex(arrayIndex)
            }
            arrayIndex += 1
        }
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
    
    //TODO: Remove test method
    func moveEnemies(){
        for enemy in self.enemies {
            enemy.Walk()
        }
    }

    
}