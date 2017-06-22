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

    var lblLifeCounter: SKLabelNode?
    var ground: SKSpriteNode?
    var cloud: SKSpriteNode?

    var cat: Cat?
    var canMove = false
    var moveLeft = false

    static var screenCenter = CGFloat()
    static var screenLeftEdge = CGFloat()
    static var screenRightEdge = CGFloat()

    var rainDropRate: TimeInterval = 1
    var timeSinceRainDrop: TimeInterval = 0
    var lastTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        //view.showsPhysics = true
        self.physicsWorld.contactDelegate = self
        GameScene.screenCenter = self.frame.size.width / self.frame.size.height
        GameScene.screenRightEdge = self.frame.size.width / 2 - 40
        GameScene.screenLeftEdge = -1 * (self.frame.size.width / 2 - 40)

        Audio.setBackgroundMusic(for: self)
        Audio.preloadSounds()

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

        lblLifeCounter = self.childNode(withName: "lblLifeCounter") as? SKLabelNode
        updateLifeCounter()
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if cat?.isAlive() == true {
            manageCatMovements()

            // Identify cat texture changes
            if let catVerticalVelocity = cat?.physicsBody?.velocity.dy {
                if catVerticalVelocity > 100 {
                    if moveLeft {
                        cat?.texture = SKTexture(imageNamed: "Pusheen-jump-left")
                    } else {
                        cat?.texture = SKTexture(imageNamed: "Pusheen-jump-right")
                    }
                } else if moveLeft {
                    cat?.texture = SKTexture(imageNamed: "Pusheen-left-stand")
                } else {
                    cat?.texture = SKTexture(imageNamed: "Pusheen-right-stand")
                }
            }

        }
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
        other.removeFromParent()

        if cat?.isAlive() == true {
            cat?.takeDamage()

            if cat?.isAlive() == false {
                gameOver()
            } else {
                updateLifeCounter()
            }
        }
    }

    func updateLifeCounter() {
        if let currentLifes = cat?.lifes {
            lblLifeCounter?.text = "Lifes: \(currentLifes)"
        }
    }

    func gameOver() {
        lblLifeCounter?.text = "Game Over!"
        self.run(SKAction.playSoundFileNamed("gameover.m4a", waitForCompletion: false))
        cat?.die()
    }

    func groundDidCollide(with other: SKNode) {
        let otherCategory = other.physicsBody?.categoryBitMask
        if otherCategory == PhysicsCategory.rainDrop.rawValue {
            other.removeFromParent()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)

            if (cat?.contains(location))! {
                if cat?.isAlive() == true {
                    cat?.jumpUp()
                }
            } else if location.x < GameScene.screenCenter {
                moveLeft = true
            } else {
                moveLeft = false
            }
        }
        canMove = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        canMove = false
    }

    func manageCatMovements() {
        // canMove is true when touchesBegan
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
        droppingPoint.x += CGFloat(Util.generateRandomNumber(range: -1*cloudRadius...cloudRadius))

        raindrop?.position = droppingPoint
        raindrop?.move(toParent: self)
    }

}
