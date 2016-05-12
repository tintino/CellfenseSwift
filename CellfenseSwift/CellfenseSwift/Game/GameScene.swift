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
    
    //Control: Has the play button, switch screen button, hud to add new towers
    var gameControl : GameControlNode!
    
    //World: Has the enemies, installed towers
    var gameWorld : GameWorldNode!
    
    var sceneCam: SKCameraNode!
    
    var touchedTower : SKSpriteNode?
    
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
                self.touchedTower!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                self.touchedTower!.position = CGPoint(x:  300, y:  100)
                self.addChild(self.touchedTower!)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = (touch as UITouch).locationInNode(self)
            let nodeTouched = self.nodeAtPoint(location)           
            
            if let touchedTower = self.touchedTower {
                
                //Offset on Y: avoid the tower to be under the finger
                touchedTower.position = CGPoint(x: location.x,
                                         y: location.y + self.touchedTower!.size.height)
                
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