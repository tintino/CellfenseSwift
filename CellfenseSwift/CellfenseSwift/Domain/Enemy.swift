//
//  Enemy.swift
//  CellfenseSwift
//
//  Created by Tincho on 9/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import SpriteKit
class Enemy: SKSpriteNode {
    
    var enemyFrames = [SKTexture]()
    
    enum Typed : String {
        case CATERPILLAR = "Caterpillar"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(type: Typed){
        
        //TODO: This code is the same on Tower, try to optimize
        
        //Create all Tower Textures
        let enemyAnimatedAtlas = SKTextureAtlas(named: "\(type.rawValue)")
        let numberOfEnemyFrames = enemyAnimatedAtlas.textureNames.count
        for i in 0..<numberOfEnemyFrames {
            let enemyTextureName = "\(type)_frame\(i)"
            self.enemyFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
        }
        
        //Initialize Sprite with First Frame
        super.init(texture: self.enemyFrames[0], color: UIColor.blackColor(), size:self.enemyFrames[0].size())
        
    }
    
    func Walk(){
        let animatedAction = SKAction.animateWithTextures(self.enemyFrames, timePerFrame: 0.1)
        let walkAction = SKAction.repeatActionForever(animatedAction)
        self.runAction(walkAction, withKey: "enemyWalk")
    }
}