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
    var gameSceneProtocol : GameSceneProtocol?
    var gameWorld : GameWorldNode!
    var upButton = SKSpriteNode()
    var tower = SKSpriteNode()
    var hud : SKNode!
    var rushButton = SKSpriteNode()
    var hudBackground = SKSpriteNode()
    weak var holderViewController : UIViewController!
    var energy = 0
    var lives = 0
    var state : States!
    
    enum States {
        case PLANNING, DEFENDING, ENDED, RESTARTING, PAUSED
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    init(level: Level, viewController: UIViewController){
        super.init()
        
        self.holderViewController = viewController
        
        //Create Hud container, will contain availables towers
        self.hud = SKNode()
        self.hud.position = CGPoint(x: 0, y: 0)
        self.addChild(self.hud)
        
        //Create background
        self.hudBackground = SKSpriteNode(imageNamed: "hud")
        self.hudBackground.name = Constants.NodeName.hudBackground
        self.hudBackground.anchorPoint = CGPoint(x: 0, y: 0)
        self.hudBackground.position = CGPoint(x: 0, y: 0)
        self.hudBackground.alpha = 0.3
        self.hudBackground.zPosition = Constants.zPosition.hudbackground
        self.hud.addChild(hudBackground)
        
        //Create Tower Button
        self.tower = SKSpriteNode(imageNamed: "turret_frame0")
        self.tower.name = Constants.NodeName.hudTower
        self.tower.anchorPoint = CGPoint(x: 1, y: -1)
        self.tower.position = CGPoint(x: 320, y: 0)
        self.hud.addChild(self.tower)
        
        //Create Up/Down Button
        self.upButton = SKSpriteNode(imageNamed: "up_button")
        self.upButton.name = Constants.NodeName.hudSwitch
        self.upButton.anchorPoint = CGPoint(x: 0, y: 0)
        self.upButton.position = CGPoint(x: 0, y: 0)
        self.addChild(self.upButton)
        
        //Create Rushs Button
        self.rushButton = SKSpriteNode(imageNamed: "rush_button")
        self.rushButton.name = Constants.NodeName.hudRush
        self.rushButton.anchorPoint = CGPoint(x: 0, y: 0)
        self.rushButton.position = CGPoint(x:self.rushButton.frame.size.width, y: 0)
        self.addChild(self.rushButton)
        
        self.state = .PLANNING
        
    }
    
    func hideHud(){
        self.rushButton.alpha = 0.5
        self.hud.isHidden = true
    }
    
    func showHud(){
        self.rushButton.alpha = 1
        self.hud.isHidden = false
        self.isHidden = false
    }
    
    func isHudArea(position: CGPoint) -> Bool {
        if position.y < self.hudBackground.frame.height {
            return true
        }
        else{
            return false
        }
    }
    
    func hideButtons() {
        //TODO: action not working
        self.upButton.run(SKAction.moveBy(x: -self.upButton.frame.width, y: 0, duration: 2000))
    }
    
    func gameCompleted(elapsedTime: Double) {
        //TODO: update game control data
        
        if self.gameSceneProtocol != nil {
            self.gameSceneProtocol!.pauseGame()
        }
        
        //Calc Score
        let intElapsedTime = Int(elapsedTime)
        
        let rootSquare = Double(intElapsedTime*intElapsedTime)
        let lastScore = ((1.0/rootSquare) * 100000.0) + Double(energy * 30);
        
        let alertController = UIAlertController(title: "LevelCompleted".localized,
                                                message: "\("YourScoreIs".localized) \(lastScore)",
            preferredStyle: UIAlertControllerStyle.alert)
        
        
        let okAction = UIAlertAction(title: "Continue".localized, style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            self.continueGame()
        }
        let okCancel = UIAlertAction(title: "TryAgain".localized, style: UIAlertActionStyle.cancel)
        {
            (result : UIAlertAction) -> Void in
            self.tryAgain()
        }
        alertController.addAction(okAction)
        alertController.addAction(okCancel)
        
        self.holderViewController.present(alertController, animated: true, completion: nil)
        self.state = .ENDED
        
    }
    
    func restart(){
        self.state = .PLANNING
        //TODO: [self showButtons];
        self.showHud()
        self.gameWorld.restart()
        self.gameSceneProtocol?.resumeGame()
    }
    
    func continueGame() {
        switch self.state! {
        case .ENDED:
            // LEVEL PASSED
            self.gameSceneProtocol?.dismissGameGame()
            
        default:
            print("")
        }
        
    }
    
    func tryAgain() {
        //ObjC code: - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
        
        switch self.state! {
        case .ENDED:
            
            // DEFEATED
            self.restart()
            
        default:
            print("")
        }
    }
    
    func updateLives(lives: Int){
        self.lives = lives
        
        if self.lives == 0 {
            self.gameSceneProtocol?.pauseGame()
            let alertController = UIAlertController(title: "GameOver".localized,
                                                    message: "Defeated".localized,
                                                    preferredStyle: UIAlertControllerStyle.alert)
            
            
            let okAction = UIAlertAction(title: "TryAgain".localized, style: UIAlertActionStyle.default)
            {
                (result : UIAlertAction) -> Void in
                self.tryAgain()
            }
            let okCancel = UIAlertAction(title: "Back".localized, style: UIAlertActionStyle.cancel)
            {
                (result : UIAlertAction) -> Void in
                self.continueGame()
            }
            alertController.addAction(okAction)
            alertController.addAction(okCancel)
            
            self.holderViewController.present(alertController, animated: true, completion: nil)
            self.state = .ENDED
        }
    }
}
