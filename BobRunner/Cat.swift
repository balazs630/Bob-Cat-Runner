//
//  Cat.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 16..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Cat: SKSpriteNode {

    let jumpImpulse = 800
    let runSpeed = CGFloat(5)
    let catMass = CGFloat(2)

    var lifes: Int = 5
    var initialSize: CGSize = CGSize(width: 70, height: 45)

    init(lifes: Int) {
        self.lifes = lifes
        let texture = SKTexture(imageNamed: "Pusheen-right-stand")
        super.init(texture: texture, color: UIColor.clear, size: initialSize)

        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: initialSize.width, height: initialSize.height))
        physicsBody?.affectedByGravity = true
        physicsBody?.mass = catMass
        physicsBody?.categoryBitMask = PhysicsCategory.cat.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.cloud.rawValue | PhysicsCategory.rainDrop.rawValue
    }

    func move(left: Bool) {
        if left {
            if position.x > GameScene.screenLeftEdge {
                position.x -= runSpeed
            }
        } else {
            if position.x < GameScene.screenRightEdge {
                position.x += runSpeed
            }
        }
    }

    func jumpUp() {
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
