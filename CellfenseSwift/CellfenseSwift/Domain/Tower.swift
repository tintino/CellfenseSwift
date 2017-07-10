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
    var shootingAt : Enemy?
    var shootTimer : Int = 0
    var turboTimer : Int = 0
    var defaultRate : CGFloat = 0.0
    
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
        super.init(texture: self.towerFrames[0], color: UIColor.black, size:self.towerFrames[0].size())
        
        //Shared init values
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
        //Custom init values for each tower type
        switch type {
            
        case TowerType.TURRET:
            self.range = Constants.Tower.range
            self.fireSoundFileName = "chain_gun.wav"
            self.defaultRate = Constants.Tower.defaultRate
            
        }
        
        //Shoot Radio. This will not affect the SKSpriteNode Size
        
        let radioShootArea = SKShapeNode(circleOfRadius: self.frame.size.width * self.range )
        radioShootArea.position = CGPoint(x: frame.midX, y: frame.midY)
        radioShootArea.strokeColor = SKColor.green
        radioShootArea.lineWidth = 1
        radioShootArea.alpha = 0.2
        self.addChild(radioShootArea)
        
        /*
        let blockArea = SKShapeNode(rect: self.frame)
        blockArea.lineWidth = 1
        blockArea.strokeColor = SKColor.cyanColor()
        blockArea.position = CGPointMake(frame.midX, frame.midY)
        self.addChild(blockArea)
        */
    }
    
    func fire(){
        let animatedAction = SKAction.animate(with: self.towerFrames, timePerFrame: 0.1)
        let fireAction = SKAction.repeat(animatedAction, count:1)
        //let fireSoundAction = SKAction.playSoundFileNamed(fireSoundFileName, waitForCompletion: false)
        self.run(fireAction, withKey: "towerFire")
        //self.run(fireSoundAction)
    }
    
    func rotate(angle: CGFloat){
        self.run(SKAction.rotate(toAngle: angle.degreesToRadians(), duration: Constants.Tower.rotateSpeed))
    }
    
    func rate() -> CGFloat{
        if self.turboTimer < Constants.Tower.turboTime{
            return self.defaultRate/3
        }
        else{
            return self.defaultRate
        }
    }
    
    func tryShoot(victim: Enemy) -> Bool{
        
        //Shoot only if im not shooting
        if self.shootTimer  >= Int(self.defaultRate * 1000) {
            self.shootTimer = 0
            
            victim.shoot(damage: self.damage(enemy: victim))
            
            self.fire()
            return true
        }
        else{
            //Im shooting
            return false
        }
    }
    
    func damage(enemy: Enemy) -> CGFloat{
        //TODO compare all towers and enemies
        return 13
    }
    
    func tick(dt: Double){
        let intTime = Int(dt*1000)
        self.turboTimer += intTime
        self.shootTimer += intTime
        
        //TODO:random crazy tower
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
