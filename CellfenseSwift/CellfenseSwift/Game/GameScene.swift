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

    let levelLoaded: Level?
    var lastUpdateTime = TimeInterval()

    // Control: Has the play button, switch screen button, hud to add new towers
    var gameControl: GameControlNode!

    // World: Has the enemies, installed towers
    var gameWorld: GameWorldNode!

    var sceneCam: SKCameraNode!

    // Vars to hande action on switch area button
    var cameraOffSet: CGFloat = 0
    var enemyFieldOffset: CGFloat = 0
    var defenseFieldOffset: CGFloat = 0

    var touchedTower: SKSpriteNode?
    
    // To show messages to the user as position errors, sell?, etc
    var labelMessage = SKLabelNode()

    weak var holderViewController: UIViewController!

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
        self.gameControl = GameControlNode(level: self.levelLoaded!)
        //**self.gameControl.gameSceneProtocol = self

        // GameControlNode is ccamera child, the center of the camera is (0,0),
        // width and height are the same as gamescene view
        self.gameControl.position = CGPoint(x: -self.frame.midX, y: -self.frame.midY)

        setupWorldNode()

        // TODO: better way to do this? a pattern? cross dependency cannot use constructor to inyect dependency
        //**self.gameWorld.gameControl = self.gameControl
        //**self.gameControl.gameWorld = self.gameWorld
        setupControlNode()

        // Add Camera Scene
        // The camera’s viewport is the same size as the scene’s viewport (determined by the scene’s size property)
        sceneCam = SKCameraNode()
        self.camera = sceneCam

        // The energy bar, with button and play button is part of the controls,
        // they need to be on the screen always (they move with the camera)
        self.camera?.addChild(self.gameControl)
        addChild(sceneCam)

        // position the camera on the scene. the center of the camera is tied to its position (No anchorpoint)
        sceneCam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        self.enemyFieldOffset = self.frame.midY + self.frame.maxY
        self.defenseFieldOffset = self.frame.midY
        self.cameraOffSet = enemyFieldOffset

        // Center on the screen
        self.labelMessage.position = self.sceneCam.position
        self.labelMessage.fontSize = 40
        self.labelMessage.fontColor = UIColor.white
        // self.labelMessage.hidden = true
        self.addChild(self.labelMessage)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {

            let location = (touch as UITouch).location(in: self)
            let nodeTouched = self.atPoint(location)

            if nodeTouched.name == Constants.NodeName.hudSwitch {
                moveCamera()
                return
            }

            // Add a new Tower
            if nodeTouched.name == Constants.NodeName.hudTower {
                self.touchedTower = SKSpriteNode(imageNamed: "turret_frame0")
                self.touchedTower?.alpha = 0.5

                //Offset on Y: avoid the tower to be under the finger
                self.touchedTower!.position = CGPoint(x: location.x,
                                                      y: location.y + self.touchedTower!.size.height)
                self.addChild(self.touchedTower!)
            }
            // Relocate a Tower
            else if let worldTower = self.gameWorld.towerAtLocation(location) {
                // Reuse same flow as "add a new tower" to Keep It Simple
                self.touchedTower = worldTower
                self.gameWorld.removeTowerAtLocation(location)
            } else if nodeTouched.name == Constants.NodeName.hudRush {
                self.gameWorld.startDefending()
                //TODO: hideButtons not working
                //self.gameControl.hideButtons()
                //self.gameControl.hideHud()
                self.gameControl.isHidden = true
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {

            let location = (touch as UITouch).location(in: self)
            // let nodeTouched = self.atPoint(location)
            _ = self.atPoint(location)

            if let touchedTower = self.touchedTower {

                // Offset on Y: mantain the tower on the finger
                touchedTower.position = self.gameWorld.worldToGrid(location)

                // If Overlaping another tower, show it red
                if self.gameWorld.towerAtLocation(touchedTower.position) != nil {

                    touchedTower.color = UIColor.red
                    touchedTower.colorBlendFactor = Constants.Tower.opacity
                } else {
                    touchedTower.colorBlendFactor = 0.0
                }

                if self.gameControl.isHudArea(position: touchedTower.position) {
                    self.showMessage(message: "SELL?")
                } else {
                    self.hideMessage()
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {

            let location = (touch as UITouch).location(in: self)
            //let nodeTouched = self.atPoint(location)
            _ = self.atPoint(location)

            //User is holding a new tower
            if let touchedTower = self.touchedTower {

                //And Want to sell it
                if self.gameControl.isHudArea(position: touchedTower.position) {
                    self.showAutoHideMessage(message: "SELL?")
                }
                    //And want to place it
                else if self.gameWorld.towerAtLocation(touchedTower.position) == nil {

                    //And is not blocking the path
                    if self.gameWorld.doesBlockPathIfAddedTo(position: touchedTower.position) {
                        self.gameWorld.addTower(touchedTower.position)
                    } else {
                        self.showAutoHideMessage(message: "BLOCKING!")
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
        if !self.isPaused {
            let timeSinceLastUpdate = currentTime - lastUpdateTime
            lastUpdateTime = currentTime

            self.gameWorld.update(dTime: timeSinceLastUpdate)
        }
    }

    override func didFinishUpdate() {
    }

    func setupWorldNode() {
        gameWorld = GameWorldNode(level: self.levelLoaded!)

        gameWorld.onGameComplete = { time in
            print("CF: gameWorld.onGameComplete")
            self.gameControl.gameCompleted(elapsedTime: time)
        }

        gameWorld.onUpdateLives = { lives in
            print("CF: gameWorld.onUpdateLives")
            self.gameControl.updateLives(lives: lives)
        }

        addChild(gameWorld)
    }

    func setupControlNode() {

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

    func moveCamera() {
        // All these variables and logic, are just to handle if the user touches
        // very quickly the "switch button" before the action finished
        self.sceneCam.run(SKAction.moveTo(y: cameraOffSet, duration: 0.3))
        if self.cameraOffSet == self.enemyFieldOffset {

            self.cameraOffSet = self.defenseFieldOffset
            self.gameControl.hideHud()
        } else {
            self.cameraOffSet = self.enemyFieldOffset
            self.gameControl.showHud()
        }
    }

    func showAutoHideMessage(message: String) {

        self.showMessage(message: message)
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(GameScene.hideMessage),
                             userInfo: nil,
                             repeats: false)
    }

    func showMessage(message: String) {
        self.labelMessage.text = message
        self.labelMessage.isHidden = false
    }

    @objc func hideMessage() {
        self.labelMessage.isHidden = true
    }

    func pauseGame() {
        self.scene?.isPaused = true
    }

    func resumeGame() {
        self.scene?.isPaused = false
    }

    func dissmissGame() {
        self.holderViewController.dismiss(animated: true, completion: nil)
    }

    func gameRestart() {
        self.gameControl.showHud()
        self.gameWorld.restart()
        self.resumeGame()
    }
}
