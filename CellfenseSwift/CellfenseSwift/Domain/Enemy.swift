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
    case SPIDER = "Spider"
}

class Enemy: SKSpriteNode {
    
    var enemyFrames = [SKTexture]()
    var path = []
    
    //TODO: directions to integers
    var dirX : CGFloat = 0
    var dirY : CGFloat = 0
    var life : CGFloat = 0
    var pathIndex = 0
    var col = 7
    var row = 23
    
    let myLabel = SKLabelNode()
    
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
        self.life = 100
        self.speed = 1.4
        
        //Debug Information
        myLabel.fontSize = 12
        myLabel.position = CGPointMake(0,self.frame.minY)
        myLabel.fontColor = UIColor.whiteColor()
        self.addChild(myLabel)
    }
    
    override var position: CGPoint{
        willSet {
            myLabel.text = "Y: \(newValue.y)";
        }
    }
    
    func Walk(){
        let animatedAction = SKAction.animateWithTextures(self.enemyFrames, timePerFrame: 0.1)
        let walkAction = SKAction.repeatActionForever(animatedAction)
        self.runAction(walkAction, withKey: "enemyWalk")
    }
    
    func rotate(angle: Int){
        self.runAction(SKAction.rotateToAngle(CGFloat(angle).degreesToRadians(), duration: Constants.Enemy.rotateSpeed))
    }
    
    func  shoot(damage: CGFloat){
        if self.life != 0 {
            self.life -= damage
        }
        
        if self.life <= 0 {
            self.life = 0
            
            //TODO: enemy destroy
            
            self.removeAllActions()
        }
        
        //TODO: calc life width bar
    }
}