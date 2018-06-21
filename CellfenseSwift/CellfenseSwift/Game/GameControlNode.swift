//
//  ControlLayer.swift
//  CellfenseSwift
//
//  Created by Tincho on 9/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import SpriteKit

class GameControlNode: SKNode, UIAlertViewDelegate {
    // Delegate methods
    var onGameComplete: ((_ score: Double) -> Void)?
    var onGameLost: (() -> Void)?

    private var hudBackground = SKSpriteNode()
    private var rushButton = SKSpriteNode()
    private var upButton = SKSpriteNode()
    private var tower = SKSpriteNode()
    private var hud: SKNode!
    private var energy = 0
    private var lives = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    init(level: Level) {
        super.init()
        
        // Create Hud container, will contain availables towers
        hud = SKNode()
        hud.position = CGPoint(x: 0, y: 0)
        addChild(hud)

        // Create background
        hudBackground = SKSpriteNode(imageNamed: "hud")
        hudBackground.name = Constants.NodeName.hudBackground
        hudBackground.anchorPoint = CGPoint(x: 0, y: 0)
        hudBackground.position = CGPoint(x: 0, y: 0)
        hudBackground.alpha = 0.3
        hudBackground.zPosition = Constants.Zposition.hudbackground
        hud.addChild(hudBackground)

        // Create Tower Button
        tower = SKSpriteNode(imageNamed: "turret_frame0")
        tower.name = Constants.NodeName.hudTower
        tower.anchorPoint = CGPoint(x: 1, y: -1)
        tower.position = CGPoint(x: 320, y: 0)
        hud.addChild(self.tower)

        // Create Up/Down Button
        upButton = SKSpriteNode(imageNamed: "up_button")
        upButton.name = Constants.NodeName.hudSwitch
        upButton.anchorPoint = CGPoint(x: 0, y: 0)
        upButton.position = CGPoint(x: 0, y: 0)
        addChild(self.upButton)

        // Create Rushs Button
        rushButton = SKSpriteNode(imageNamed: "rush_button")
        rushButton.name = Constants.NodeName.hudRush
        rushButton.anchorPoint = CGPoint(x: 0, y: 0)
        rushButton.position = CGPoint(x: rushButton.frame.size.width, y: 0)
        addChild(self.rushButton)

    }

    func hideHud() {
        rushButton.alpha = 0.5
        hud.isHidden = true
    }

    func showHud() {
        rushButton.alpha = 1
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
}
