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
    var sampleCellSize : CGSize?
    var towers = [Tower]()
    var enemies = [Enemy]()
    var background = SKSpriteNode()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withLevel: Level){
        
        super.init()
        
        self.sampleCellSize = CGSizeMake(0, 0)
        
        //Create background
        self.background = SKSpriteNode(imageNamed: "sceneBackground")
        self.background.anchorPoint = CGPoint(x: 0, y: 0)
        self.background.position = CGPoint(x: 0, y: 0)
        //Force to render on back
        self.background.zPosition = Constants.zPosition.background
        self.addChild(self.background)
        
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
    
    func cellSize() -> CGSize{
        if self.sampleCellSize!.width == 0{
            let sampleSprite = SKSpriteNode.init(imageNamed: "turret_frame0")
            self.sampleCellSize = CGSize(width: sampleSprite.size.width, height: sampleSprite.size.height)
        }
        let size = min(self.sampleCellSize!.width,self.sampleCellSize!.height)
        return CGSizeMake(size, size)
    }
    
    func rows()->Int{
        return Int(self.background.frame.size.height/self.cellSize().width)
    }
    
    func cols()->Int{
        return Int(self.background.frame.size.width/self.cellSize().width)
    }
    
    func startDefending(){
        self.planEnemiesPath()
    }
    
    func planEnemiesPath(){
        //Objective C will need a Int32
        let rows : NSNumber = self.rows()
        let cols : NSNumber = self.cols()
        let pathFinder = PathFinder(rows: rows.intValue, columns: cols.intValue, walls: self.towerNodesForPathFinding())
        
        for enemy in self.enemies {
            
            let point = CGPoint(x: 7,y: 4)
            let colIndex : NSNumber = point.x
            enemy.path = pathFinder.findPathRow(0, col: colIndex.intValue, toRow: rows.intValue - 1, toCol: 0)
            
            enemy.dirX = 0
            enemy.dirY = -1
            enemy.pathIndex = 0
            
            enemy.Walk()
            //
            //enemy.path = [self getShortestExitFrom:index row:[self rows]-1 cols:[self cols] finder:finder];
            //[finder findPathRow:0 Col:(int)index.x toRow:row toCol:0];
        }
        
    }
    
    func towerNodesForPathFinding()->[AnyObject] {
        var towerNodes: [AnyObject] = []
        for tower in self.towers {
            //
            let node : PathFindNode = PathFindNode()
            node.nodeX = 3
            node.nodeY = 3
            towerNodes.append(node)
            
        }
        return towerNodes
    }
    
    
    //TODO: Remove test method
    func moveEnemies(){
        for enemy in self.enemies {
            enemy.Walk()
        }
    }
    
    func update(dt: Double) {
        
        
        self.processEnemies(dt)
        
    }
    
    func processEnemies(dt: Double){
        let cellSize = self.cellSize().width
        
        
        self.enumerateChildNodesWithName(Constants.NodeName.enemy) { (node, stop) in
           
            if let enemyNode = node as? Enemy{
                
                enemyNode.position = CGPoint(x: (enemyNode.position.x + cellSize * enemyNode.dirX * enemyNode.speed * CGFloat(dt)),
                                       y:  (enemyNode.position.y + cellSize * enemyNode.dirY * enemyNode.speed * CGFloat(dt)))
                
                
                
            }
            
        }
            
        
        
    }
    
    
    
    
}