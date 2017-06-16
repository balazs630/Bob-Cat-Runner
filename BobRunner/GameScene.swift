//
//  GameScene.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 05. 22..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit
import GameplayKit

enum PhysicsCategory: UInt32 {
    case noCategory = 1
    case ground = 2
    case cat = 4
    case cloud = 8
    case rainDrop = 16
    case umbrella = 32
    case otherItem = 64
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var ground: SKSpriteNode?
    var cloud: SKSpriteNode?
    var cat: Cat?

    var lifes: Int = 5
    var lblLifeCounter: SKLabelNode?

    var canMove = false
    var moveLeft = false

    var screenCenter = CGFloat()

    var rainDropRate: TimeInterval = 1
    var timeSinceRainDrop: TimeInterval = 0
    var lastTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        //view.showsPhysics = true
        self.physicsWorld.contactDelegate = self
        screenCenter = self.frame.size.width / self.frame.size.height

        Audio.setBackgroundMusic(for: self)
        Audio.preloadSounds()

        lblLifeCounter = self.childNode(withName: "lblLifeCounter") as? SKLabelNode
        lblLifeCounter?.text = "Lifes: \(lifes)"

        ground = self.childNode(withName: "ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
        ground?.physicsBody?.collisionBitMask = PhysicsCategory.noCategory.rawValue
        ground?.physicsBody?.contactTestBitMask = PhysicsCategory.rainDrop.rawValue

        cloud = self.childNode(withName: "cloud") as? SKSpriteNode
        cloud?.physicsBody?.categoryBitMask = PhysicsCategory.cloud.rawValue
        cloud?.physicsBody?.collisionBitMask = PhysicsCategory.noCategory.rawValue
        cloud?.physicsBody?.contactTestBitMask = PhysicsCategory.cat.rawValue

        cat = childNode(withName: "cat") as? Cat
        cat?.physicsBody?.categoryBitMask = PhysicsCategory.cat.rawValue
        cat?.physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
        cat?.physicsBody?.contactTestBitMask = PhysicsCategory.cloud.rawValue | PhysicsCategory.rainDrop.rawValue
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveCat()
        checkRainDrop(currentTime - lastTime)
        lastTime = currentTime
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let cA: UInt32 = contact.bodyA.categoryBitMask
        let cB: UInt32 = contact.bodyB.categoryBitMask
        let otherNode: SKNode

        if cA == PhysicsCategory.cat.rawValue || cB == PhysicsCategory.cat.rawValue {
            otherNode = (cA == PhysicsCategory.cat.rawValue) ? contact.bodyB.node! : contact.bodyA.node!
            catDidCollide(with: otherNode)
        } else if cA == PhysicsCategory.ground.rawValue || cB == PhysicsCategory.ground.rawValue {
            otherNode = (cA == PhysicsCategory.ground.rawValue) ? contact.bodyB.node! : contact.bodyA.node!
            groundDidCollide(with: otherNode)
        }
    }

    func catDidCollide(with other: SKNode) {
        let otherCategory = other.physicsBody?.categoryBitMask
        if otherCategory == PhysicsCategory.umbrella.rawValue {
            other.removeFromParent()
        } else if otherCategory == PhysicsCategory.rainDrop.rawValue {
            catWashed(by: other)
        }
    }

    func catWashed(by other: SKNode) {
        let rainDropExplosion: SKEmitterNode = SKEmitterNode(fileNamed: "RainDropExplosion")!
        rainDropExplosion.position = other.position
        self.addChild(rainDropExplosion)
        self.run(SKAction.playSoundFileNamed("raindrop_explosion.m4a", waitForCompletion: false))
        other.removeFromParent()

        if lifes > 0 {
            lifes -= 1

            if lifes == 0 {
                gameOver()
            } else {
                lblLifeCounter?.text = "Lifes: \(lifes)"
            }
        }
    }

    func gameOver() {
        lblLifeCounter?.text = "Game Over!"
        self.run(SKAction.playSoundFileNamed("gameover.m4a", waitForCompletion: false))
        cat?.run(SKAction.rotate(byAngle: (.pi), duration: 0.5))

    }

    func groundDidCollide(with other: SKNode) {
        let otherCategory = other.physicsBody?.categoryBitMask
        if otherCategory == PhysicsCategory.rainDrop.rawValue {
            other.removeFromParent()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            if location.x > screenCenter {
                moveLeft = false
            } else {
                moveLeft = true
            }
        }
        canMove = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        canMove = false
    }

    func moveCat() {
        if canMove {
            cat?.move(left: moveLeft)
        }
    }

    func checkRainDrop(_ frameRate: TimeInterval) {
        // Add time to timer
        timeSinceRainDrop += frameRate

        // Return if it hasn't been enogh time to drop raindrop
        if timeSinceRainDrop < rainDropRate {
            return
        } else {
            dropRainDrop()
            timeSinceRainDrop = 0
        }
    }

    func dropRainDrop() {
        let scene: SKScene = SKScene(fileNamed: "Raindrop")!
        let raindrop = scene.childNode(withName: "raindrop")
        raindrop?.physicsBody?.categoryBitMask = PhysicsCategory.rainDrop.rawValue
        raindrop?.physicsBody?.collisionBitMask = PhysicsCategory.noCategory.rawValue
        raindrop?.physicsBody?.contactTestBitMask = PhysicsCategory.cat.rawValue | PhysicsCategory.ground.rawValue

        let cloudRadius: Int = Int(cloud!.size.width/2) - 20

        var droppingPoint: CGPoint = cloud!.position
        // Drop raindrops randomly according to cloud width
        droppingPoint.x += CGFloat(generateRandomNumber(range: -1*cloudRadius...cloudRadius))

        raindrop?.position = droppingPoint
        raindrop?.move(toParent: self)
    }

    func generateRandomNumber(range: ClosedRange<Int>) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }
}
