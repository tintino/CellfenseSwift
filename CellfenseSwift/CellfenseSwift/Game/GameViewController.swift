//
//  GameViewController.swift
//  CellfenseSwift
//
//  Created by Tincho on 7/5/16.
//  Copyright (c) 2016 quitarts. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var gameView: UIView!

    public var levelToLoad = Level()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Create size of the game on the screen
        let sceneSize = gameView.frame.size
        //let sceneSize = CGSize(width: 320  , height: 480)

        let gameScene = createGameScene(sceneSize: sceneSize)

        // Configure the view.
        if let skView = gameView as? SKView {
            skView.showsFPS = true
            skView.showsNodeCount = true

            // Sprite Kit applies additional optimizations to improve rendering performance.
            skView.ignoresSiblingOrder = true

            //Set the scale mode to scale to fit the window.
            gameScene.scaleMode = .aspectFit

            skView.presentScene(gameScene)
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private func createGameScene(sceneSize size: CGSize) -> GameScene {
        let gameScene = GameScene(size: size, level: levelToLoad)

        gameScene.showAlert = { (title, message, positive, negative, onPositive, onNegative) -> Void in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: positive, style: .default) { result in
                onPositive()
            }
            let okCancel = UIAlertAction(title: negative, style: .cancel) { result in
                onNegative()
            }
            alertController.addAction(okAction)
            alertController.addAction(okCancel)
            self.present(alertController, animated: true, completion: nil)
        }

        gameScene.onGameEnded = {
            self.dismiss(animated: true, completion: nil)
        }

        gameScene.backgroundColor = UIColor.green
        return gameScene
    }
}
