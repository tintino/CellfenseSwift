//
//  Tower.swift
//  CellfenseSwift
//
//  Created by Tincho on 8/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import SpriteKit

enum TowerType : String {
    case TURRET = "Turret"
}

class Tower: SKSpriteNode {
    
    var towerFrames = [SKTexture]()
    var fireSoundFileName = ""
    var range : CGFloat = 0.0    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(type: TowerType){
        
        //Create all Tower Textures
        let towerAnimatedAtlas = SKTextureAtlas(named: "\(type.rawValue)")
        let numberOfTowerFrames = towerAnimatedAtlas.textureNames.count
        for i in 0..<numberOfTowerFrames {
            let towerTextureName = "\(type)_frame\(i)"
            self.towerFrames.append(towerAnimatedAtlas.textureNamed(towerTextureName))
        }
        
        //Initialize Sprite with First Frame
        super.init(texture: self.towerFrames[0], color: UIColor.blackColor(), size:self.towerFrames[0].size())
        
        //Shared init values
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //Custom init values for each tower type
        switch type {
            
        case TowerType.TURRET:
            self.range = Constants.Tower.range
            self.fireSoundFileName = "chain_gun.wav"
        }
        
        //Shoot Radio for debug. This will not affect the SKSpriteNode Size
        let fireRadioCircle = CGRect(x: self.frame.origin.x * self.range,
                                 y: self.frame.origin.y * self.range,
                                 width: self.frame.size.width * self.range,
                                 height: self.frame.size.height * self.range)
        let shapeNode = SKShapeNode(rect: fireRadioCircle)
        shapeNode.path = UIBezierPath.init(ovalInRect: fireRadioCircle).CGPath
        shapeNode.strokeColor = SKColor.greenColor()
        shapeNode.lineWidth = 1;
        self.addChild(shapeNode)
    }
    
    func fire(){
        let animatedAction = SKAction.animateWithTextures(self.towerFrames, timePerFrame: 0.1)
        let fireAction = SKAction.repeatAction(animatedAction, count:1)
        let fireSoundAction = SKAction.playSoundFileNamed(fireSoundFileName, waitForCompletion: false)
        self.runAction(fireAction, withKey: "towerFire")
        self.runAction(fireSoundAction)
    }
}