//
//  UIButtonExtensions.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2018. 05. 06..
//  Copyright © 2018. Horváth Balázs. All rights reserved.
//

import SpriteKit

extension UIButton {
    func centerButton(in view: SKView?) {
        self.frame.origin.x = (view?.center.x)! - self.frame.size.width / 2
        self.frame.origin.y = (view?.center.y)! - self.frame.size.height / 2
    }

    func setButtonAttributes(title: String) {
        self.layer.cornerRadius = 5
        self.backgroundColor = .black
        self.setTitle(title, for: .normal)
    }
}
