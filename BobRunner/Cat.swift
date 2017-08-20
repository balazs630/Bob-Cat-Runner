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
    var isProtected = false
    var initialSize: CGSize = CGSize(width: 70, height: 45)

    let dieAction: SKAction = SKAction.rotate(byAngle: (.pi), duration: 0.5)

    let collectUmbrellaSound: SKAction = SKAction.playSoundFileNamed("collectUmbrella.m4a", waitForCompletion: false)
    let rainDropHitCatSound: SKAction = SKAction.playSoundFileNamed("raindrop_hit_cat.m4a", waitForCompletion: false)
    let rainDropHitUmbrellaSound: SKAction = SKAction.playSoundFileNamed("raindrop_hit_umbrella.m4a", waitForCompletion: false)
    let gameOverSound: SKAction = SKAction.playSoundFileNamed("gameover.m4a", waitForCompletion: false)
    let celebrateSound: SKAction = SKAction.playSoundFileNamed("crowd_celebrate.m4a", waitForCompletion: false)

    init(lifes: Int) {
        self.lifes = lifes
        self.isProtected = false
        let texture = SKTexture(imageNamed: "pusheen-stand-right")
        super.init(texture: texture, color: UIColor.clear, size: initialSize)
        zPosition = 1

        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: initialSize.width, height: initialSize.height))
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = false
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
            position.x += runSpeed
        }
    }

    func jumpUp() {
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
    }

    func takeDamage() {
        lifes -= 1
        run(rainDropHitCatSound)
    }

    func collect(umbrella: SKNode) {
        umbrella.removeFromParent()
        run(collectUmbrellaSound)
        isProtected = true
    }

    func isAlive() -> Bool {
        if lifes > 0 {
            return true
        } else {
            return false
        }
    }

    func die() {
        run(SKAction.sequence([gameOverSound, dieAction]))
        texture = SKTexture(imageNamed: "pusheen-dead")
        isProtected = false
    }

    func celebrate() {
        run(celebrateSound)

        let jumpAction: SKAction = SKAction.applyForce(CGVector(dx: 0, dy: 800), duration: TimeInterval(1.5))
        var jumpSequence = [SKAction]()

        for _ in 0...4 {
            jumpSequence.append(jumpAction)
        }

        //Jump up 5 times
        run(SKAction.sequence(jumpSequence))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
