//
//  GameViewController.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 05. 22..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as? SKView {
            // Load the actual stage
            if let scene = SKScene(fileNamed: Stage.name) {
                if isIphoneX {
                    scene.scaleMode = .resizeFill
                } else {
                    scene.scaleMode = .aspectFill
                }

                // Present the scene
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true
            view.isDebugEnabled(false)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension GameViewController {
    var isIphoneX: Bool {
        let aspectRatio = Double(view.frame.width/view.frame.height)
        let iphoneXAspectRatio = 2436.0/1125.0
        return (aspectRatio == iphoneXAspectRatio) ? true : false
    }

    var isIPad: Bool {
        let aspectRatio = view.frame.width/view.frame.height
        return aspectRatio < 1.5 ? true : false
    }
}
