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
    // MARK: Delegates Methods
    var onGameComplete: ((_ score: Double) -> Void)?
    var onGameLost: (() -> Void)?

    private var hudBackground = SKShapeNode()
    private var rushButton = SKSpriteNode()
    private var upButton = SKSpriteNode()
    private var armory: [SKSpriteNode] = []
    private var hud: SKNode!
    private var energy = 0
    private var lives = 0
    private var towerTypesOnLevel = Set<String>()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    init(level: Level, gameFrame: CGRect) {
        super.init()

        // Create Hud Container
        hud = SKNode()
        hud.position = CGPoint(x: 0, y: 0)
        addChild(hud)

        // Create Up/Down Button
        upButton = SKSpriteNode(imageNamed: "up_button")
        upButton.name = Constants.NodeName.hudSwitch
        upButton.anchorPoint = CGPoint(x: 0, y: 0)
        upButton.position = CGPoint(x: 0, y: 0)
        addChild(upButton)

        // Create Rushs Button
        rushButton = SKSpriteNode(imageNamed: "rush_button")
        rushButton.name = Constants.NodeName.hudRush
        rushButton.anchorPoint = CGPoint(x: 0, y: 0)
        rushButton.position = CGPoint(x: upButton.frame.size.width, y: 0)
        addChild(rushButton)

        // Create background
        let hudBackgroundSize = CGRect(x: 0, y: 0, width: gameFrame.width, height: upButton.frame.size.height)
        hudBackground = SKShapeNode(rect: hudBackgroundSize)
        hudBackground.name = Constants.NodeName.hudBackground
        hudBackground.fillColor = .black
        hudBackground.lineWidth = 0
        //hudBackground.anchorPoint = CGPoint(x: 0, y: 0)
        hudBackground.position = CGPoint(x: 0, y: 0)
        hudBackground.alpha = 0.3
        hudBackground.zPosition = Constants.Zposition.hudbackground
        hud.addChild(hudBackground)

        // Create Tower Button
        for (index, type) in level.towers.enumerated() {
            let fileName = Tower.hudFileName(forType: type)
            let tower = SKSpriteNode(imageNamed: fileName)
            tower.name = type.rawValue
            tower.anchorPoint = CGPoint(x: 1, y: -1)
            tower.position = CGPoint(x: (Int(hudBackgroundSize.width) - (index * Int(rushButton.frame.size.width))),
                                         y: 0)
            hud.addChild(tower)
            towerTypesOnLevel.insert(type.rawValue)
        }
    }

    // MARK: public methods
    func hideHud() {
        rushButton.alpha = 0.5
        rushButton.isUserInteractionEnabled = true
        hud.isHidden = true
    }

    func showHud() {
        rushButton.alpha = 1
        rushButton.isUserInteractionEnabled = false
        hud.isHidden = false
        isHidden = false
    }

    func isHudArea(position: CGPoint) -> Bool {
        return position.y < hudBackground.frame.height ? true : false
    }

    func hideButtons() {
        //TODO: action not working
        upButton.run(SKAction.moveBy(x: -upButton.frame.width, y: 0, duration: 2000))
    }

    func gameCompleted(elapsedTime: Double) {
        // TODO: update game control data

        // Calc final Score
        let intElapsedTime = Int(elapsedTime)
        let rootSquare = Double(intElapsedTime*intElapsedTime)
        let lastScore = ((1.0/rootSquare) * 100000.0) + Double(energy * 30)

        onGameComplete?(lastScore)
    }

    func updateLives(lives: Int) {
        self.lives = lives
        if lives == 0 { onGameLost?() }
    }

    func isHudTowerName(name: String) -> Bool {
        let result = towerTypesOnLevel.first {
            $0 == name
        }
        return result != nil ? true : false
    }
}
