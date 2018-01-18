//
//  GameScene.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 05. 22..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

enum PhysicsCategory: UInt32 {
    case noCategory = 0
    case ground = 1
    case cat = 2
    case cloud = 4
    case raindrop = 8
    case umbrella = 16
    case house = 32
    case dangerZone = 64
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var cam = SKCameraNode()
    let cameraOffset = CGFloat(150)
    var hud = SKReferenceNode()
    let isIPhoneX = GameViewController().isIphoneX
    
    var stage = Stage()
    var graphicsLayers: [SKNode] = []
    
    var cat = Cat(lifes: 5)
    var touchActive = false
    var canMove = true
    var isMoveLeft = false
    var isJumpingWhileMoving = false
    let standardCatTextureScale = CGFloat(1.0)
    let umbrellaCatTextureScale = CGFloat(1.8)
    
    let btnLoadNextStage = UIButton(frame: CGRect(x: 100, y: 100, width: 120, height: 50))
    let btnReloadStage = UIButton(frame: CGRect(x: 100, y: 100, width: 120, height: 50))
    let btnReplayWholeGame = UIButton(frame: CGRect(x: 100, y: 100, width: 240, height: 50))
    
    var lblLifeCounter: SKLabelNode?
    var lblUmbrellaCountDown: SKLabelNode?
    
    var umbrellaTimer = Timer()
    let countDownInitialSeconds = 2
    var countDownSeconds = Int()
    
    override func didMove(to view: SKView) {
        // Called immediately after a scene is presented by a view
        self.physicsWorld.contactDelegate = self
        Audio.setBackgroundMusic(for: self)
        
        if let camNode = self.childNode(withName: Node.camera) as? SKCameraNode {
            cam = camNode
        }
        
        if let catNode = self.childNode(withName: Node.cat) as? Cat {
            cat = catNode
        }
        
        for cloudName in stage.clouds {
            self.childNode(withName: cloudName)
        }
        
        if let backgroundNode = self.childNode(withName: Node.Layer.background),
            let midgroundNode = self.childNode(withName: Node.Layer.midground),
            let foregroundNode = self.childNode(withName: Node.Layer.foreground) {
                graphicsLayers.append(backgroundNode)
                graphicsLayers.append(midgroundNode)
                graphicsLayers.append(foregroundNode)
        }
        
        if isIPhoneX {
            hud = SKReferenceNode(fileNamed: Scene.hudIphoneX)
        } else {
            hud = SKReferenceNode(fileNamed: Scene.hudStandard)
            if GameViewController().isIPad {
                let iPadHudPos = CGPoint(x: view.frame.width / 2 - 260, y: view.frame.height / 2 - 200)
                hud.position = iPadHudPos
            }
        }
        
        cam.addChild(hud)
        
        if let lifeCounter = hud.childNode(withName: Node.Lbl.lifeCounter) as? SKLabelNode,
            let umbrellaCountDown = hud.childNode(withName: Node.Lbl.umbrellaCountDown) as? SKLabelNode {
                lblLifeCounter = lifeCounter
                updateLifeCounter()
            
                lblUmbrellaCountDown = umbrellaCountDown
                lblUmbrellaCountDown?.isHidden = true
                lblUmbrellaCountDown?.text = String(countDownInitialSeconds)
                countDownSeconds = countDownInitialSeconds
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Performs any scene-specific updates that need to occur before scene actions and physics simulations are evaluated
        
        // Drop raindrops from the clouds
        Raindrop.checkRaindrop(timeBetweenFrames: currentTime - Raindrop.lastTime, stage: stage, in: self)
        Raindrop.lastTime = currentTime
    }
    
    override func didSimulatePhysics() {
        // Performs any scene-specific updates that need to occur after physics simulations are performed
        
        // Identify cat texture changes
        if cat.isAlive() {
            manageCatMovements()
            
            cat.xScale = standardCatTextureScale
            cat.yScale = standardCatTextureScale
            
            if let catVerticalVelocity = cat.physicsBody?.velocity.dy {
                
                switch (isMoveLeft, cat.isProtected, Float(catVerticalVelocity), canMove) {
                case (true, false, 100..<1000, true):
                    cat.texture = SKTexture(assetIdentifier: .catJumpLeft)
                case (false, false, 100..<1000, true):
                    cat.texture = SKTexture(assetIdentifier: .catJumpRight)
                case (true, true, _, true):
                    cat.texture = SKTexture(assetIdentifier: .catUmbrellaLeft)
                    cat.yScale = umbrellaCatTextureScale
                case (false, true, _, true):
                    cat.texture = SKTexture(assetIdentifier: .catUmbrellaRight)
                    cat.yScale = umbrellaCatTextureScale
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
        }
        
        // Move camere ahead of the player
        cam.position.x = cat.position.x + cameraOffset
    
        // Do the parallax background effect
        for layer in graphicsLayers {
            if let movementMultiplier = layer.userData?.value(forKey: UserData.Key.movementMultiplier) as? CGFloat {
                let adjustedPosition = cat.position.x * (1 - movementMultiplier)
                layer.position.x = adjustedPosition
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Called when two bodies first contact each other
        let cA = contact.bodyA.categoryBitMask
        let cB = contact.bodyB.categoryBitMask
        let otherNode: SKNode
        
        if cA == PhysicsCategory.cat.rawValue || cB == PhysicsCategory.cat.rawValue {
            // At least one of the objects is the cat
            otherNode = (cA == PhysicsCategory.cat.rawValue) ? contact.bodyB.node! : contact.bodyA.node!
            catDidCollide(with: otherNode)
            
        } else if cA == PhysicsCategory.ground.rawValue || cB == PhysicsCategory.ground.rawValue {
            // At least one of the objects is the ground
            otherNode = (cA == PhysicsCategory.ground.rawValue) ? contact.bodyB.node! : contact.bodyA.node!
            if otherNode.physicsBody?.categoryBitMask == PhysicsCategory.raindrop.rawValue {
                otherNode.removeFromParent()
            }
        }
    }
    
    func catDidCollide(with other: SKNode) {
        // Type of objects the cat can collide with
        if let otherCategory = other.physicsBody?.categoryBitMask {
            switch (otherCategory) {
            case PhysicsCategory.raindrop.rawValue:
                Raindrop.explode(raindrop: other, in: self)
                if cat.isProtected {
                    run(cat.raindropHitUmbrellaSound)
                } else {
                    catHitByRaindrop()
                }
                
            case PhysicsCategory.umbrella.rawValue:
                cat.collect(umbrella: other)
                
                // Start countdown (the cat can own the umbrella only for a few seconds)
                lblUmbrellaCountDown?.isHidden = false
                umbrellaTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateUmbrellaHoldingTimer), userInfo: nil, repeats: true)
              
            case PhysicsCategory.dangerZone.rawValue:
                cat.lifes = 0
                gameOver(type: GameOverType.drown)
                
            case PhysicsCategory.house.rawValue:
                completeActualStage()
                
            default:
                print("Unhandled collision occured between the cat and \(String(describing: other.physicsBody?.node))")
                break
            }
        }
    }
    
    func catHitByRaindrop() {
        if cat.isAlive() {
            cat.takeDamage()
            updateLifeCounter()
            
            // Check the lifes after the damage
            if !cat.isAlive() {
                gameOver()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Tells this object that one or more new touches occurred in a view or window
        
        if canMove {
            touchActive = true
            for t in touches {
                let location = t.location(in: self)
                
                if (self.atPoint(location).name == Node.Button.reload) {
                    reloadStage()
                }
                
                if cat.contains(location) {
                    cat.jumpUp()
                    isJumpingWhileMoving = true
                } else if location.x < (cam.position.x - cameraOffset) {
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
    
    func manageCatMovements() {
        if touchActive {
            cat.move(left: isMoveLeft)
        }
    }
    
    func updateLifeCounter() {
        lblLifeCounter?.text = String(cat.lifes)
    }
    
    func gameOver(type: String = "") {
        // Lost all its life
        if type == GameOverType.drown {
            cat.drown()
        } else {
            cat.die()
        }
    
        canMove = false
        presentReloadStageButton(withTitle: "Retry stage!")
    }
    
    func completeActualStage() {
        // Called if the cat can get back to the house
        canMove = false
        touchActive = false
        cat.celebrate()
        
        if stage.current == Stage.maxCount {
            // Each stage is completed
            presentReplayWholeGameButton(withTitle: "Replay game from Stage 1!")
        } else {
            // Go to next stage
            presentLoadNextStageButton(withTitle: "Start Stage \(stage.current + 1)!")
        }
    }
    
    func presentLoadNextStageButton(withTitle text: String) {
        // Center button on the screen
        btnLoadNextStage.frame.origin.x = (self.view?.center.x)! - btnLoadNextStage.frame.size.width / 2
        btnLoadNextStage.frame.origin.y = (self.view?.center.y)! - btnLoadNextStage.frame.size.height / 2
        
        btnLoadNextStage.layer.cornerRadius = 5
        btnLoadNextStage.backgroundColor = .black
        btnLoadNextStage.setTitle(text, for: .normal)
        btnLoadNextStage.addTarget(self, action: #selector(loadNextStage), for: .touchUpInside)
        self.view?.addSubview(btnLoadNextStage)
    }
    
    func presentReloadStageButton(withTitle text: String) {
        // Center button on the screen
        btnReloadStage.frame.origin.x = (self.view?.center.x)! - btnReloadStage.frame.size.width / 2
        btnReloadStage.frame.origin.y = (self.view?.center.y)! - btnReloadStage.frame.size.height / 2
        
        btnReloadStage.layer.cornerRadius = 5
        btnReloadStage.backgroundColor = .black
        btnReloadStage.setTitle(text, for: .normal)
        btnReloadStage.addTarget(self, action: #selector(reloadStage), for: .touchUpInside)
        self.view?.addSubview(btnReloadStage)
    }
    
    func presentReplayWholeGameButton(withTitle text: String) {
        // Center button on the screen
        btnReplayWholeGame.frame.origin.x = (self.view?.center.x)! - btnReplayWholeGame.frame.size.width / 2
        btnReplayWholeGame.frame.origin.y = (self.view?.center.y)! - btnReplayWholeGame.frame.size.height / 2
        
        btnReplayWholeGame.layer.cornerRadius = 5
        btnReplayWholeGame.backgroundColor = .black
        btnReplayWholeGame.setTitle(text, for: .normal)
        btnReplayWholeGame.addTarget(self, action: #selector(replayWholeGame), for: .touchUpInside)
        self.view?.addSubview(btnReplayWholeGame)
    }
    
    @objc func updateUmbrellaHoldingTimer() {
        if countDownSeconds > 0 {
            countDownSeconds -= 1
            lblUmbrellaCountDown?.text = String(countDownSeconds)
        } else {
            // Time is over
            cat.isProtected = false
            lblUmbrellaCountDown?.isHidden = true
            countDownSeconds = countDownInitialSeconds
            umbrellaTimer.invalidate()
        }
    }
    
    @objc func loadNextStage() {
        // Load next stage if current stage is completed
        stage.current += 1
        presentScene()
        btnLoadNextStage.removeFromSuperview()
    }
    
    @objc func reloadStage() {
        // Reload actual stage on gameover
        presentScene()
        btnReloadStage.removeFromSuperview()
    }
    
    @objc func replayWholeGame() {
        stage.current = 1
        presentScene()
        btnReplayWholeGame.removeFromSuperview()
    }
    
    private func presentScene() {
        if let scene = SKScene(fileNamed: stage.name) {
            if isIPhoneX {
                scene.scaleMode = .resizeFill
            } else {
                scene.scaleMode = .aspectFill
            }
            
            self.view?.presentScene(scene)
        }
    }
    
}
