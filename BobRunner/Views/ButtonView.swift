//
//  ButtonView.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2018. 05. 11..
//  Copyright © 2018. Horváth Balázs. All rights reserved.
//

import SpriteKit

class ButtonView: UIView {
    // MARK: Properties
    let btnLoadNextStage = UIButton.makeLoadNext()
    let btnReloadStage = UIButton.makeReload()
    let btnReplayGame = UIButton.makeReplayGame()

    var buttons: [UIButton] {
        return [btnLoadNextStage, btnReloadStage, btnReplayGame]
    }

    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Button configuration
extension ButtonView {
    func alignCenter(in view: SKView) {
        buttons.forEach { $0.alignCenter(in: view) }
    }

    func setActions(for gameVC: GameViewController) {
        btnLoadNextStage.addTarget(gameVC, action: #selector(gameVC.loadNextStage), for: .touchUpInside)
        btnReloadStage.addTarget(gameVC, action: #selector(gameVC.reloadStage), for: .touchUpInside)
        btnReplayGame.addTarget(gameVC, action: #selector(gameVC.replayGame), for: .touchUpInside)
    }
}
