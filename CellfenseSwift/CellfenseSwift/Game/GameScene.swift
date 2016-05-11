//
//  GameScene.swift
//  SpriteKitGameExample
//
//  Created by Tincho on 5/5/16.
//  Copyright © 2016 ag2. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    
    var gameControl : GameControlNode!
    var gameWorld : GameWorldNode!
    var sceneCam: SKCameraNode!
    
    var touchedTower : SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        
        //Create the scene’s contents.
        
        let level = Level()
        self.gameControl = GameControlNode(withLevel: level)
        self.addChild(self.gameControl)
        
        self.gameWorld = GameWorldNode(withLevel: "")
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
            
            if nodeTouched.name == Constants.NodeName.hudTower{
                self.touchedTower = SKSpriteNode(imageNamed: "turret_frame0")
                self.touchedTower.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                self.touchedTower.position = CGPoint(x:  300, y:  100)
                self.addChild(self.touchedTower)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            
            let location = (touch as UITouch).locationInNode(self)
            
            let nodeTouched = self.nodeAtPoint(location)           
            
            if let tower = self.touchedTower {
                //Offset on y: avoid the tower to be under the finger
                tower.position = CGPoint(x: location.x, y: location.y +
                    self.touchedTower.size.height)
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
            
            if let tower = self.touchedTower {
                tower.removeFromParent()
                self.gameWorld.addTower(tower.position)
                
            }
        }
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        
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