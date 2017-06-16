//
//  Cat.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 16..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Cat: SKSpriteNode {

    var screenLeftEdge = CGFloat(-290)
    var screenRightEdge = CGFloat(290)

    init() {
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: 28, height: 24))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func move(left: Bool) {
        if left {
            if self.position.x > screenLeftEdge {
                self.position.x -= 5
                self.texture = SKTexture(imageNamed: "Pusheen-left-stand")
            }
        } else {
            if self.position.x < screenRightEdge {
                self.position.x += 5
                self.texture = SKTexture(imageNamed: "Pusheen-right-stand")
            }
        }
    }
}
