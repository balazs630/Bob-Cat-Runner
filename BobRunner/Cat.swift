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
            if self.position.x > GameScene.screenLeftEdge {
                self.position.x -= 5
                self.texture = SKTexture(imageNamed: "Pusheen-left-stand")
            }
        } else {
            if self.position.x < GameScene.screenRightEdge {
                self.position.x += 5
                self.texture = SKTexture(imageNamed: "Pusheen-right-stand")
            }
        }
    }

    func jumpUp() {
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
        self.texture = SKTexture(imageNamed: "Pusheen-jump-right")
    }
    
    func takeDamage() {
        self.lifes -= 1
        self.run(SKAction.playSoundFileNamed("raindrop_explosion.m4a", waitForCompletion: false))
    }

    func isAlive() -> Bool {
        if self.lifes > 0 {
            return true
        } else {
            return false
        }
    }

    func die() {
        self.run(SKAction.rotate(byAngle: (.pi), duration: 0.5))
        self.texture = SKTexture(imageNamed: "pusheen-dead")
    }

}
