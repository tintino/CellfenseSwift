//
//  Enemy.swift
//  CellfenseSwift
//
//  Created by Tincho on 9/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import SpriteKit

enum EnemyType: String {
    case CATERPILLAR = "caterpillar"
    case SPIDER = "spider"
    case CHIP = "chip"
}

class Enemy: SKNode {
    //TODO: directioPathFindNodens to integers

    var type: EnemyType = EnemyType.SPIDER
    var dirX: CGFloat = 0
    var dirY: CGFloat = 0
    var life: Double = Constants.Enemy.startLife
    var path = [Any]()
    var pathIndex = 0
    var col = 0
    var row = 0

    private var enemyFrames = [SKTexture]()
    private let labelDebugInfo = SKLabelNode()
    private var energyBar: SKShapeNode!
    private var lifeWidth = 0.0
    private var critrure: SKSpriteNode!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    init?(type: EnemyType) {
        super.init()
        // TODO: This code is the same on Tower, try to optimize
        self.type = type
        // Create all Tower Textures
        let enemyAnimatedAtlas = SKTextureAtlas(named: "\(type.rawValue)")
        let numberOfEnemyFrames = enemyAnimatedAtlas.textureNames.count
        for frameIndex in 0..<numberOfEnemyFrames {
            let enemyTextureName = "\(type)_frame\(frameIndex)"
            enemyFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
        }

        // Initialize Sprite with First Frame
        critrure = SKSpriteNode(texture: enemyFrames[0], color: UIColor.black, size: enemyFrames[0].size())
        addChild(critrure)
        name = Constants.NodeName.enemy
        speed = 1.4

        // Enery bar
        energyBar = SKShapeNode()
        energyBar.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                          y: 0,
                                                          width: critrure.size.width,
                                                          height: Constants.Enemy.energyBarHeight),
                                      cornerRadius: 0).cgPath
        energyBar.position = CGPoint(x: -critrure.size.width/2,
                                     y: (critrure.size.height/2) + Constants.Enemy.energyBarPadding)
        energyBar.fillColor = Constants.Color.energyBarGreen
        energyBar.lineWidth = 0
        addChild(energyBar)

        //zRotation = CGFloat(90).degreesToRadians()
        // Debug Information

        //labelDebugInfo.fontSize = 12
        //labelDebugInfo.position = CGPoint(x: 0, y: frame.minY)
        //labelDebugInfo.fontColor = UIColor.white
        //addChild(labelDebugInfo)

    }

    /*override var position: CGPoint {
        willSet {
            labelDebugInfo.text = "Y: \(newValue.y)"
        }
    }*/

    private func updateEnergyBar() {
        let newSize = life*100 / Constants.Enemy.startLife
        energyBar.xScale = CGFloat(newSize/100)
        if life < Constants.Enemy.criticPercentageLife {
            energyBar.fillColor = Constants.Color.energyBarYellow
        }
    }
    // MARK: public methods

    func walk() {
        let animatedAction = SKAction.animate(with: enemyFrames, timePerFrame: 0.1)
        let walkAction = SKAction.repeatForever(animatedAction)
        critrure.run(walkAction, withKey: "enemyWalk")
    }

    func rotate(angle: Int) {
        critrure.run(SKAction.rotate(toAngle: CGFloat(angle).degreesToRadians(), duration: Constants.Enemy.rotateSpeed))
    }

    func  shoot(damage: Double) {
        if life != 0.0 {
            life -= damage
        }

        if life <= 0.0 {
            life = 0.0
            // TODO: enemy destroy
            removeAllActions()
        }

        updateEnergyBar()
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = Enemy(type: type)
        copy?.position = position
        copy?.col = col
        copy?.row = row
        return copy!
    }
}
