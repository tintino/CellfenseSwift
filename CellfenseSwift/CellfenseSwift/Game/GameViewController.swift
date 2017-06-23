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
    @IBOutlet weak var gameView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create size of the game on the screen
        let sceneSize = self.gameView.frame.size
        //let sceneSize = CGSize(width: 320  , height: 480)
        
        //Create game Scene
        let gameScene = GameScene(size: sceneSize)
        gameScene.backgroundColor = UIColor.green
                
        // Configure the view.
        let skView = self.gameView as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        gameScene.scaleMode = .aspectFit
        
        skView.presentScene(gameScene)
        
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
