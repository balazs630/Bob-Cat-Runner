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

    var lblLifeCounter: SKLabelNode?
    var lblUmbrellaCountDown: SKLabelNode?

    var umbrellaTimer = Timer()
    var countDownSeconds = Int()

    // MARK: - Scene lifecycle
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupCommonNodes()
    }
}

// MARK: Setup nodes
extension GameScene {
    private func setupCommonNodes() {
        Audio.setBackgroundMusic(for: self)

        if let camNode = childNode(withName: Node.camera) as? SKCameraNode {
            cam = camNode
        }

        if let catNode = childNode(withName: Node.cat) as? Cat {
            cat = catNode
        }

        Stage.clouds.forEach { childNode(withName: $0) }

        if let backgroundNode = childNode(withName: Node.Layer.background),
            let midgroundNode = childNode(withName: Node.Layer.midground),
            let foregroundNode = childNode(withName: Node.Layer.foreground) {
            graphicsLayers.append(backgroundNode)
            graphicsLayers.append(midgroundNode)
            graphicsLayers.append(foregroundNode)
        }

        let hudLeft = prepareTopLeftHUD()
        let hudRight = prepareTopRightHUD()
        cam.addChilds([hudLeft, hudRight])
        updateLifeCounter()
    }

    private func prepareTopLeftHUD() -> SKNode {
        let topLeftHUDScene = SKScene(fileNamed: Scene.topLeftHUD)
        guard let topLeftHUD = topLeftHUDScene?.childNode(withName: Node.Layer.hud) else { return SKNode() }
        topLeftHUD.removeFromParent()
        topLeftHUD.position = (self.view?.topLeftCorner)!

        return topLeftHUD
    }

    private func prepareTopRightHUD() -> SKNode {
        let topRightHUDScene = SKScene(fileNamed: Scene.topRightHUD)

        if let lifeCounter = topRightHUDScene?.childNode(withName: Node.Lbl.lifeCounter) as? SKLabelNode,
            let umbrellaCountDown = topRightHUDScene?.childNode(withName: Node.Lbl.umbrellaCountDown) as? SKLabelNode {
            lblLifeCounter = lifeCounter

            lblUmbrellaCountDown = umbrellaCountDown
            lblUmbrellaCountDown?.isHidden = true
            lblUmbrellaCountDown?.text = String(Constant.countDownInitialSeconds)
            countDownSeconds = Constant.countDownInitialSeconds
        }

        guard let topRightHUD = topRightHUDScene?.childNode(withName: Node.Layer.hud) else { return SKNode() }
        topRightHUD.removeFromParent()
        topRightHUD.position = (self.view?.topRightCorner)!

        return topRightHUD
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
                cat.isProtected ? run(cat.raindropHitUmbrellaSound) : catHitByRaindrop()

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
            touches.forEach { touch in
                let location = touch.location(in: self)

                if self.atPoint(location).name == Button.ReloadStage.name {
                    reloadStage()
                }

                if cat.contains(location) {
                    cat.jumpUp()
                    isJumpingWhileMoving = true
                } else {
                    isMoveLeft = location.x < (cam.position.x - Constant.cameraOffset)
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
        graphicsLayers.forEach { layer in
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
        type == .drown ? cat.drown() : cat.die()
        canMove = false
        view?.viewWithTag(Button.ReloadStage.tag)?.isHidden = false
    }

    private func completeActualStage() {
        canMove = false
        touchActive = false
        cat.celebrate()

        if Stage.isAllCompleted() {
            view?.viewWithTag(Button.ReplayGame.tag)?.isHidden = false
        } else {
            let button = view?.viewWithTag(Button.NextStage.tag) as? UIButton
            button?.setTitle("Start Stage \(Stage.current + 1)!", for: .normal)
            button?.isHidden = false
        }
    }

    private func reloadStage() {
        view?.presentScene(SKScene(fileNamed: Stage.name))
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
