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
    var rushButton = SKSpriteNode()
    var hudBackground = SKSpriteNode()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withLevel: Level){
        super.init()
                
        //Create Hud container, will contain availables towers
        self.hud = SKNode()
        self.hud.position = CGPoint(x: 0, y: 0)
        self.addChild(self.hud)
        
        //Create background
        self.hudBackground = SKSpriteNode(imageNamed: "hud")
        self.hudBackground.name = Constants.NodeName.hudBackground
        self.hudBackground.anchorPoint = CGPoint(x: 0, y: 0)
        self.hudBackground.position = CGPoint(x: 0, y: 0)
        self.hudBackground.alpha = 0.3
        self.hudBackground.zPosition = Constants.zPosition.hudbackground
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
        
        //Create Rushs Button
        self.rushButton = SKSpriteNode(imageNamed: "rush_button")
        self.rushButton.name = Constants.NodeName.hudRush
        self.rushButton.anchorPoint = CGPoint(x: 0, y: 0)        
        self.rushButton.position = CGPoint(x:self.rushButton.frame.size.width, y: 0)
        self.addChild(self.rushButton)
        
    }
    
    func hideHud(){
        self.hud.hidden = true
    }
    
    func showHud(){
        self.hud.hidden = false
    }
    
    func isHudArea(position: CGPoint) -> Bool {
        if position.y < self.hudBackground.frame.height {
            return true
        }
        else{
            return false
        }
    }
    
}