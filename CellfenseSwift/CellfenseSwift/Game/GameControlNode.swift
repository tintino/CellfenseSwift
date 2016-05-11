//
//  ControlLayer.swift
//  CellfenseSwift
//
//  Created by Tincho on 9/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import SpriteKit

class GameControlNode: SKNode {
    
    var upButton = SKSpriteNode()
    var tower = SKSpriteNode()
    var hud : SKNode!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withLevel: Level){
        super.init()
        
        //Create Hud, will contain everything but play and switch button
        self.hud = SKNode()
        self.hud.position = CGPoint(x: 0, y: 0)
        self.addChild(self.hud)
        
        //Create background
        let hudBackground = SKSpriteNode(imageNamed: "hud")
        hudBackground.name = Constants.NodeName.hudBackground
        hudBackground.anchorPoint = CGPoint(x: 0, y: 0)
        hudBackground.position = CGPoint(x: 0, y: 0)
        hudBackground.alpha = 0.3
        hudBackground.zPosition = -1
        self.hud.addChild(hudBackground)
        
        //Create Tower Button
        self.tower = SKSpriteNode(imageNamed: "turret_frame0")
        self.tower.name = Constants.NodeName.hudTower
        self.tower.anchorPoint = CGPoint(x: 1, y: -1)
        self.tower.position = CGPoint(x: 320, y: 0)
        self.hud.addChild(self.tower)
        
        //Create Up/Down Button
        self.upButton = SKSpriteNode(imageNamed: "up_button")
        self.upButton.name = Constants.NodeName.hudSwitch
        self.upButton.anchorPoint = CGPoint(x: 0, y: 0)
        self.upButton.position = CGPoint(x: 0, y: 0)
        self.addChild(self.upButton)
        
    }
    
    func moveUp(){
        //TODO: on multiple touchs on switch try to reverse action to avoid incorrect behavior
        self.runAction(SKAction.moveTo(CGPoint(x: 0,y:480), duration: 1))
        self.hud.hidden = true
    }
    
    func moveDown(){        
        self.runAction(SKAction.moveTo(CGPoint(x: 0,y:0), duration: 1))
        self.hud.hidden = false
    }
    
    
}