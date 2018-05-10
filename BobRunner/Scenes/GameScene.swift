//
//  GameScene.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 05. 22..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: Properties
    var cam = SKCameraNode()
    var graphicsLayers: [SKNode] = []

    var cat = Cat(lifes: 5)
    var touchActive = false
    var canMove = true
    var isMoveLeft = false
    var isJumpingWhileMoving = false

    var hud = SKReferenceNode()
    var lblLifeCounter: SKLabelNode?
    var lblUmbrellaCountDown: SKLabelNode?

    var umbrellaTimer = Timer()
    var countDownSeconds = Int()

    // MARK: - Scene lifecycle
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        Audio.setBackgroundMusic(for: self)

        initCommonStageNodes()
        initHud(on: view)

        cam.addChild(hud)
        initHudChildNodes()
        updateLifeCounter()
    }

    private func initCommonStageNodes() {
        if let camNode = self.childNode(withName: Node.camera) as? SKCameraNode {
            cam = camNode
        }

        if let catNode = self.childNode(withName: Node.cat) as? Cat {
            cat = catNode
        }

        for cloudName in Stage.clouds {
            self.childNode(withName: cloudName)
        }

        if let backgroundNode = self.childNode(withName: Node.Layer.background),
            let midgroundNode = self.childNode(withName: Node.Layer.midground),
            let foregroundNode = self.childNode(withName: Node.Layer.foreground) {
            graphicsLayers.append(backgroundNode)
            graphicsLayers.append(midgroundNode)
            graphicsLayers.append(foregroundNode)
        }
    }

    private func initHud(on view: SKView) {
        if view.isIphoneX() {
            hud = SKReferenceNode(fileNamed: Scene.hudIphoneX)
        } else {
            hud = SKReferenceNode(fileNamed: Scene.hudStandard)
            if view.isIPad() {
                let iPadHudPos = CGPoint(x: view.frame.width / 2 - 260, y: view.frame.height / 2 - 200)
                hud.position = iPadHudPos
            }
        }
    }

    private func initHudChildNodes() {
        if let lifeCounter = hud.childNode(withName: Node.Lbl.lifeCounter) as? SKLabelNode,
            let umbrellaCountDown = hud.childNode(withName: Node.Lbl.umbrellaCountDown) as? SKLabelNode {
            lblLifeCounter = lifeCounter

            lblUmbrellaCountDown = umbrellaCountDown
            lblUmbrellaCountDown?.isHidden = true
            lblUmbrellaCountDown?.text = String(Constant.countDownInitialSeconds)
            countDownSeconds = Constant.countDownInitialSeconds
        }
    }
}

// MARK: - Frame rendering cycle
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        // Drop raindrops from the clouds
        Raindrop.checkRaindrop(timeBetweenFrames: currentTime - Raindrop.lastTime, in: self)
        Raindrop.lastTime = currentTime
    }

    override func didSimulatePhysics() {
        if cat.isAlive() {
            manageCatMovements()
            adjustParallaxBackgroundLayers()
            adjustCameraPosition()
            updateCatTexture()
        }
    }
}

// MARK: - Collisions
extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        // Called when two bodies contact each other
        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask
        let otherNode: SKNode

        if bodyA == PhysicsCategory.cat.rawValue || bodyB == PhysicsCategory.cat.rawValue {
            // At least one of the objects is the cat
            otherNode = (bodyA == PhysicsCategory.cat.rawValue) ? contact.bodyB.node! : contact.bodyA.node!
            catDidCollide(with: otherNode)

        } else if bodyA == PhysicsCategory.ground.rawValue || bodyB == PhysicsCategory.ground.rawValue {
            // At least one of the objects is the ground
            otherNode = (bodyA == PhysicsCategory.ground.rawValue) ? contact.bodyB.node! : contact.bodyA.node!
            if otherNode.physicsBody?.categoryBitMask == PhysicsCategory.raindrop.rawValue {
                otherNode.removeFromParent()
            }
        }
    }

    func catDidCollide(with other: SKNode) {
        // Type of objects the cat can collide with
        if let otherCategory = other.physicsBody?.categoryBitMask {
            switch otherCategory {
            case PhysicsCategory.raindrop.rawValue:
                Raindrop.explode(raindrop: other, in: self)
                if cat.isProtected {
                    run(cat.raindropHitUmbrellaSound)
                } else {
                    catHitByRaindrop()
                }

            case PhysicsCategory.umbrella.rawValue:
                cat.collect(umbrella: other)
                lblUmbrellaCountDown?.isHidden = false
                umbrellaTimer = startTimer()

            case PhysicsCategory.dangerZone.rawValue:
                cat.lifes = 0
                gameOver(type: .drown)

            case PhysicsCategory.house.rawValue:
                completeActualStage()

            default:
                NSLog("Unhandled collision occured between the cat and \(String(describing: other.physicsBody?.node))")
            }
        }
    }
}

// MARK: - Touch events
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Tells this object that one or more new touches occurred in a view or window

        if canMove {
            touchActive = true
            for touch in touches {
                let location = touch.location(in: self)

                if self.atPoint(location).name == Button.ReloadStage.name {
                    reloadStage()
                }

                if cat.contains(location) {
                    cat.jumpUp()
                    isJumpingWhileMoving = true
                } else if location.x < (cam.position.x - Constant.cameraOffset) {
                    isMoveLeft = true
                } else {
                    isMoveLeft = false
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Tells the responder when one or more fingers are raised from a view or window
        if !isJumpingWhileMoving {
            touchActive = false
        }
        isJumpingWhileMoving = false
    }
}

// MARK: - Utility
extension GameScene {
    private func manageCatMovements() {
        if touchActive {
            cat.move(left: isMoveLeft)
        }
    }

    private func catHitByRaindrop() {
        if cat.isAlive() {
            cat.takeDamage()
            updateLifeCounter()

            if !cat.isAlive() {
                gameOver(type: .flood)
            }
        }
    }

    private func adjustParallaxBackgroundLayers() {
        for layer in graphicsLayers {
            if let movementMultiplier = layer.userData?.value(forKey: UserData.Key.movementMultiplier) as? CGFloat {
                let adjustedPosition = cat.position.x * (1 - movementMultiplier)
                layer.position.x = adjustedPosition
            }
        }
    }

    private func adjustCameraPosition() {
        // Move camere ahead of the player
        cam.position.x = cat.position.x + Constant.cameraOffset
    }

    private func updateCatTexture() {
        cat.xScale = Constant.standardCatTextureScale
        cat.yScale = Constant.standardCatTextureScale

        let catVerticalVelocity = cat.physicsBody?.velocity.dy

        // Identify cat texture changes
        switch (isMoveLeft, cat.isProtected, Float(catVerticalVelocity!), canMove) {
        case (true, false, 100..<1000, true):
            cat.texture = SKTexture(assetIdentifier: .catJumpLeft)
        case (false, false, 100..<1000, true):
            cat.texture = SKTexture(assetIdentifier: .catJumpRight)
        case (true, true, _, true):
            cat.texture = SKTexture(assetIdentifier: .catUmbrellaLeft)
            cat.yScale = Constant.umbrellaCatTextureScale
        case (false, true, _, true):
            cat.texture = SKTexture(assetIdentifier: .catUmbrellaRight)
            cat.yScale = Constant.umbrellaCatTextureScale
        case (_, _, _, false):
            cat.texture = SKTexture(assetIdentifier: .catStandRight)
        default:
            if isMoveLeft {
                cat.texture = SKTexture(assetIdentifier: .catStandLeft)
            } else {
                cat.texture = SKTexture(assetIdentifier: .catStandRight)
            }
        }
    }

    private func updateLifeCounter() {
        lblLifeCounter?.text = String(cat.lifes)
    }

    private func gameOver(type: GameOverType) {
        if type == .drown {
            cat.drown()
        } else {
            cat.die()
        }

        canMove = false
        self.view?.viewWithTag(Button.ReloadStage.tag)?.isHidden = false
    }

    private func completeActualStage() {
        canMove = false
        touchActive = false
        cat.celebrate()

        if Stage.isAllCompleted() {
            self.view?.viewWithTag(Button.ReplayGame.tag)?.isHidden = false
        } else {
            self.view?.viewWithTag(Button.NextStage.tag)?.isHidden = false
        }
    }

    private func reloadStage() {
        self.view?.presentScene(SKScene(fileNamed: Stage.name))
    }

}

// MARK: - Timer
extension GameScene {
    private func startTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(updateUmbrellaHoldingTimer),
                             userInfo: nil,
                             repeats: true)
    }

    @objc func updateUmbrellaHoldingTimer() {
        if countDownSeconds > 0 {
            countDownSeconds -= 1
            lblUmbrellaCountDown?.text = String(countDownSeconds)
        } else {
            // Time is over
            cat.isProtected = false
            lblUmbrellaCountDown?.isHidden = true
            countDownSeconds = Constant.countDownInitialSeconds
            umbrellaTimer.invalidate()
        }
    }

}
