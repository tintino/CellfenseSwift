//
//  GameWorldNode.swift
//  CellfenseSwift
//
//  Created by Tincho on 9/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import SpriteKit
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (left?, right?):
    return left < right
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (left?, right?):
    return left > right
  default:
    return rhs < lhs
  }
}

class GameWorldNode: SKNode {

    // Delegate methods
    var onGameComplete: ((_ time: Double) -> Void)?
    var onUpdateLives: ((_ lives: Int) -> Void)?

    var levelDone = false
    var sampleCellSize: CGSize?
    var towers = [Tower]()
    var enemies = [Enemy]()
    var addedEnemies = [Enemy]()
    var background = SKSpriteNode()
    var lives: Int = 0 {
        willSet (newValue) {
            if lives != newValue {
                onUpdateLives?(lives)
            }
        }
    }
    var elapsed = 0.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    init(level: Level) {

        super.init()

        sampleCellSize = CGSize.zero

        // Create background
        background = SKSpriteNode(imageNamed: "sceneBackground")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        // Force the render on the back
        background.zPosition = Constants.Zposition.background
        addChild(background)

        for enemy in level.enemies {
            spawnEnemy(enemy: enemy)
        }
        lives = 1

        prepareLevel()
    }

    func update(dTime: Double) {

        if !levelDone {
            elapsed += dTime
        }

        if enemies.count == 0 && !levelDone {
            gameCompleted()
        } else {
            checkBoundaries()
            processEnemies(dTime: dTime)
            processTowers(dTime: dTime)
        }
    }

    func checkBoundaries() {

        var toDiscard = [Enemy]()

        for enemy in enemies where enemyScape(enemy: enemy) {
            // Check if enemy escape!
            toDiscard.append(enemy)
            lives -= 1
        }

        for enemy in toDiscard {
            removeEnemy(enemy: enemy)
        }

        // TODO: clean bullets out of broundaries
    }

    func enemyScape(enemy: Enemy) -> Bool {
        return enemy.position.y < -enemy.frame.height/2
    }

    func addTower(_ position: CGPoint) {

        let newTower = Tower(type: TowerType.TURRET)
        newTower?.position = position
        towers.append(newTower!)
        // newTower?.name
        addChild(newTower!)
    }

    func removeTowerAtLocation(_ position: CGPoint) {
        // TODO: Analize best solution for towers type
        /*
         To avoid iteration just to remove a tower, we can use NSMutableArray for towers,
         will be easy to handle the remove action, but on the other hand,
         the compiler will bridged NSMutableArray to a Swift array of type [AnyObject]:  cast and check
         problems started.
         For actual faster processors and not so many towers on this old game,
         we can iterate sacrificing a little performance. Other solution, a hacky one,
         will be to save tower index on a new var (tower.number) and use that value on removeAtIndex method
         */

        var arrayIndex = 0

        for tower in towers {
            var rectArea = CGRect()
            rectArea.size = tower.size
            rectArea.origin = CGPoint(x: tower.position.x - rectArea.size.width/2, y: tower.position.y - rectArea.size.height/2)
            if rectArea.contains(position) {
                towers.remove(at: arrayIndex)
            }
            arrayIndex += 1
        }
    }

    func towerAtLocation(_ position: CGPoint) -> Tower? {
        for tower in towers {
            var rectArea = CGRect()
            rectArea.size = tower.size
            rectArea.origin = CGPoint(x: tower.position.x - rectArea.size.width/2, y: tower.position.y - rectArea.size.height/2)
            if rectArea.contains(position) {
                return tower
            }
        }
        return nil
    }

    func cellSize() -> CGSize {
        if sampleCellSize!.width == 0 {
            let sampleSprite = SKSpriteNode.init(imageNamed: "turret_frame0")
            sampleCellSize = CGSize(width: sampleSprite.size.width, height: sampleSprite.size.height)
        }
        let size = min(sampleCellSize!.width, sampleCellSize!.height)
        return CGSize(width: size, height: size)
    }

    // Objective C will need a Int32
    func rows() -> Int32 {
        return Int32.init(background.frame.size.height/cellSize().width)
    }
    func cols() -> Int32 {
        return Int32.init(background.frame.size.width/cellSize().width)
    }

    func startDefending() {
        planEnemiesPath()
    }

    func planEnemiesPath() {

        // Create Grid with walls where the tower are
        let pathFinder = PathFinder(rows: rows(), columns: cols(), walls: towerNodesForPathFinding())

        // Calc path from grid block from each enemy
        for enemy in enemies {

            // Find path
            enemy.path = (pathFinder?.findPathRow(Int32(enemy.row) - 1, col: Int32(enemy.col) - 1, toRow: 23, toCol: 0))!

            // For debug draw enemy path
            /*
            var isFirstNode = true
            var isLastNode = false
            for path in enemy.path{
                
                // Enemy reach the end of the path
                if enemy.pathIndex == enemy.path.count{
                    return
                }
                
                if enemy.pathIndex == enemy.path.count - 1 {
                    isLastNode = true
                }
                
                // Find the node in the path
                let nodePath : PathFindNode =  path as! PathFindNode// enemy.path.objectAtIndex(enemy.path.count - 1 - enemy.pathIndex)
                let nodePathWorldLocation = indexesToWorld(CGPoint(x: Int(nodePath.nodeX),y: Int(nodePath.nodeY)))
                
                let blockArea = SKShapeNode(circleOfRadius: 5)
                blockArea.lineWidth = 1
                if isFirstNode {
                    isFirstNode = false
                    blockArea.fillColor = SKColor.green
                }
                else if isLastNode{
                    isLastNode = false
                    blockArea.fillColor = SKColor.red
                }
                    
                else{
                    blockArea.fillColor = SKColor.yellow
                }
                blockArea.strokeColor = SKColor.yellow
                blockArea.position = nodePathWorldLocation
                addChild(blockArea)
                
                enemy.pathIndex += 1
            }
             */

            // Set Direction (enemies will start goind down allways)
            enemy.dirX = 0
            enemy.dirY = -1
            enemy.pathIndex = 0

            // Start Animation
            enemy.walk()
        }
    }

    func worldToGrid(_ position: CGPoint) -> CGPoint {

        // Cast to int will round the world position to "tiled" position
        let tiledX: Int = (Int(position.x / cellSize().width) * Int(cellSize().width))
        let tiledY: Int = (Int(position.y / cellSize().height) * Int(cellSize().height))

        return CGPoint(x: CGFloat(tiledX) + cellSize().width/2, y: CGFloat(tiledY) + cellSize().height * 1.5)
    }

    func gridToWorld(_ position: CGPoint) -> CGPoint {

        return CGPoint(x: cellSize().width/2 + position.x * cellSize().width,
                       y: position.y * cellSize().height + cellSize().height/2)
    }

    func worldToGridIndexes(_ worldPoint: CGPoint) -> CGPoint {

        // Cast to int will round the world position to "tiled" position
        let tiledX = round(worldPoint.x / cellSize().width) * cellSize().width
        let tiledY = round(worldPoint.y / cellSize().height) * cellSize().height

        // Fix to mid position
        let toGrid = CGPoint(x: CGFloat(tiledX), y: CGFloat(tiledY))

        // Convert to Grid Value. Index 0 is the row above the first line of towers
        return CGPoint(x: Int(toGrid.x/cellSize().width) - 1, y: Int(rows()) - Int((toGrid.y/cellSize().height)))
    }

    func indexesToWorld(_ gridPoint: CGPoint) -> CGPoint {
        return CGPoint(x: gridPoint.x * cellSize().width + cellSize().width/2,
                       y: background.frame.size.height - ( (gridPoint.y) * cellSize().height + cellSize().height/2))
    }

    func towerNodesForPathFinding() -> [AnyObject] {

        var towerNodes: [AnyObject] = []
        for tower in towers {
            let gridPosition = worldToGridIndexes(tower.position)
            let node: PathFindNode = PathFindNode()

            node.nodeX = Int32.init(gridPosition.x)
            node.nodeY = Int32.init(gridPosition.y)
            towerNodes.append(node)
        }
        return towerNodes
    }

    func processEnemies(dTime: Double) {

        let cellSize = self.cellSize().width
        enumerateChildNodes(withName: Constants.NodeName.enemy) { (node, stop) in

            if let enemyNode = node as? Enemy {

                // Move enemy in one grid block taking consideration his speed
                enemyNode.position = CGPoint(x: (enemyNode.position.x +
                    cellSize * enemyNode.dirX * enemyNode.speed * CGFloat(dTime)),
                                             y: (enemyNode.position.y +
                                                cellSize * enemyNode.dirY * enemyNode.speed * CGFloat(dTime)))

                // Enemy reach the end of the path
                if enemyNode.pathIndex == enemyNode.path.count {
                    return
                }

                // Find the node in the path
                let nodePath = enemyNode.path[enemyNode.path.count - 1 - enemyNode.pathIndex]
                let nodePathWorldLocation = self.indexesToWorld(CGPoint(x: Int((nodePath as AnyObject).nodeX),
                                                                        y: Int((nodePath as AnyObject).nodeY)))

                // If the enemy reach or pass the node limit, fix the position to the limit and get next pathNode
                if enemyNode.dirX == Constants.Direction.LEFT {

                    if enemyNode.position.x <= nodePathWorldLocation.x {
                        enemyNode.position = CGPoint(x: nodePathWorldLocation.x, y: enemyNode.position.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemy: enemyNode)
                    }
                } else if enemyNode.dirX == Constants.Direction.RIGHT {

                    if enemyNode.position.x >= nodePathWorldLocation.x {
                        enemyNode.position = CGPoint(x: nodePathWorldLocation.x, y: enemyNode.position.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemy: enemyNode)
                    }
                } else if enemyNode.dirY == Constants.Direction.UPWARD {

                    if enemyNode.position.y >= nodePathWorldLocation.y {
                        enemyNode.position = CGPoint(x: enemyNode.position.x, y: nodePathWorldLocation.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemy: enemyNode)
                    }
                } else if enemyNode.dirY == Constants.Direction.DOWN {

                    if enemyNode.position.y <= nodePathWorldLocation.y {
                        enemyNode.position = CGPoint(x: enemyNode.position.x, y: nodePathWorldLocation.y)
                        enemyNode.pathIndex += 1
                        self.decideDirection(enemy: enemyNode)
                    }
                }
            }
        }
    }

    func decideDirection(enemy: Enemy) {

        // Is the end of the travel go down
        if enemy.pathIndex == enemy.path.count {
            enemy.dirX = Constants.Direction.STOP
            enemy.dirY = Constants.Direction.DOWN
            enemy.rotate(angle: 0)
            return
        }

        // First "-1" is to shift: array position start at 0
        let previous = enemy.path[enemy.path.count - 1 - enemy.pathIndex + 1]
        let actualNode = enemy.path[enemy.path.count - 1 - enemy.pathIndex]

        // Walking left or right
        if (previous as AnyObject).nodeY == (actualNode as AnyObject).nodeY {

            enemy.dirY = Constants.Direction.STOP

            if (previous as AnyObject).nodeX > (actualNode as AnyObject).nodeX {
                enemy.dirX = Constants.Direction.LEFT
                enemy.rotate(angle: -90)
            } else {
                enemy.dirX = Constants.Direction.RIGHT
                enemy.rotate(angle: 90)
            }
        }
        // Walking up or down
        else {

            enemy.dirX = Constants.Direction.STOP

            if (previous as AnyObject).nodeY > (actualNode as AnyObject).nodeY {
                enemy.dirY = Constants.Direction.UPWARD
                enemy.rotate(angle: 180)
            } else {
                enemy.dirY = Constants.Direction.DOWN
                enemy.rotate(angle: 0)
            }
        }
    }

    func spawnEnemy(enemy: Enemy) {
        /* TODO: due objective c project differences on point 0.0 on axes,
         we need to apply offset at spawn enemy time. For fixed screen is 11 (0->11 =  12).
        Change and improve this. This is to avoid to have diferents xmls level versions on objective c and android.
        */

        let rows = Int(background.frame.size.height/cellSize().width)
        let fixedY = rows - enemy.row
        // Objective C use 1->8 and Swift version 0->7
        let fixedX = enemy.col - 1

        enemy.position = gridToWorld(CGPoint(x: fixedX, y: fixedY))

        addedEnemies.append(enemy)
    }

    func processTowers(dTime: Double) {

        for tower in towers {

            // Before shoot or keep shooting we check if it is already dead (maybe kill by another tower) or out of range
            if (tower.shootingAt == nil ||
                tower.shootingAt?.life == 0 ||
                !isInRange(tower: tower, enemy: tower.shootingAt!)) {

                // Dead or lucky (out of range)
                tower.shootingAt = nil

                // Find a new victim
                var nearestEnemy: Enemy? = nil
                var nearestDist = CGFloat.greatestFiniteMagnitude
                for enemy in enemies {

                    // the closest one
                    if isInRange(tower: tower, enemy: enemy) {

                        if nearestEnemy == nil {

                            nearestEnemy = enemy
                            nearestDist = distance(tower: tower, enemy: enemy)
                        } else {

                            let distance = self.distance(tower: tower, enemy: enemy)
                            if distance <= nearestDist {
                                nearestDist = distance
                                nearestEnemy = enemy
                            }
                        }
                    }
                }
                tower.shootingAt = nearestEnemy
            }
            // Got a victim, let's aim the tower and shoot
            if tower.shootingAt != nil {

                // Aim the tower
                let πValue = CGFloat(Double.pi)
                let dx = tower.shootingAt!.position.x - tower.position.x
                let dy = tower.shootingAt!.position.y - tower.position.y
                var angle = atan(dy/dx) * (180/πValue)
                if (tower.shootingAt!.position.x - tower.position.x  < 0) {
                    angle += 180
                }
                tower.rotate(angle: angle - 90)

                // Fire!
                if tower.tryShoot(victim: tower.shootingAt!) {

                    if tower.shootingAt?.life > 0 {
                        // TODO: spare blood particles
                    } else {
                        enemyKilled(enemy: tower.shootingAt!)
                        tower.shootingAt = nil
                    }
                }
            }
            tower.tick(dt: dTime)
        }
    }

    func enemyKilled(enemy: Enemy) {
        enemy.rotate(angle: 0)
        // TODO: spawnParticleGroupAtX
        removeEnemy(enemy: enemy)
    }

    func removeEnemy(enemy: Enemy) {

        // TODO: due use of enemies.index(of check if we can remove indexAtWave from enemy
        if let index = enemies.index(of: enemy) {
            enemies.remove(at: index)
            enemy.removeFromParent()
        }
    }

    func isInRange(tower: Tower, enemy: Enemy) -> Bool {

        let distance = self.distance(tower: tower, enemy: enemy)
        let range = tower.range * cellSize().width

        return distance <= range || fabs(distance - range) < 0.001
    }

    func distance(tower: Tower, enemy: Enemy) -> CGFloat {
        // Calc Deltas
        let dx = abs(tower.position.x - enemy.position.x)
        let dy = abs(tower.position.y - enemy.position.y)

        // If it is closer, ready and steady to shoot
        if dy > cellSize().height * Constants.Tower.getReadyDistance {
            // TODO: this is use to tutorial, by this version will be used to target enemy and wait for shoot range
        }

        let ndx, ndy, proportion: CGFloat

        if dx < dy {
            proportion = dx/dy
            ndy = cellSize().height/2
            ndx = ndy * proportion
        } else {
            proportion = dy/dx
            ndx = cellSize().width/2
            ndy = ndx * proportion
        }
        return sqrt(dx*dx + dy*dy) - sqrt(ndx*ndx + ndy*ndy)
    }

    func doesBlockPathIfAddedTo(position: CGPoint) -> Bool {

        // Create walls for existing tower + asked position
        var towerNodes = towerNodesForPathFinding()
        let locationIndexes = worldToGridIndexes(position)
        let pathNode = PathFindNode()
        pathNode.nodeX = Int32(locationIndexes.x)
        pathNode.nodeY = Int32(locationIndexes.y)
        towerNodes.append(pathNode)

        let pathFinder = PathFinder.init(rows: rows(), columns: cols(), walls: towerNodes)
        let path = pathFinder?.findPathRow(0, col: 0, toRow: rows() - 1, toCol: 0)

        return path != nil ? true : false
    }

    private func gameCompleted() {
        stopAnimations()
        cleanEnemies()
        levelDone = true
        onGameComplete?(elapsed)
    }

    func cleanEnemies() {
        // Remove enemies from Screen
        enumerateChildNodes(withName: Constants.NodeName.enemy) { (node, stop) in
            if let enemyNode = node as? Enemy {
                enemyNode.removeFromParent()
            }
        }
        enemies.removeAll()
    }

    func stopAnimations() {
        // TODO: stop particles from fly
        for enemy in enemies {
            enemy.removeAllActions()
        }
    }

    func restart() {
        cleanEnemies()

        // Restart initial values
        lives = 1
        elapsed = 0
        levelDone = false

        prepareLevel()
    }

    func prepareLevel() {

        for originalEnemy in addedEnemies {
            if let copyEnemy = originalEnemy.copy() as? Enemy {
                enemies.append(copyEnemy)
                addChild(copyEnemy)
            }
        }
    }
}
