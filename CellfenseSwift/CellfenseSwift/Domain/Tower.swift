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
    case TURRET = "turret"
    case TANK = "tank"
    case BOMB = "bomb"
}

class Tower: SKSpriteNode {

    var shootingAt: Enemy?
    var range: Double = 0.0
    var type: TowerType!

    private var towerFrames = [SKTexture]()
    private var soundFire: SKAudioNode!
    private var shootTimer: Int = 0
    private var turboTimer: Int = 0
    private var defaultRate: Double = 0.0
    private var tankBase: SKSpriteNode?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    init?(type: TowerType) {

        // Create all Tower Textures
        let towerAnimatedAtlas = SKTextureAtlas(named: "\(type.rawValue)")
        let numberOfTowerFrames = towerAnimatedAtlas.textureNames.count
        for frameIndex in 0..<numberOfTowerFrames {
            let towerTextureName = "\(type)_frame\(frameIndex)"
            towerFrames.append(towerAnimatedAtlas.textureNamed(towerTextureName))
        }

        // Initialize Sprite with First Frame
        super.init(texture: towerFrames[0], color: UIColor.black, size: towerFrames[0].size())

        self.type = type
        self.name = type.rawValue

        // Shared init values
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let fireAudioFile: String!
        // Custom init values for each tower type
        // TODO: change inital values
        switch type {
        case .TURRET:
            range = Constants.Tower.range
            fireAudioFile = "machine_gun"
            defaultRate = Constants.Tower.defaultRate
        case .TANK:
            range = Constants.Tank.range
            fireAudioFile = "cannon"
            defaultRate = Constants.Tank.defaultRate
            tankBase =  SKSpriteNode(imageNamed: "gun_turret_tank_base")
            tankBase?.zPosition = -1
            addChild(tankBase!)
        case .BOMB:
            range = Constants.Tank.range
            fireAudioFile = "chain_gun.wav"
            defaultRate = Constants.Tower.defaultRate
        }

        if let fireURL = Bundle.main.url(forResource: fireAudioFile, withExtension: "m4a") {
            soundFire = SKAudioNode(url: fireURL)
            soundFire.autoplayLooped = false
            addChild(soundFire)
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
        self.run(fireAction, withKey: "towerFire")
        soundFire.stop()
        soundFire.play()
    }

    func rotate(angle: Double) {
        // Avoid tank to rotate
        tankBase?.zRotation = -CGFloat(angle).degreesToRadians()

        run(SKAction.rotate(toAngle: CGFloat(angle).degreesToRadians(), duration: Constants.Tower.rotateSpeed))
    }

    func rate() -> Double {
        if turboTimer < Constants.Tower.turboTime {
            return defaultRate/3
        } else {
            return defaultRate
        }
    }

    func tryShoot(victim: Enemy) -> Bool {

        // Shoot only if im not shooting
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
        switch enemy.type {
        case .SPIDER:
            switch self.type! {
            case .TURRET:
                return Constants.Tower.damageToSpider
            case .TANK:
                return Constants.Tank.damageToSpider
            default:
                break
            }
        case .CATERPILLAR:
            switch self.type! {
            case .TURRET:
                return Constants.Tower.damageToCaterpillar
            case .TANK:
                return Constants.Tank.damageToCaterpillar
            default:
                break
            }
        case .CHIP:
            switch self.type! {
            case .TURRET:
                return Constants.Tower.damageToChip
            case .TANK:
                return Constants.Tank.damageToChip
            default:
                break
            }
        }
        return 0
    }

    func tick(dTime: Double) {
        let intTime = Int(dTime*1000)
        self.turboTimer += intTime
        self.shootTimer += intTime

        //TODO:random crazy tower
    }

    static func hudFileName(forType type: TowerType) -> String {
        return (type == .TANK ? "gun_turret_tank" : "\(type.rawValue)_frame0")
    }
}
