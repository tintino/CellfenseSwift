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
    
    //Vars to hande action on switch area button
    var cameraOffSet : CGFloat = 0
    var enemyFieldOffset : CGFloat = 0
    var defenseFieldOffset : CGFloat = 0
    
    
    var touchedTower : SKSpriteNode?
    var labelMessage = SKLabelNode()
    
    override func didMoveToView(view: SKView) {
        
        //Create the scene’s contents.
        
        let randomLevel = Level.randomLevel()
        self.gameControl = GameControlNode(withLevel: randomLevel)
        
        //GameControlNode is child of camera, the center of the camera is (0,0), width and height is the same as gamescene view
        self.gameControl.position = CGPoint(x: -CGRectGetMidX(self.frame), y: -CGRectGetMidY(self.frame))
     
        
        self.gameWorld = GameWorldNode(withLevel: randomLevel)
        self.addChild(gameWorld)
        
        //Add Camera Scene
        //The camera’s viewport is the same size as the scene’s viewport (determined by the scene’s size property)
        sceneCam = SKCameraNode()
        self.camera = sceneCam
        
        //The energy bar, with button and play button is part of the controls, they need to be on the screen always (they move with the camera)
        self.camera?.addChild(self.gameControl)
        addChild(sceneCam)
        
        //position the camera on the scene. the center of the camera is tied to its position (No anchorpoint)
        sceneCam.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        self.enemyFieldOffset = CGRectGetMidY(self.frame) + CGRectGetMaxY(self.frame)
        self.defenseFieldOffset = CGRectGetMidY(self.frame)
        self.cameraOffSet = enemyFieldOffset
        
        //Center on the screen
        self.labelMessage.position = self.sceneCam.position
        self.labelMessage.fontSize = 40
        self.labelMessage.fontColor = UIColor.whiteColor()
        //self.labelMessage.hidden = true
        self.addChild(self.labelMessage)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = (touch as UITouch).locationInNode(self)
            let nodeTouched = self.nodeAtPoint(location)
            
            if nodeTouched.name == Constants.NodeName.hudSwitch {
                moveCamera()
                return
            }
            
            //Add a new Tower
            if nodeTouched.name == Constants.NodeName.hudTower{
                self.touchedTower = SKSpriteNode(imageNamed: "turret_frame0")
                self.touchedTower!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                self.touchedTower?.alpha = 0.5
                
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
                self.gameControl.hidden = true
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
                
                //If Overlaping another tower, show it red
                if self.gameWorld.towerAtLocation(touchedTower.position) != nil{
                    
                    touchedTower.color = UIColor.redColor();
                    touchedTower.colorBlendFactor = Constants.Tower.opacity;
                }
                else{
                    touchedTower.colorBlendFactor = 0.0;
                }
                
                if self.gameControl.isHudArea(touchedTower.position){
                    self.showMessage("SELL?", autoHide: false)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = (touch as UITouch).locationInNode(self)
            let nodeTouched = self.nodeAtPoint(location)
            
          
            
            //User is holding a new tower
            if let touchedTower = self.touchedTower {
                
                //And Want to sell it
                if self.gameControl.isHudArea(touchedTower.position){
                    self.showMessage("SELL?", autoHide: true)
                }
                //And want to place it
                else if self.gameWorld.towerAtLocation(touchedTower.position) == nil{
                    
                    //And is not blocking the path 
                    if self.gameWorld.doesBlockPathIfAddedTo(touchedTower.position){
                        self.gameWorld.addTower(touchedTower.position)
                    }
                    else{
                        self.showMessage("BLOCKING!", autoHide: true)
                    }
                }
                
                //Added (available place) or not (occupied place, block or sell) to the world, we remove the touched tower
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
    
    func moveCamera(){
       //All these variables and logic, are just to handle if the user touches very quickly the "switch button" before the action finished
        self.sceneCam.runAction(SKAction.moveToY(cameraOffSet, duration: 0.3))
        if self.cameraOffSet == self.enemyFieldOffset{
            
            self.cameraOffSet = self.defenseFieldOffset
            self.gameControl.hideHud()
        }
        else{
            self.cameraOffSet = self.enemyFieldOffset
            self.gameControl.showHud()
        }
    }
    
    func showMessage(message: String, autoHide: Bool){
        self.labelMessage.text = message
        self.labelMessage.hidden = false
        
        if autoHide{
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(GameScene.hideMessage), userInfo: nil, repeats: false)
        }
    }
    
    func hideMessage(){
        self.labelMessage.hidden = true
    }
    
    
    
    
    
    
    
}