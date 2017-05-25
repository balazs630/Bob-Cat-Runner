//
//  GameScene.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 05. 22..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var ground: SKSpriteNode?
    var cloud: SKSpriteNode?
    var cat: SKSpriteNode?

    var lifes: Int = 5
    var lblLifeCounter: SKLabelNode?

    var rainDropRate: TimeInterval = 1
    var timeSinceRainDrop: TimeInterval = 0
    var lastTime: TimeInterval = 0

    // Collision masks
    let noCategory: UInt32 = 0x00
    let rainDropCategory: UInt32 = 0x01
    let catCategory: UInt32 = 0x02
    let cloudCategory: UInt32 = 0x03
    let umbrellaCategory: UInt32 = 0x04
    let groundCategory: UInt32 = 0x05

    override func didMove(to view: SKView) {
        view.showsPhysics = true
        self.physicsWorld.contactDelegate = self

        lblLifeCounter = self.childNode(withName: "lblLifeCounter") as? SKLabelNode

        ground = self.childNode(withName: "ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = groundCategory
        ground?.physicsBody?.collisionBitMask = noCategory
        ground?.physicsBody?.collisionBitMask = rainDropCategory

        cloud = self.childNode(withName: "cloud") as? SKSpriteNode
        cloud?.physicsBody?.categoryBitMask = cloudCategory
        cloud?.physicsBody?.collisionBitMask = noCategory
        cloud?.physicsBody?.contactTestBitMask = catCategory

        cat = self.childNode(withName: "cat") as? SKSpriteNode
        cat?.physicsBody?.categoryBitMask = catCategory
        cat?.physicsBody?.collisionBitMask = groundCategory
        cat?.physicsBody?.contactTestBitMask = cloudCategory | rainDropCategory
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let cA: UInt32 = contact.bodyA.categoryBitMask
        let cB: UInt32 = contact.bodyB.categoryBitMask
        let otherNode: SKNode

        if cA == catCategory || cB == catCategory {
            otherNode = (cA == catCategory) ? contact.bodyB.node! : contact.bodyA.node!
            catDidCollide(with: otherNode)
        } else if cA == groundCategory || cB == groundCategory {
            otherNode = (cA == groundCategory) ? contact.bodyB.node! : contact.bodyA.node!
            groundDidCollide(with: otherNode)
        }
    }

    func catDidCollide(with other: SKNode) {
        let otherCategory = other.physicsBody?.categoryBitMask
        if otherCategory == umbrellaCategory {
            other.removeFromParent()
        } else if otherCategory == rainDropCategory {
            let rainDropExplosion: SKEmitterNode = SKEmitterNode(fileNamed: "RainDropExplosion")!
            rainDropExplosion.position = other.position
            self.addChild(rainDropExplosion)

            lifes -= 1
            lblLifeCounter?.text = "Lifes: \(lifes)"
            other.removeFromParent()
            if (lifes == 0) {
                lblLifeCounter?.text = "Game Over!"
                cat?.removeFromParent()
            }

        }
    }

    func groundDidCollide(with other: SKNode) {
        let otherCategory = other.physicsBody?.categoryBitMask
        if otherCategory == rainDropCategory {
            other.removeFromParent()
        }
    }

    func touchDown(atPoint pos: CGPoint) {

    }

    func touchMoved(toPoint pos: CGPoint) {

    }

    func touchUp(atPoint pos: CGPoint) {

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        checkRainDrop(currentTime - lastTime)
        lastTime = currentTime
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
        raindrop?.physicsBody?.categoryBitMask = rainDropCategory
        raindrop?.physicsBody?.collisionBitMask = noCategory
        raindrop?.physicsBody?.contactTestBitMask = catCategory | groundCategory

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
