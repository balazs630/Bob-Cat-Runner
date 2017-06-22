//
//  Cat.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 16..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Cat: SKSpriteNode {

    var lifes: Int = 5

    init(lifes: Int) {
        self.lifes = lifes
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: 28, height: 24))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func move(left: Bool) {
        if left {
            if position.x > GameScene.screenLeftEdge {
                position.x -= 5
            }
        } else {
            if position.x < GameScene.screenRightEdge {
                position.x += 5
            }
        }
    }

    func jumpUp() {
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 650))
    }

    func takeDamage() {
        lifes -= 1
        run(SKAction.playSoundFileNamed("raindrop_explosion.m4a", waitForCompletion: false))
    }

    func isAlive() -> Bool {
        if lifes > 0 {
            return true
        } else {
            return false
        }
    }

    func die() {
        run(SKAction.rotate(byAngle: (.pi), duration: 0.5))
        texture = SKTexture(imageNamed: "pusheen-dead")
    }

}
