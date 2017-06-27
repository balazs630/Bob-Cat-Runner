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

    let cam = SKCameraNode()
    var lblLifeCounter: SKLabelNode?

    let cat = Cat(lifes: 5)
    let cloud = Cloud()
    let umbrella = Umbrella()
    var ground: SKSpriteNode?

    let initialCatPosition = CGPoint(x: -270, y: -100)
    let standardCatTextureScale = CGFloat(1.2)
    let tallCatTextureScale = CGFloat(2.17)

    let initialCloudPosition = CGPoint(x: -200, y: 65)
    let initialUmbrellaPosition = CGPoint(x: 300, y: -100)

    var canMove = false
    var moveLeft = false

    static var screenLeftEdge = CGFloat()
    static var screenRightEdge = CGFloat()

    override func didMove(to view: SKView) {
        //view.showsPhysics = true
        self.physicsWorld.contactDelegate = self
        self.camera = cam
        GameScene.screenRightEdge = self.frame.size.width / 2 - 40
        GameScene.screenLeftEdge = -1 * (self.frame.size.width / 2 - 40)

        Audio.setBackgroundMusic(for: self)
        Audio.preloadSounds()

        cat.position = initialCatPosition
        self.addChild(cat)

        cloud.position = initialCloudPosition
        self.addChild(cloud)

        umbrella.position = initialUmbrellaPosition
        self.addChild(umbrella)

        ground = self.childNode(withName: "ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
        ground?.physicsBody?.collisionBitMask = PhysicsCategory.noCategory.rawValue
        ground?.physicsBody?.contactTestBitMask = PhysicsCategory.rainDrop.rawValue
        
        lblLifeCounter = self.childNode(withName: "lblLifeCounter") as? SKLabelNode
        updateLifeCounter()
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        lblLifeCounter?.position.x = cam.position.x + 250
        lblLifeCounter?.position.y = cam.position.y + 150

        if cat.isAlive() == true {
            manageCatMovements()

            cat.xScale = standardCatTextureScale
            cat.yScale = standardCatTextureScale

            if let catVerticalVelocity = cat.physicsBody?.velocity.dy {

                // Identify cat texture changes
                switch (moveLeft, cat.isProtected, Float(catVerticalVelocity)) {
                case (true, false, 100..<1000):
                    cat.texture = SKTexture(imageNamed: "Pusheen-jump-left")
                case (false, false, 100..<1000):
                    cat.texture = SKTexture(imageNamed: "Pusheen-jump-right")
                case (true, true, _):
                    cat.texture = SKTexture(imageNamed: "pusheen-umbrella-left")
                    cat.yScale = tallCatTextureScale
                case (false, true, _):
                    cat.texture = SKTexture(imageNamed: "pusheen-umbrella-right")
                    cat.yScale = tallCatTextureScale
                default:
                    if moveLeft {
                        cat.texture = SKTexture(imageNamed: "Pusheen-left-stand")
                    } else {
                        cat.texture = SKTexture(imageNamed: "Pusheen-right-stand")
                    }
                }
            }
        }

        // Move camere ahead of the player
        cam.position.x = cat.position.x + 150

        Raindrop.checkRainDrop(frameRate: currentTime - Raindrop.lastTime, cloud: cloud, scene: self)
        Raindrop.lastTime = currentTime
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
            cat.collect(umbrella: other)
        } else if otherCategory == PhysicsCategory.rainDrop.rawValue {
            Raindrop.explode(raindrop: other, scene: self)
            if cat.isProtected {
                run(cat.rainDropHitUmbrellaSound)
            } else {
                catWashed(by: other)
            }
        }
    }

    func catWashed(by other: SKNode) {
        if cat.isAlive() == true {
            cat.takeDamage()

            // Check if it's still alive after the damage
            if cat.isAlive() == true {
                updateLifeCounter()
            } else {
                gameOver()
            }
        }
    }

    func updateLifeCounter() {
        lblLifeCounter?.text = "Lifes: \(cat.lifes)"
    }

    func gameOver() {
        lblLifeCounter?.text = "Game Over!"
        cat.die()

        let newGameButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        newGameButton.backgroundColor = .black
        newGameButton.setTitle("New Game", for: .normal)
        newGameButton.addTarget(self, action: #selector(startNewGame), for: .touchUpInside)
        self.view?.addSubview(newGameButton)
    }

    func startNewGame() {
        let scene = GameScene(size: self.size)
        let animation = SKTransition.crossFade(withDuration: 0.5)
        self.view?.presentScene(scene, transition: animation)
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
            

            if cat.contains(location) {
                if cat.isAlive() == true {
                    cat.jumpUp()
                }
            } else if location.x < cam.position.x {
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
            cat.move(left: moveLeft)
        }
    }

}
