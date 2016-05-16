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
            self.spawnEnemy(enemy)
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
    
    //Objective C will need a Int32
    func rows()->Int32{
        return Int32.init(self.background.frame.size.height/self.cellSize().width)
    }
    func cols()->Int32{
        return Int32.init(self.background.frame.size.width/self.cellSize().width)
    }
    
    func startDefending(){
        self.planEnemiesPath()
    }
    
    func planEnemiesPath(){
        
        //Create Grid with walls where the tower are
        let pathFinder = PathFinder(rows: self.rows(), columns: self.cols(), walls: self.towerNodesForPathFinding())
        
        //Calc path from grid block from each enemy
        for enemy in self.enemies {
            
            //Get Grid position
            let point = self.worldToGridIndexes(enemy.position)
            
            //Find path
            enemy.path = pathFinder.findPathRow(0, col: Int32.init(point.x), toRow: self.rows() - 1, toCol:  0)
            
            for pat in enemy.path {
                
                let node = pat as? PathFindNode
                
                print("Node:\(node?.nodeX) - \(node?.nodeY)")
                
            }
            
            
            //Set Direction (enemies will start goind down allways)
            enemy.dirX = 0
            enemy.dirY = -1
            enemy.pathIndex = 0
            
            //Start Animation
            enemy.Walk()
        }
    }
    
    func worldToGrid(position: CGPoint)-> CGPoint{
        let cellSize = self.cellSize()
        
        //Cast to int will round the world position to "tiled" position
        let tiledX : Int = (Int(position.x / cellSize.width) * Int(cellSize.width));
        let tiledY : Int = (Int(position.y / cellSize.height) * Int(cellSize.height));
        
        return CGPoint(x: CGFloat(tiledX) + cellSize.width/2, y:CGFloat(tiledY) + cellSize.height * 1.5)
        
    }
    
    func gridToWorld(position: CGPoint) -> CGPoint{
        let cellSize = self.cellSize()
        
        return CGPoint(x:cellSize.width/2 + position.x * cellSize.width, y:position.y * cellSize.height + cellSize.height/2)
    }
    
    func worldToGridIndexes(worldPoint: CGPoint) -> CGPoint {
        let cellSize = self.cellSize()
        
        //Cast to int will round the world position to "tiled" position
        let tiledX : Int = (Int(worldPoint.x / cellSize.width) * Int(cellSize.width));
        let tiledY : Int = (Int(worldPoint.y / cellSize.height) * Int(cellSize.height));
        
        //Fix to mid position
        let toGrid = CGPoint(x: CGFloat(tiledX) + cellSize.width/2, y: CGFloat(tiledY) - cellSize.height/2)
        
        //Convert to Grid Value. Index 0 is the row above the first line of towers
        return CGPoint(x: Int(toGrid.x/cellSize.width), y: Int((toGrid.y/cellSize.height - 1)))
    }
    
    func indexesToWorld(gridPoint: CGPoint) -> CGPoint{
        let cellSize = self.cellSize()
        
        return CGPoint(x: gridPoint.x * cellSize.width + cellSize.width/2,
                       y: self.background.frame.size.height - ( gridPoint.y * cellSize.height + cellSize.height/2))
    }
    
    func towerNodesForPathFinding()->[AnyObject] {
        var towerNodes: [AnyObject] = []
        for tower in self.towers {
            let gridPosition = self.worldToGridIndexes(tower.position)
            let node : PathFindNode = PathFindNode()
            
            node.nodeX = Int32.init(gridPosition.x)
            node.nodeY = Int32.init(gridPosition.y)
            towerNodes.append(node)
        }
        return towerNodes
    }
    
    func update(dt: Double) {
        self.processEnemies(dt)
    }
    
    func decideDirection(enemy: Enemy){
        
        //Is the end of the travel go down
        if enemy.pathIndex == enemy.path.count {
            enemy.dirX = Constants.direction.STOP
            enemy.dirY = Constants.direction.DOWN
            enemy.zRotation = 0
            return
        }
        
        //First "-1" is to shift: array position start at 0
        let previous = enemy.path[enemy.path.count - 1 - enemy.pathIndex + 1]
        let actualNode = enemy.path[enemy.path.count - 1 - enemy.pathIndex]
        
        //Walking left or right
        if previous.nodeY == actualNode.nodeY{
            
            enemy.dirY = Constants.direction.STOP
            
            if previous.nodeX > actualNode.nodeX {
                enemy.dirX = Constants.direction.LEFT
                enemy.zRotation = 90
            }
            else{
                enemy.dirX = Constants.direction.RIGHT
                enemy.zRotation = -90
            }
        }
        //Walking up or down
        else{
            
            enemy.dirX = Constants.direction.STOP
            
            if previous.nodeY > actualNode.nodeY{
                enemy.dirY = Constants.direction.UP
                enemy.zRotation = 180
            }
            else{
                enemy.dirY = Constants.direction.DOWN
                enemy.zRotation = 0
            }
        }
    }
    
    func processEnemies(dt: Double){
        let cellSize = self.cellSize().width
        self.enumerateChildNodesWithName(Constants.NodeName.enemy) { (node, stop) in
            
            if let enemyNode = node as? Enemy{
                
                
                //Move enemy in one grid block taking consideration his speed
                enemyNode.position = CGPoint(x: (enemyNode.position.x + cellSize * enemyNode.dirX * enemyNode.speed * CGFloat(dt)),
                                             y:  (enemyNode.position.y + cellSize * enemyNode.dirY * enemyNode.speed * CGFloat(dt)))
                
                //Enemy reach the end of the path
                if enemyNode.pathIndex == enemyNode.path.count{
                    return
                }
                
                //Find the next node in the path
                let index = enemyNode.path.count - 1 - enemyNode.pathIndex
                //print("index: \(index)")
                
                let node = enemyNode.path.objectAtIndex(enemyNode.path.count - 1 - enemyNode.pathIndex)
                
                print("node at found path:\(enemyNode.path.count - 1 - enemyNode.pathIndex) value: x:\(node.nodeX) y:\(node.nodeY)")
                
                let worldLocation = self.indexesToWorld(CGPoint(x: Int(node.nodeX),y: Int(node.nodeY)))
                
                //print("node in world: \(worldLocation)")
                
                if enemyNode.dirX == Constants.direction.LEFT{
                    if enemyNode.position.x <= worldLocation.x{
                        enemyNode.position = CGPoint(x: worldLocation.x, y: enemyNode.position.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemyNode)
                    }
                }
                else if enemyNode.dirX == Constants.direction.RIGHT{
                    if enemyNode.position.x >= worldLocation.x{
                        enemyNode.position = CGPoint(x: worldLocation.x, y:  enemyNode.position.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemyNode)
                    }
                }
                else if enemyNode.dirY == Constants.direction.UP{
                    if enemyNode.position.y >= worldLocation.y{
                        enemyNode.position = CGPoint(x: enemyNode.position.x, y: worldLocation.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemyNode)
                    }
                }
                else if enemyNode.dirY == Constants.direction.DOWN{
                    
                    print("\(enemyNode.position) new pos: \(CGPoint(x: enemyNode.position.x, y: worldLocation.y))")
                    if enemyNode.position.y <= worldLocation.y{
                        enemyNode.position = CGPoint(x: enemyNode.position.x, y: worldLocation.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemyNode)
                    }
                }
            }
        }
    }
    
    func spawnEnemy(enemy: Enemy){
        enemy.position = self.gridToWorld(CGPoint(x:enemy.col - 1,y: Int(self.rows()) - enemy.row))
        self.enemies.append(enemy)
        
    }
}