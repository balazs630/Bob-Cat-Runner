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
    case noCategory = 0
    case ground = 1
    case cat = 2
    case cloud = 4
    case rainDrop = 8
    case umbrella = 16
    case house = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let cam = SKCameraNode()
    var stage = Stage()
    var cat = Cat(lifes: 5)
    
    let initialCatPosition = CGPoint(x: -270, y: -100)
    
    let standardCatTextureScale = CGFloat(1.2)
    let umbrellaCatTextureScale = CGFloat(2.17)
    
    let btnLoadNextStage = UIButton(frame: CGRect(x: 100, y: 100, width: 120, height: 50))
    let btnReloadStage = UIButton(frame: CGRect(x: 100, y: 100, width: 120, height: 50))
    let btnReplayWholeGame = UIButton(frame: CGRect(x: 100, y: 100, width: 240, height: 50))
    
    var lblLifeCounter: SKLabelNode?
    let lifeCounterPosition = CGPoint(x: 320, y: 150)
    
    var lblUmbrellaCountDown: SKLabelNode?
    let umbrellaCountDownPosition = CGPoint(x: 320, y: 110)
    
    var umbrellaTimer = Timer()
    let countDownInitialSeconds = 3
    var countDownSeconds = Int()
    
    var touchActive = false
    var canMove = true
    var moveLeft = false
    
    static var screenLeftEdge = CGFloat()
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.camera = cam
        GameScene.screenLeftEdge = -1 * (self.frame.size.width / 2)
        
        Audio.setBackgroundMusic(for: self)
        Audio.preloadSounds()
        
        cat.position = initialCatPosition
        self.addChild(cat)
        
        for cloudName in stage.currentClouds {
            self.childNode(withName: cloudName)
        }
        
        lblLifeCounter = self.childNode(withName: "lblLifeCounter") as? SKLabelNode
        updateLifeCounter()
        
        lblUmbrellaCountDown = self.childNode(withName: "lblUmbrellaCountDown") as? SKLabelNode
        lblUmbrellaCountDown?.isHidden = true
        lblUmbrellaCountDown?.text = String(countDownInitialSeconds)
        countDownSeconds = countDownInitialSeconds
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        lblLifeCounter?.position.x = cam.position.x + lifeCounterPosition.x
        lblLifeCounter?.position.y = cam.position.y + lifeCounterPosition.y
        
        lblUmbrellaCountDown?.position.x = cam.position.x + umbrellaCountDownPosition.x
        lblUmbrellaCountDown?.position.y = cam.position.y + umbrellaCountDownPosition.y
        
        if cat.isAlive() == true {
            manageCatMovements()
            
            cat.xScale = standardCatTextureScale
            cat.yScale = standardCatTextureScale
            
            if let catVerticalVelocity = cat.physicsBody?.velocity.dy {
                
                // Identify cat texture changes
                switch (moveLeft, cat.isProtected, Float(catVerticalVelocity), canMove) {
                case (true, false, 100..<1000, true):
                    cat.texture = SKTexture(imageNamed: "pusheen-jump-left")
                case (false, false, 100..<1000, true):
                    cat.texture = SKTexture(imageNamed: "pusheen-jump-right")
                case (true, true, _, true):
                    cat.texture = SKTexture(imageNamed: "pusheen-umbrella-left")
                    cat.yScale = umbrellaCatTextureScale
                case (false, true, _, true):
                    cat.texture = SKTexture(imageNamed: "pusheen-umbrella-right")
                    cat.yScale = umbrellaCatTextureScale
                case (_, _, _, false):
                    cat.texture = SKTexture(imageNamed: "pusheen-stand-right")
                default:
                    if moveLeft {
                        cat.texture = SKTexture(imageNamed: "pusheen-stand-left")
                    } else {
                        cat.texture = SKTexture(imageNamed: "pusheen-stand-right")
                    }
                }
            }
        }
        
        // Move camere ahead of the player
        cam.position.x = cat.position.x + 150
        
        // Drop raindrops from the clouds
        Raindrop.checkRainDrop(frameRate: currentTime - Raindrop.lastTime, rainDropRate: stage.currentRainIntensity, stage: stage, scene: self)
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
        if canMove {
            touchActive = true
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
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        presentReloadStageButton(with: "Retry stage!")
    }
    
    func completeActualStage() {
        // Called if the cat can get back to the house
        canMove = false
        touchActive = false
        cat.celebrate()
        
        if stage.actual == Stage.maxStageCount {
            // Each stage is completed
            presentReplayWholeGameButton(with: "Replay game from Stage 1!")
        } else {
            // Go to next stage
            presentLoadNextStageButton(with: "Start Stage \(stage.actual + 1)!")
        }
    }
    
    func presentLoadNextStageButton(with text: String) {
        // Center button on the screen
        btnLoadNextStage.frame.origin.x = (self.view?.center.x)! - btnLoadNextStage.frame.size.width / 2
        btnLoadNextStage.frame.origin.y = (self.view?.center.y)! - btnLoadNextStage.frame.size.height / 2
        
        btnLoadNextStage.layer.cornerRadius = 5
        btnLoadNextStage.backgroundColor = .black
        btnLoadNextStage.setTitle(text, for: .normal)
        btnLoadNextStage.addTarget(self, action: #selector(loadNextStage), for: .touchUpInside)
        self.view?.addSubview(btnLoadNextStage)
    }
    
    func presentReloadStageButton(with text: String) {
        // Center button on the screen
        btnReloadStage.frame.origin.x = (self.view?.center.x)! - btnReloadStage.frame.size.width / 2
        btnReloadStage.frame.origin.y = (self.view?.center.y)! - btnReloadStage.frame.size.height / 2
        
        btnReloadStage.layer.cornerRadius = 5
        btnReloadStage.backgroundColor = .black
        btnReloadStage.setTitle(text, for: .normal)
        btnReloadStage.addTarget(self, action: #selector(reloadStage), for: .touchUpInside)
        self.view?.addSubview(btnReloadStage)
    }
    
    func presentReplayWholeGameButton(with text: String) {
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
            // If time is over
            cat.isProtected = false
            lblUmbrellaCountDown?.isHidden = true
            countDownSeconds = countDownInitialSeconds
            umbrellaTimer.invalidate()
        }
    }
    
    @objc func loadNextStage() {
        // Load next stage if current stage is completed
        stage.actual += 1
        
        if let scene = GameScene(fileNamed: "Stage\(stage.actual)") {
            self.view?.presentScene(scene)
        }
        
        btnLoadNextStage.removeFromSuperview()
    }
    
    @objc func reloadStage() {
        // Reload actual stage on gameover
        if let scene = GameScene(fileNamed: "Stage\(stage.actual)") {
            self.view?.presentScene(scene)
        }
        
        btnReloadStage.removeFromSuperview()
    }
    
    @objc func replayWholeGame() {
        stage.actual = 1
        
        if let scene = GameScene(fileNamed: "Stage\(stage.actual)") {
            self.view?.presentScene(scene)
        }
        
        btnReplayWholeGame.removeFromSuperview()
    }
    
}
