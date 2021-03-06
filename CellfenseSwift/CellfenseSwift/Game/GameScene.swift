//
//  GameScene.swift
//  SpriteKitGameExample
//
//  Created by Tincho on 5/5/16.
//  Copyright © 2016 ag2. All rights reserved.
//
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    // Parent controller needed to show ui alerts.
    weak var holderViewController: UIViewController!

    private var sceneCam: SKCameraNode!
    private var touchedTower: Tower?

    // Vars to hande action on switch area button
    private var cameraOffSet: CGFloat = 0
    private var enemyFieldOffset: CGFloat = 0
    private var defenseFieldOffset: CGFloat = 0

    // Control: Has the play button, switch screen button, hud to add new towers
    private var gameControl: GameControlNode!
    private let levelLoaded: Level?
    private var lastUpdateTime = TimeInterval()

    // World: Has the enemies, installed towers
    private var gameWorld: GameWorldNode!

    // To show messages to the user as position errors, sell?, etc
    private var labelMessage = SKLabelNode()

    required init(size: CGSize, level: Level, holderViewController: UIViewController) {
        self.levelLoaded = level
        self.holderViewController = holderViewController
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {

        // Create the scene’s contents.
        gameControl = GameControlNode(level: levelLoaded!, gameFrame: frame)

        // GameControlNode is ccamera child, the center of the camera is (0,0),
        // width and height are the same as gamescene view
        gameControl.position = CGPoint(x: -frame.midX, y: -frame.midY)

        setupWorldNode()

        setupControlNode()

        // Add Camera Scene
        // The camera’s viewport is the same size as the scene’s viewport (determined by the scene’s size property)
        sceneCam = SKCameraNode()
        camera = sceneCam

        // The energy bar, with button and play button is part of the controls,
        // they need to be on the screen always (they move with the camera)
        camera?.addChild(gameControl)
        addChild(sceneCam)

        // position the camera on the scene. the center of the camera is tied to its position (No anchorpoint)
        sceneCam.position = CGPoint(x: frame.midX, y: frame.midY)

        enemyFieldOffset = frame.midY + frame.maxY
        defenseFieldOffset = frame.midY
        cameraOffSet = enemyFieldOffset

        // Center on the screen
        labelMessage.position = sceneCam.position
        labelMessage.fontSize = 40
        labelMessage.fontColor = UIColor.white
        // self.labelMessage.hidden = true
        addChild(labelMessage)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {

            let location = (touch as UITouch).location(in: self)
            let nodeTouched = atPoint(location)

            if nodeTouched.name == Constants.NodeName.hudSwitch {
                moveCamera()
                return
            }

            // Add a new Tower
            if let hudTowerName = nodeTouched.name,
                gameControl.isHudTowerName(name: hudTowerName),
                let hudTowerType = TowerType(rawValue: hudTowerName) {

                touchedTower = Tower(type: hudTowerType)
                touchedTower?.alpha = 0.5
                // Offset on Y: avoid the tower to be under the finger
                touchedTower!.position = CGPoint(x: location.x,
                                                 y: location.y + touchedTower!.size.height)
                addChild(touchedTower!)
            }
            // Relocate a Tower
            else if let worldTower = gameWorld.towerAtLocation(location) {
                // Reuse same flow as "add a new tower" to Keep It Simple
                touchedTower = worldTower
                gameWorld.removeTowerAtLocation(location)
            } else if nodeTouched.name == Constants.NodeName.hudRush {
                gameWorld.startDefending()
                //TODO: hideButtons not working
                //self.gameControl.hideButtons()
                //self.gameControl.hideHud()
                gameControl.isHidden = true
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {

            let location = (touch as UITouch).location(in: self)
            // let nodeTouched = atPoint(location)
            _ = atPoint(location)

            if let tower = touchedTower {

                // Offset on Y: mantain the tower on the finger
                tower.position = gameWorld.worldToGrid(location)

                // If Overlaping another tower, show it red
                if gameWorld.towerAtLocation(tower.position) != nil {

                    tower.color = UIColor.red
                    tower.colorBlendFactor = Constants.Tower.opacity
                } else {
                    tower.colorBlendFactor = 0.0
                }

                if gameControl.isHudArea(position: tower.position) {
                    showMessage(message: "SELL?")
                } else {
                    self.hideMessage()
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {

            let location = (touch as UITouch).location(in: self)
            // let nodeTouched = self.atPoint(location)
            _ = atPoint(location)

            // User is holding a new tower
            if let touchedTower = touchedTower {

                // And Want to sell it
                if gameControl.isHudArea(position: touchedTower.position) {
                    showAutoHideMessage(message: "SELL?")
                }
                // And want to place it
                else if gameWorld.towerAtLocation(touchedTower.position) == nil {

                    // And is not blocking the path
                    if gameWorld.doesBlockPathIfAddedTo(position: touchedTower.position),
                        let towerName = touchedTower.name,
                        let towerType = TowerType(rawValue: towerName) {
                        gameWorld.add(towerType: towerType, atPosition: touchedTower.position)
                    } else {
                        showAutoHideMessage(message: "BLOCKING!")
                    }
                }

                // Added (available place) or not (occupied place, block or sell) to the world,
                // we remove the touched tower
                touchedTower.removeFromParent()
                self.touchedTower = nil
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if !isPaused {
            let timeSinceLastUpdate = currentTime - lastUpdateTime
            lastUpdateTime = currentTime

            gameWorld.update(dTime: timeSinceLastUpdate)
        }
    }

    override func didFinishUpdate() {
    }

    private func setupWorldNode() {
        gameWorld = GameWorldNode(level: levelLoaded!)

        gameWorld.onGameComplete = { time in
            self.gameControl.gameCompleted(elapsedTime: time)
        }

        gameWorld.onUpdateLives = { lives in
            self.gameControl.updateLives(lives: lives)
        }

        addChild(gameWorld)
    }

    private func setupControlNode() {

        gameControl.onGameComplete = { score in
            self.pauseGame()
            let alertController = UIAlertController(title: "LevelCompleted".localized,
                                                    message: "\("YourScoreIs".localized) \(score)",
                preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Continue".localized, style: .default) { result in
                self.dissmissGame()
            }
            let okCancel = UIAlertAction(title: "TryAgain".localized, style: .cancel) { result in
                self.gameRestart()
            }
            alertController.addAction(okAction)
            alertController.addAction(okCancel)

            self.holderViewController.present(alertController, animated: true, completion: nil)
        }

        gameControl.onGameLost = {
            let alertController = UIAlertController(title: "GameOver".localized,
                                                    message: "Defeated".localized,
                                                    preferredStyle: UIAlertController.Style.alert)

            let okAction = UIAlertAction(title: "TryAgain".localized, style: .default) { result in
                self.gameRestart()
            }
            let okCancel = UIAlertAction(title: "Back".localized, style: .cancel) { result in
                self.dissmissGame()
            }
            alertController.addAction(okAction)
            alertController.addAction(okCancel)

            self.holderViewController.present(alertController, animated: true, completion: nil)
        }
    }

    private func moveCamera() {
        // All these variables and logic, are just to handle if the user touches
        // very quickly the "switch button" before the action finished
        sceneCam.run(SKAction.moveTo(y: cameraOffSet, duration: 0.3))
        if cameraOffSet == enemyFieldOffset {
            cameraOffSet = defenseFieldOffset
            gameControl.hideHud()
        } else {
            cameraOffSet = enemyFieldOffset
            gameControl.showHud()
        }
    }

    private func showAutoHideMessage(message: String) {

        showMessage(message: message)
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(GameScene.hideMessage),
                             userInfo: nil,
                             repeats: false)
    }

    private func showMessage(message: String) {
        self.labelMessage.text = message
        self.labelMessage.isHidden = false
    }

    @objc func hideMessage() {
        labelMessage.isHidden = true
    }

    private func pauseGame() {
        scene?.isPaused = true
    }

    private func resumeGame() {
        scene?.isPaused = false
    }

    private func dissmissGame() {
        holderViewController.dismiss(animated: true, completion: nil)
    }

    private func gameRestart() {
        gameControl.showHud()
        gameWorld.restart()
        resumeGame()
    }
}
