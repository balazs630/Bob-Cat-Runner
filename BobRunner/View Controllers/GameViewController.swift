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
    let buttonView = ButtonView()

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSelf()
    }
}

// MARK: - Screen configuration
extension GameViewController {
    private func configureSelf() {
        guard let view = view as? SKView else { return }
        guard let scene = SKScene(fileNamed: Stage.name) else { return }
        scene.scaleMode = view.hasTopNotch ? .resizeFill : .aspectFill

        buttonView.alignCenter(in: view)
        buttonView.setActions(for: self)
        view.addSubviews(buttonView.buttons)

        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        view.isDebugEnabled(false)
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

// MARK: - Button actions
extension GameViewController {
    @objc func loadNextStage() {
        Stage.current += 1
        presentScene()
        buttonView.btnLoadNextStage.isHidden = true
    }

    @objc func reloadStage() {
        presentScene()
        buttonView.btnReloadStage.isHidden = true
    }

    @objc func replayGame() {
        Stage.current = 1
        presentScene()
        buttonView.btnReplayGame.isHidden = true
    }

    private func presentScene() {
        if let view = view as? SKView {
            view.presentScene(SKScene(fileNamed: Stage.name))
        }
    }
}
