//
//  GameScene.swift
//  SpriteKitGameExample
//
//  Created by Tincho on 5/5/16.
//  Copyright © 2016 ag2. All rights reserved.
//
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    
    var lastUpdateTime = NSTimeInterval()
    
    //Control: Has the play button, switch screen button, hud to add new towers
    var gameControl : GameControlNode!
    
    //World: Has the enemies, installed towers
    var gameWorld : GameWorldNode!
    
    var sceneCam: SKCameraNode!
    
    var touchedTower : SKSpriteNode?
    
    override func didMoveToView(view: SKView) {
        
        //Create the scene’s contents.
        
        let randomLevel = Level.randomLevel()
        self.gameControl = GameControlNode(withLevel: randomLevel)
        self.addChild(self.gameControl)
        
        self.gameWorld = GameWorldNode(withLevel: randomLevel)
        self.addChild(gameWorld)
        
        //Add Camera Scene
        //The camera’s viewport is the same size as the scene’s viewport (determined by the scene’s size property)
        sceneCam = SKCameraNode()
        self.camera = sceneCam
        addChild(sceneCam)
        
        //position the camera on the scene.
        sceneCam.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = (touch as UITouch).locationInNode(self)
            let nodeTouched = self.nodeAtPoint(location)
            
            //Add a new Tower
            if nodeTouched.name == Constants.NodeName.hudTower{
                self.touchedTower = SKSpriteNode(imageNamed: "turret_frame0")
                self.touchedTower!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                
                //Offset on Y: avoid the tower to be under the finger
                self.touchedTower!.position = CGPoint(x: location.x,
                                                      y: location.y + self.touchedTower!.size.height)
                self.addChild(self.touchedTower!)
            }
                //Relocate a Tower
            else if let worldTower = self.gameWorld.towerAtLocation(location){
                
                //Reuse same flow as "add a new tower" to Keep It Simple
                self.touchedTower = worldTower
                self.gameWorld.removeTowerAtLocation(location)
            }
            else if nodeTouched.name == Constants.NodeName.hudRush{
                self.gameWorld.startDefending()
            }
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = (touch as UITouch).locationInNode(self)
            let nodeTouched = self.nodeAtPoint(location)
            
            if let touchedTower = self.touchedTower {
                
                //Offset on Y: mantain the tower on the finger
                touchedTower.position = self.gameWorld.worldToGrid(location)
                
                if self.gameWorld.towerAtLocation(touchedTower.position) != nil{
                    
                    touchedTower.color = UIColor.redColor();
                    touchedTower.colorBlendFactor = Constants.Tower.opacity;
                }
                else{
                    touchedTower.colorBlendFactor = 0.0;
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = (touch as UITouch).locationInNode(self)
            let nodeTouched = self.nodeAtPoint(location)
            
            if nodeTouched.name == Constants.NodeName.hudSwitch {
                moveScene()
            }
            
            //User is holding a new tower
            if let touchedTower = self.touchedTower {
                
                //And want it to place it on an empty space
                if self.gameWorld.towerAtLocation(touchedTower.position) == nil{
                    
                    self.gameWorld.addTower(touchedTower.position)
                }
                
                //Added (available place) or not (occupied place) to the world, we remove the touched tower
                touchedTower.removeFromParent()
                self.touchedTower = nil
            }
        }
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        
        let timeSinceLastUpdate = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        self.gameWorld.update(timeSinceLastUpdate)
    }
    
    override func didFinishUpdate() {
    }
    
    func moveScene(){
        if self.sceneCam.position.y == 720{
            self.sceneCam.runAction(SKAction.moveToY(240, duration: 1))
            self.gameControl.moveDown()
        }
        else{
            self.sceneCam.runAction(SKAction.moveToY(720, duration: 1))
            self.gameControl.moveUp()
        }
    }
}