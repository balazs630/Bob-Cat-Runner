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
            // Load the SKScene according to actual stage
            if let scene = SKScene(fileNamed: Stage().name) {
                // Set the scale mode to scale to fit the display
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            // For debug purpose
            //view.showsFPS = true
            //view.showsNodeCount = true
            //view.showsDrawCount = true
            //view.showsQuadCount = true
            //view.showsPhysics = true
            //view.showsFields = true
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
