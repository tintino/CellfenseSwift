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
    
    var lastUpdateTime = TimeInterval()
    
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
    
    override func didMove(to view: SKView) {
        
        //Create the scene’s contents.
        
        let randomLevel = Level.randomLevel()
        self.gameControl = GameControlNode(withLevel: randomLevel)
        
        //GameControlNode is child of camera, the center of the camera is (0,0), width and height is the same as gamescene view
        self.gameControl.position = CGPoint(x: -self.frame.midX, y: -self.frame.midY)
        
        
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
        sceneCam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        self.enemyFieldOffset = self.frame.midY + self.frame.maxY
        self.defenseFieldOffset = self.frame.midY
        self.cameraOffSet = enemyFieldOffset
        
        //Center on the screen
        self.labelMessage.position = self.sceneCam.position
        self.labelMessage.fontSize = 40
        self.labelMessage.fontColor = UIColor.white
        //self.labelMessage.hidden = true
        self.addChild(self.labelMessage)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = (touch as UITouch).location(in: self)
            let nodeTouched = self.atPoint(location)
            
            if nodeTouched.name == Constants.NodeName.hudSwitch {
                moveCamera()
                return
            }
            
            //Add a new Tower
            if nodeTouched.name == Constants.NodeName.hudTower{
                self.touchedTower = SKSpriteNode(imageNamed: "turret_frame0")
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
                self.gameControl.isHidden = true
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = (touch as UITouch).location(in: self)
            //let nodeTouched = self.atPoint(location)
            _ = self.atPoint(location)
            
            if let touchedTower = self.touchedTower {
                
                //Offset on Y: mantain the tower on the finger
                touchedTower.position = self.gameWorld.worldToGrid(location)
                
                //If Overlaping another tower, show it red
                if self.gameWorld.towerAtLocation(touchedTower.position) != nil{
                    
                    touchedTower.color = UIColor.red;
                    touchedTower.colorBlendFactor = Constants.Tower.opacity;
                }
                else{
                    touchedTower.colorBlendFactor = 0.0;
                }
                
                if self.gameControl.isHudArea(touchedTower.position){
                    self.showMessage("SELL?")
                }
                else{
                    self.hideMessage()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = (touch as UITouch).location(in: self)
            //let nodeTouched = self.atPoint(location)
            _ = self.atPoint(location)
            
            //User is holding a new tower
            if let touchedTower = self.touchedTower {
                
                //And Want to sell it
                if self.gameControl.isHudArea(touchedTower.position){
                    self.showAutoHideMessage("SELL?")
                }
                    //And want to place it
                else if self.gameWorld.towerAtLocation(touchedTower.position) == nil{
                    
                    //And is not blocking the path
                    if self.gameWorld.doesBlockPathIfAddedTo(touchedTower.position){
                        self.gameWorld.addTower(touchedTower.position)
                    }
                    else{
                        self.showAutoHideMessage("BLOCKING!")
                    }
                }
                
                //Added (available place) or not (occupied place, block or sell) to the world, we remove the touched tower
                touchedTower.removeFromParent()
                self.touchedTower = nil
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let timeSinceLastUpdate = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        self.gameWorld.update(timeSinceLastUpdate)
    }
    
    override func didFinishUpdate() {
    }
    
    func moveCamera(){
        //All these variables and logic, are just to handle if the user touches very quickly the "switch button" before the action finished
        self.sceneCam.run(SKAction.moveTo(y: cameraOffSet, duration: 0.3))
        if self.cameraOffSet == self.enemyFieldOffset{
            
            self.cameraOffSet = self.defenseFieldOffset
            self.gameControl.hideHud()
        }
        else{
            self.cameraOffSet = self.enemyFieldOffset
            self.gameControl.showHud()
        }
    }
    
    func showAutoHideMessage(_ message: String){
        
        self.showMessage(message)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.hideMessage), userInfo: nil, repeats: false)
    }
    
    func showMessage(_ message: String){
        
        self.labelMessage.text = message
        self.labelMessage.isHidden = false
    }
    
    func hideMessage(){
        self.labelMessage.isHidden = true
    }
    
    
    
    
    
    
    
}
