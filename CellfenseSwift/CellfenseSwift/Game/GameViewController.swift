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
        let sceneSize = self.gameView.frame.size
        //let sceneSize = CGSize(width: 320  , height: 480)

        //Create game Scene
        let gameScene = GameScene(size: sceneSize, level: self.levelToLoad, holderViewController: self)
        gameScene.backgroundColor = UIColor.green

        // Configure the view.
        if let skView = self.gameView as? SKView {
            skView.showsFPS = true
            skView.showsNodeCount = true

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            /* Set the scale mode to scale to fit the window */
            gameScene.scaleMode = .aspectFit

            skView.presentScene(gameScene)
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
