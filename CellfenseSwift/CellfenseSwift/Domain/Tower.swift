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
        
        switch type {
            
        case TowerType.TURRET:
            self.fireSoundFileName = "chain_gun.wav"
        }
        
    }
    
    func fire(){
        let animatedAction = SKAction.animateWithTextures(self.towerFrames, timePerFrame: 0.1)
        let fireAction = SKAction.repeatAction(animatedAction, count:1)
        let fireSoundAction = SKAction.playSoundFileNamed(fireSoundFileName, waitForCompletion: false)
        self.runAction(fireAction, withKey: "towerFire")
        self.runAction(fireSoundAction)
    }
}