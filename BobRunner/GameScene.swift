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
    case rainDrop = 8
    case umbrella = 16
    case house = 32
    case dangerZone = 64
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var cam = SKCameraNode()
    let cameraOffset = CGFloat(150)
    
    var stage = Stage()
    var graphicsLayers: [SKNode] = []
    
    var cat = Cat(lifes: 5)
    var touchActive = false
    var canMove = true
    var moveLeft = false
    let standardCatTextureScale = CGFloat(1.0)
    let umbrellaCatTextureScale = CGFloat(1.8)
    
    let btnLoadNextStage = UIButton(frame: CGRect(x: 100, y: 100, width: 120, height: 50))
    let btnReloadStage = UIButton(frame: CGRect(x: 100, y: 100, width: 120, height: 50))
    let btnReplayWholeGame = UIButton(frame: CGRect(x: 100, y: 100, width: 240, height: 50))
    
    var lblLifeCounter: SKLabelNode?
    var lblUmbrellaCountDown: SKLabelNode?
    
    var umbrellaTimer = Timer()
    let countDownInitialSeconds = 3
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
        
        for cloudName in stage.currentClouds {
            self.childNode(withName: cloudName)
        }
        
        if let backgroundNode = self.childNode(withName: Node.Layer.background),
            let midgroundNode = self.childNode(withName: Node.Layer.midground),
            let foregroundNode = self.childNode(withName: Node.Layer.foreground) {
                graphicsLayers.append(backgroundNode)
                graphicsLayers.append(midgroundNode)
                graphicsLayers.append(foregroundNode)
        }
        
        if let lifeCounter = cam.childNode(withName: Node.Lbl.lifeCounter) as? SKLabelNode,
            let umbrellaCountDown = cam.childNode(withName: Node.Lbl.umbrellaCountDown) as? SKLabelNode {
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
        Raindrop.checkRainDrop(frameRate: currentTime - Raindrop.lastTime, rainDropRate: stage.currentRainIntensity, stage: stage, scene: self)
        Raindrop.lastTime = currentTime
    }
    
    override func didSimulatePhysics() {
        // Performs any scene-specific updates that need to occur after physics simulations are performed
        
        // Identify cat texture changes
        if cat.isAlive() == true {
            manageCatMovements()
            
            cat.xScale = standardCatTextureScale
            cat.yScale = standardCatTextureScale
            
            if let catVerticalVelocity = cat.physicsBody?.velocity.dy {
                
                switch (moveLeft, cat.isProtected, Float(catVerticalVelocity), canMove) {
                case (true, false, 100..<1000, true):
                    cat.texture = SKTexture(assetIdentifier: .CatJumpLeft)
                case (false, false, 100..<1000, true):
                    cat.texture = SKTexture(assetIdentifier: .CatJumpRight)
                case (true, true, _, true):
                    cat.texture = SKTexture(assetIdentifier: .CatUmbrellaLeft)
                    cat.yScale = umbrellaCatTextureScale
                case (false, true, _, true):
                    cat.texture = SKTexture(assetIdentifier: .CatUmbrellaRight)
                    cat.yScale = umbrellaCatTextureScale
                case (_, _, _, false):
                    cat.texture = SKTexture(assetIdentifier: .CatStandRight)
                default:
                    if moveLeft {
                        cat.texture = SKTexture(assetIdentifier: .CatStandLeft)
                    } else {
                        cat.texture = SKTexture(assetIdentifier: .CatStandRight)
                    }
                }
            }
        }
        
        // Move camere ahead of the player
        cam.position.x = cat.position.x + cameraOffset
    
        // Do the parallax background effect
        for background in self.graphicsLayers {
            let adjustedPosition = cat.position.x * (1 - (background.userData?.value(forKey: Key.movementMultiplier) as! CGFloat))
            background.position.x = adjustedPosition
        }
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
        // Type of objects the cat can collide with
        if let otherCategory = other.physicsBody?.categoryBitMask {
            switch (otherCategory) {
            case PhysicsCategory.rainDrop.rawValue:
                Raindrop.explode(raindrop: other, scene: self)
                if cat.isProtected {
                    run(cat.rainDropHitUmbrellaSound)
                } else {
                    catHitByRaindrop()
                }
                
            case PhysicsCategory.umbrella.rawValue:
                cat.collect(umbrella: other)
                
                // Start countdown (the cat can own the umbrella only for a few seconds)
                lblUmbrellaCountDown?.isHidden = false
                umbrellaTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateUmbrellaHoldingTimer), userInfo: nil, repeats: true)
                
            case PhysicsCategory.house.rawValue:
                completeActualStage()
                
            default:
                print("Unexpected collision occured in func catDidCollide!")
                break
            }
        }
    }
    
    func catHitByRaindrop() {
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
    
    func groundDidCollide(with other: SKNode) {
        let otherCategory = other.physicsBody?.categoryBitMask
        if otherCategory == PhysicsCategory.rainDrop.rawValue {
            other.removeFromParent()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Tells this object that one or more new touches occurred in a view or window
        if canMove {
            touchActive = true
            for t in touches {
                let location = t.location(in: self)
                
                if cat.contains(location) {
                    if cat.isAlive() == true {
                        cat.jumpUp()
                    }
                } else if location.x < (cam.position.x - cameraOffset) {
                    moveLeft = true
                } else {
                    moveLeft = false
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Tells the responder when one or more fingers are raised from a view or window
        touchActive = false
    }
    
    func manageCatMovements() {
        // canMove is true when touchesBegan
        if touchActive {
            cat.move(left: moveLeft)
        }
    }
    
    func updateLifeCounter() {
        lblLifeCounter?.text = String(cat.lifes)
    }
    
    func gameOver() {
        // Lost all its life
        cat.die()
        presentReloadStageButton(withTitle: "Retry stage!")
    }
    
    func completeActualStage() {
        // Called if the cat can get back to the house
        canMove = false
        touchActive = false
        cat.celebrate()
        
        if stage.actual == Stage.maxStageCount {
            // Each stage is completed
            presentReplayWholeGameButton(withTitle: "Replay game from Stage 1!")
        } else {
            // Go to next stage
            presentLoadNextStageButton(withTitle: "Start Stage \(stage.actual + 1)!")
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
        stage.actual += 1
        
        if let scene = SKScene(fileNamed: stage.actualStageName) {
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
        }
        
        btnLoadNextStage.removeFromSuperview()
    }
    
    @objc func reloadStage() {
        // Reload actual stage on gameover
        if let scene = SKScene(fileNamed: stage.actualStageName) {
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
        }
        
        btnReloadStage.removeFromSuperview()
    }
    
    @objc func replayWholeGame() {
        stage.actual = 1
        
        if let scene = SKScene(fileNamed: stage.actualStageName) {
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
        }
        
        btnReplayWholeGame.removeFromSuperview()
    }
    
}
