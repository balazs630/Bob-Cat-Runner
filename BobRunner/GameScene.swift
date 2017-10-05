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
    case house = 64
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let cam = SKCameraNode()
    var lblLifeCounter: SKLabelNode?
    let lifeCounterPosition = CGPoint(x: 320, y: 150)
    let loadGameButton = UIButton(frame: CGRect(x: 100, y: 100, width: 120, height: 50))
    let replayGameButton = UIButton(frame: CGRect(x: 100, y: 100, width: 240, height: 50))
    
    var defaults: UserDefaults = UserDefaults.standard
    var actualStage: Int {
        return defaults.integer(forKey: "actualStage")
    }
    let maxStageCount = 2
    
    let cat = Cat(lifes: 5)
    let cloud = Cloud()
    let umbrella = Umbrella()
    
    let initialCatPosition = CGPoint(x: -270, y: -100)
    let initialCloudPosition = CGPoint(x: -200, y: 65)
    let initialUmbrellaPosition = CGPoint(x: 300, y: -100)
    
    let standardCatTextureScale = CGFloat(1.2)
    let umbrellaCatTextureScale = CGFloat(2.17)
    
    var umbrellaTimer = Timer()
    var lblUmbrellaCountDown: SKLabelNode?
    let umbrellaCountDownPosition = CGPoint(x: 320, y: 110)
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
        
        cloud.position = initialCloudPosition
        self.addChild(cloud)
        
        umbrella.position = initialUmbrellaPosition
        self.addChild(umbrella)
        
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
        lblLifeCounter?.text = "Lifes: \(cat.lifes)"
    }
    
    func gameOver() {
        // Lost all its life
        lblLifeCounter?.text = "Game Over!"
        cat.die()
        presentLoadGameButton(with: "Retry stage!")
    }
    
    func completeActualStage() {
        // Called if the cat can get back to the house
        canMove = false
        touchActive = false
        cat.celebrate()
        
        if actualStage == maxStageCount {
            win()
        } else {
            goToNextStage()
        }
    }
    
    func goToNextStage() {
        changeActualStage(to: actualStage + 1)
        presentLoadGameButton(with: "Start Stage \(actualStage)!")
    }
    
    func win() {
        // Each stage is completed
        changeActualStage(to: 1)
        lblLifeCounter?.text = "Congrats, you won! :)"
        presentReplayWholeGameButton(with: "Replay game from Stage 1!")
    }
    
    func changeActualStage(to stage: Int) {
        defaults.set(stage, forKey: "actualStage")
        defaults.synchronize()
    }
    
    func presentLoadGameButton(with text: String) {
        // Center button on the screen
        loadGameButton.frame.origin.x = (self.view?.center.x)! - loadGameButton.frame.size.width / 2
        loadGameButton.frame.origin.y = (self.view?.center.y)! - loadGameButton.frame.size.height / 2
        
        loadGameButton.layer.cornerRadius = 5
        loadGameButton.backgroundColor = .black
        loadGameButton.setTitle(text, for: .normal)
        loadGameButton.addTarget(self, action: #selector(loadGameStage), for: .touchUpInside)
        self.view?.addSubview(loadGameButton)
    }
    
    func presentReplayWholeGameButton(with text: String) {
        // Center button on the screen
        replayGameButton.frame.origin.x = (self.view?.center.x)! - replayGameButton.frame.size.width / 2
        replayGameButton.frame.origin.y = (self.view?.center.y)! - replayGameButton.frame.size.height / 2
        
        replayGameButton.layer.cornerRadius = 5
        replayGameButton.backgroundColor = .black
        replayGameButton.setTitle(text, for: .normal)
        replayGameButton.addTarget(self, action: #selector(loadGameStage), for: .touchUpInside)
        self.view?.addSubview(replayGameButton)
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
    
    @objc func loadGameStage() {
        // Reload actual stage on gameover or load next stage if current stage is completed
        if let scene = GameScene(fileNamed: "Stage\(actualStage)") {
            let animation = SKTransition.crossFade(withDuration: 1)
            self.view?.presentScene(scene, transition: animation)
        }
        loadGameButton.removeFromSuperview()
        replayGameButton.removeFromSuperview()
    }
    
}
