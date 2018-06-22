//
//  Tower.swift
//  CellfenseSwift
//
//  Created by Tincho on 8/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import SpriteKit

enum TowerType: String {
    case TURRET = "Turret"
}

class Tower: SKSpriteNode {

    var shootingAt: Enemy?
    var range: Double = 0.0

    private var towerFrames = [SKTexture]()
    private var fireSoundFileName = ""
    private var shootTimer: Int = 0
    private var turboTimer: Int = 0
    private var defaultRate: Double = 0.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    init?(type: TowerType) {

        //Create all Tower Textures
        let towerAnimatedAtlas = SKTextureAtlas(named: "\(type.rawValue)")
        let numberOfTowerFrames = towerAnimatedAtlas.textureNames.count
        for frameIndex in 0..<numberOfTowerFrames {
            let towerTextureName = "\(type)_frame\(frameIndex)"
            towerFrames.append(towerAnimatedAtlas.textureNamed(towerTextureName))
        }

        //Initialize Sprite with First Frame
        super.init(texture: towerFrames[0], color: UIColor.black, size: towerFrames[0].size())

        //Shared init values
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        //Custom init values for each tower type
        switch type {
        case TowerType.TURRET:
            range = Constants.Tower.range
            fireSoundFileName = "chain_gun.wav"
            defaultRate = Constants.Tower.defaultRate
        }

        //Shoot Radio. This will not affect the SKSpriteNode Size
        let radioShootArea = SKShapeNode(circleOfRadius: frame.size.width * CGFloat(range) )
        radioShootArea.position = CGPoint(x: frame.midX, y: frame.midY)
        radioShootArea.strokeColor = SKColor.green
        radioShootArea.lineWidth = 1
        radioShootArea.alpha = 0.2
        addChild(radioShootArea)

        /*
        let blockArea = SKShapeNode(rect: self.frame)
        blockArea.lineWidth = 1
        blockArea.strokeColor = SKColor.cyanColor()
        blockArea.position = CGPointMake(frame.midX, frame.midY)
        self.addChild(blockArea)
        */
    }

    // MARK: public methods
    
    func fire() {
        let animatedAction = SKAction.animate(with: towerFrames, timePerFrame: 0.1)
        let fireAction = SKAction.repeat(animatedAction, count: 1)
        //let fireSoundAction = SKAction.playSoundFileNamed(fireSoundFileName, waitForCompletion: false)
        self.run(fireAction, withKey: "towerFire")
        //self.run(fireSoundAction)
    }

    func rotate(angle: Double) {
        self.run(SKAction.rotate(toAngle: CGFloat(angle).degreesToRadians(), duration: Constants.Tower.rotateSpeed))
    }

    func rate() -> Double {
        if turboTimer < Constants.Tower.turboTime {
            return defaultRate/3
        } else {
            return defaultRate
        }
    }

    func tryShoot(victim: Enemy) -> Bool {

        //Shoot only if im not shooting
        if shootTimer  >= Int(defaultRate * 1000) {
            shootTimer = 0

            victim.shoot(damage: damage(enemy: victim))

            fire()
            return true
        } else {
            //Im shooting
            return false
        }
    }

    func damage(enemy: Enemy) -> Double {
        //TODO compare all towers and enemies
        return 13.0
    }

    func tick(dTime: Double) {
        let intTime = Int(dTime*1000)
        self.turboTimer += intTime
        self.shootTimer += intTime

        //TODO:random crazy tower
    }
}
