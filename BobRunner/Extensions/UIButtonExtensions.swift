//
//  UIButtonExtensions.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2018. 05. 06..
//  Copyright © 2018. Horváth Balázs. All rights reserved.
//

import SpriteKit

extension UIButton {

    static func makeLoadNext() -> UIButton {
        let button = UIButton(frame: Button.Frame.narrow)
        button.setDefaultAttributes(title: "Start Next Stage")
        button.tag = Button.NextStage.tag

        return button
    }

    static func makeReload() -> UIButton {
        let button = UIButton(frame: Button.Frame.narrow)
        button.setDefaultAttributes(title: "Retry stage!")
        button.tag = Button.ReloadStage.tag

        return button
    }

    static func makeReplayGame() -> UIButton {
        let button = UIButton(frame: Button.Frame.wide)
        button.setDefaultAttributes(title: "Replay game from Stage 1!")
        button.tag = Button.ReplayGame.tag

        return button
    }

    func alignCenter(in view: SKView?) {
        frame.origin.x = (view?.center.x)! - frame.size.width / 2
        frame.origin.y = (view?.center.y)! - frame.size.height / 2
    }

    func setDefaultAttributes(title: String) {
        layer.cornerRadius = 5
        backgroundColor = .black
        setTitle(title, for: .normal)
        isHidden = true
    }
}
