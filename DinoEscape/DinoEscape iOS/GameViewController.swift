//
//  GameViewController.swift
//  DinoEscape iOS
//
//  Created by Felipe Leite on 07/03/22.
//

// swiftlint:disable force_cast

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var gController: GameCenterController?

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = HomeScene.newGameScene()

        let gController = GameCenterController(viewController: self)
        gController.setupActionPoint(location: .bottomLeading, showHighlights: true, isActive: true)
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
