//
//  GameViewController.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 05. 22..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController {

    // MARK: Properties
    let btnLoadNextStage = UIButton(frame: Button.Frame.narrow)
    let btnReloadStage = UIButton(frame: Button.Frame.narrow)
    let btnReplayGame = UIButton(frame: Button.Frame.wide)

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as? SKView {
            // Load the actual stage
            if let scene = SKScene(fileNamed: Stage.name) {
                if view.isIphoneX() {
                    scene.scaleMode = .resizeFill
                } else {
                    scene.scaleMode = .aspectFill
                }

                initButtons()
                view.addSubviews([btnLoadNextStage, btnReloadStage, btnReplayGame])

                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true
            view.isDebugEnabled(false)
        }
    }

    // MARK: - Screen configuration
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

// MARK: - Setup
extension GameViewController {
    private func initButtons() {
        guard let view = self.view as? SKView else { return }

        btnLoadNextStage.alignCenter(in: view)
        btnLoadNextStage.setDefaultAttributes(title: "Start Stage \(Stage.current + 1)!")
        btnLoadNextStage.addTarget(self, action: #selector(loadNextStage), for: .touchUpInside)
        btnLoadNextStage.tag = Button.NextStage.tag

        btnReloadStage.alignCenter(in: view)
        btnReloadStage.setDefaultAttributes(title: "Retry stage!")
        btnReloadStage.addTarget(self, action: #selector(reloadStage), for: .touchUpInside)
        btnReloadStage.tag = Button.ReloadStage.tag

        btnReplayGame.alignCenter(in: view)
        btnReplayGame.setDefaultAttributes(title: "Replay game from Stage 1!")
        btnReplayGame.addTarget(self, action: #selector(replayGame), for: .touchUpInside)
        btnReplayGame.tag = Button.ReplayGame.tag
    }
}

// MARK: - Actions
extension GameViewController {
    @objc func loadNextStage() {
        Stage.current += 1
        presentScene()
        btnLoadNextStage.isHidden = true
    }

    @objc func reloadStage() {
        presentScene()
        btnReloadStage.isHidden = true
    }

    @objc func replayGame() {
        Stage.current = 1
        presentScene()
        btnReplayGame.isHidden = true
    }

    private func presentScene() {
        if let view = self.view as? SKView {
            view.presentScene(SKScene(fileNamed: Stage.name))
        }
    }
}
