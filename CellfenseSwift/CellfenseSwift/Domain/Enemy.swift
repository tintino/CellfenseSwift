//
//  Enemy.swift
//  CellfenseSwift
//
//  Created by Tincho on 9/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import SpriteKit

enum EnemyType : String {
    case CATERPILLAR = "Caterpillar"
}

class Enemy: SKSpriteNode {
    
    var enemyFrames = [SKTexture]()
    var path = []
    
    //TODO: directions to integers
    var dirX : CGFloat = 0
    var dirY : CGFloat = 0
    var pathIndex = 0
    var col = 3
    var row = 1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(type: EnemyType){
        
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
                
        self.name = Constants.NodeName.enemy
    }
    
    func Walk(){
        let animatedAction = SKAction.animateWithTextures(self.enemyFrames, timePerFrame: 0.1)
        let walkAction = SKAction.repeatActionForever(animatedAction)
        self.runAction(walkAction, withKey: "enemyWalk")
    }
}