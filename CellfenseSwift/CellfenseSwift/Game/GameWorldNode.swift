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
        //Force the render on the back
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
            
            //Find path
            enemy.path = pathFinder.findPathRow(0, col: 7, toRow: 23, toCol:  0)
            
            //For debug draw enemy path
            /*
            var isFirstNode = true
            var isLastNode = false
            for _ in enemy.path{
                
                //Enemy reach the end of the path
                if enemy.pathIndex == enemy.path.count{
                    return
                }
                
                if enemy.pathIndex == enemy.path.count - 1 {
                    isLastNode = true
                }
                
                //Find the node in the path
                let nodePath = enemy.path.objectAtIndex(enemy.path.count - 1 - enemy.pathIndex)
                let nodePathWorldLocation = self.indexesToWorld(CGPoint(x: Int(nodePath.nodeX),y: Int(nodePath.nodeY)))
                
                let blockArea = SKShapeNode(circleOfRadius: 5)
                blockArea.lineWidth = 1
                if isFirstNode {
                    isFirstNode = false
                    blockArea.fillColor = SKColor.greenColor()
                }
                else if isLastNode{
                    isLastNode = false
                    blockArea.fillColor = SKColor.redColor()
                }
                    
                else{
                    blockArea.fillColor = SKColor.yellowColor()
                }
                blockArea.strokeColor = SKColor.yellowColor()
                blockArea.position = nodePathWorldLocation
                self.addChild(blockArea)
                
                enemy.pathIndex += 1
            }
            */            
            
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
        return CGPoint(x:cellSize.width/2 + position.x * cellSize.width, y: position.y * cellSize.height + cellSize.height/2)
    }
    
    func worldToGridIndexes(worldPoint: CGPoint) -> CGPoint {
        
        let cellSize = self.cellSize()
        
        //Cast to int will round the world position to "tiled" position
        let tiledX = round(worldPoint.x / cellSize.width) * cellSize.width;
        let tiledY = round(worldPoint.y / cellSize.height) * cellSize.height;
        
        //Fix to mid position
        let toGrid = CGPoint(x: CGFloat(tiledX), y: CGFloat(tiledY))
        
        //Convert to Grid Value. Index 0 is the row above the first line of towers
        return CGPoint(x: Int(toGrid.x/cellSize.width) - 1 , y: self.rows() - Int((toGrid.y/cellSize.height)) - 0)
    }
    
    func indexesToWorld(gridPoint: CGPoint) -> CGPoint{
        
        let cellSize = self.cellSize()
        
        return CGPoint(x: gridPoint.x * cellSize.width + cellSize.width/2,
                       y: self.background.frame.size.height - ( (gridPoint.y) * cellSize.height + cellSize.height/2))
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
        self.processTowers(dt)
    }
    
    
    func processEnemies(dt: Double){
        
        let cellSize = self.cellSize().width
        self.enumerateChildNodesWithName(Constants.NodeName.enemy) { (node, stop) in
            
            if let enemyNode = node as? Enemy{
                
                //Move enemy in one grid block taking consideration his speed
                enemyNode.position = CGPoint(x: (enemyNode.position.x + cellSize * enemyNode.dirX * enemyNode.speed * CGFloat(dt)),
                                             y: (enemyNode.position.y + cellSize * enemyNode.dirY * enemyNode.speed * CGFloat(dt)))
                
                //Enemy reach the end of the path
                if enemyNode.pathIndex == enemyNode.path.count{
                    return
                }
                
                //Find the node in the path
                let nodePath = enemyNode.path.objectAtIndex(enemyNode.path.count - 1 - enemyNode.pathIndex)
                let nodePathWorldLocation = self.indexesToWorld(CGPoint(x: Int(nodePath.nodeX),y: Int(nodePath.nodeY)))
                                
                //If the enemy reach or pass the node limit, fix the position to the limit and get next pathNode
                if enemyNode.dirX == Constants.direction.LEFT{
                    
                    if enemyNode.position.x <= nodePathWorldLocation.x{
                        enemyNode.position = CGPoint(x: nodePathWorldLocation.x, y: enemyNode.position.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemyNode)
                    }
                }
                else if enemyNode.dirX == Constants.direction.RIGHT{
                    
                    if enemyNode.position.x >= nodePathWorldLocation.x{
                        enemyNode.position = CGPoint(x: nodePathWorldLocation.x, y:  enemyNode.position.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemyNode)
                    }
                }
                else if enemyNode.dirY == Constants.direction.UP{
                    
                    if enemyNode.position.y >= nodePathWorldLocation.y{
                        enemyNode.position = CGPoint(x: enemyNode.position.x, y: nodePathWorldLocation.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemyNode)
                    }
                }
                else if enemyNode.dirY == Constants.direction.DOWN{
                    
                    if enemyNode.position.y <= nodePathWorldLocation.y{
                        enemyNode.position = CGPoint(x: enemyNode.position.x, y: nodePathWorldLocation.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemyNode)
                    }
                }
            }
        }
    }
    
    func decideDirection(enemy: Enemy){
        
        //Is the end of the travel go down
        if enemy.pathIndex == enemy.path.count {
            enemy.dirX = Constants.direction.STOP
            enemy.dirY = Constants.direction.DOWN
            enemy.rotate(0)
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
                enemy.rotate(-90)
            }
            else{
                enemy.dirX = Constants.direction.RIGHT
                enemy.rotate(90)
            }
        }
        //Walking up or down
        else{
            
            enemy.dirX = Constants.direction.STOP
            
            if previous.nodeY > actualNode.nodeY{
                enemy.dirY = Constants.direction.UP
                enemy.rotate(180)
            }
            else{
                enemy.dirY = Constants.direction.DOWN
                enemy.rotate(0)
            }
        }
    }
    
    func spawnEnemy(enemy: Enemy){
        enemy.position = self.gridToWorld(CGPoint(x:enemy.col,y:enemy.row))
        self.enemies.append(enemy)
        
    }
    
    func processTowers(dt: Double){
        
        for tower in self.towers {
            
            //Before shoot or keep shooting we check if it is already dead (maybe kill by another tower) or out of range
            if (tower.shootingAt == nil || tower.shootingAt?.life == 0 || !self.isInRange(tower, enemy: tower.shootingAt!)){
                
                //Dead or lucky (out of range)
                tower.shootingAt = nil
                
                //Find a new victim
                var nearestEnemy : Enemy? = nil
                var nearestDist = CGFloat.max
                for enemy in self.enemies {
                    
                    //the closest one
                    if self.isInRange(tower, enemy: enemy){
                        
                        if nearestEnemy == nil {
                            
                            nearestEnemy = enemy
                            nearestDist = self.distance(tower, enemy: enemy)
                        }
                        else{
                            
                            let distance = self.distance(tower, enemy: enemy)
                            if distance <= nearestDist{
                                nearestDist = distance
                                nearestEnemy = enemy
                            }
                        }
                    }
                }
                tower.shootingAt = nearestEnemy
            }
            //Got a victim, let's aim the tower and shoot
            if let victim = tower.shootingAt {
                
                //Aim the tower
                let π = CGFloat(M_PI)
                let dx = victim.position.x - tower.position.x;
                let dy = victim.position.y - tower.position.y;
                var angle = atan(dy/dx) * (180/π);
                if (victim.position.x - tower.position.x  < 0){
                    angle += 180;
                }
                tower.rotate(angle - 90);
                
                //Fire!
                if tower.tryShoot(victim){
                    
                    if tower.shootingAt?.life > 0 {
                        //TODO: spare blood particles
                    }
                    else{
                        //TODO: enemyKilled
                        victim.removeFromParent()
                        //TODO: remove from enemies array
                        self.enemies.removeLast()
                        tower.shootingAt = nil
                    }
                }
            }
            tower.tick(dt)
        }
    }
    
    func isInRange(tower: Tower, enemy: Enemy) -> Bool{
        
        let distance = self.distance(tower, enemy: enemy)
        let range = tower.range * self.cellSize().width
        
        return distance <= range || fabs(distance - range) < 0.001;
    }
    
    func distance(tower: Tower, enemy: Enemy) -> CGFloat{
        //Calc Deltas
        let dx = abs(tower.position.x - enemy.position.x)
        let dy = abs(tower.position.y - enemy.position.y)
        
        //If it is closer, ready and steady to shoot
        if dy > self.cellSize().height * Constants.Tower.getReadyDistance{
            //TODO: this is use to tutorial, by this version will be used to target enemy and wait for shoot range
        }
        
        let ndx, ndy, proportion : CGFloat
        
        if dx < dy {
            proportion = dx/dy
            ndy = self.cellSize().height/2
            ndx = ndy * proportion
        }
        else{
            proportion = dy/dx
            ndx = self.cellSize().width/2
            ndy = ndx * proportion
        }
        return sqrt(dx*dx + dy*dy) - sqrt(ndx*ndx + ndy*ndy)
    }
    
}