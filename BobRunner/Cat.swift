//
//  Cat.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 16..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Cat: SKSpriteNode {
    
    let jumpImpulse = 800
    let runSpeed = CGFloat(5)
    
    var lifes: Int = 5
    var isProtected = false
    var initialSize = CGSize(width: 84, height: 54)
    
    let dieAction = SKAction.rotate(byAngle: (.pi), duration: 0.5)
    
    let collectUmbrellaSound = SKAction.playSoundFileNamed("collectUmbrella.m4a", waitForCompletion: false)
    let raindropHitCatSound = SKAction.playSoundFileNamed("raindrop_hit_cat.m4a", waitForCompletion: false)
    let raindropHitUmbrellaSound = SKAction.playSoundFileNamed("raindrop_hit_umbrella.m4a", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("gameover.m4a", waitForCompletion: false)
    let celebrateSound = SKAction.playSoundFileNamed("crowd_celebrate.m4a", waitForCompletion: false)
    
    init(lifes: Int) {
        self.lifes = lifes
        let texture = SKTexture(assetIdentifier: .catStandRight)
        super.init(texture: texture, color: UIColor.clear, size: initialSize)
    }
    
    func move(left: Bool) {
        if left {
            position.x -= runSpeed
        } else {
            position.x += runSpeed
        }
    }
    
    func jumpUp() {
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
    }
    
    func takeDamage() {
        lifes -= 1
        run(raindropHitCatSound)
    }
    
    func collect(umbrella: SKNode) {
        umbrella.removeFromParent()
        run(collectUmbrellaSound)
        isProtected = true
    }
    
    func isAlive() -> Bool {
        return lifes > 0 ? true : false
    }
    
    func die() {
        run(SKAction.sequence([gameOverSound, dieAction]))
        texture = SKTexture(assetIdentifier: .catDead)
        isProtected = false
    }
    
    func drown() {
        run(gameOverSound)
        isProtected = false
    }
    
    func celebrate() {
        run(celebrateSound)
        
        let jumpAction = SKAction.applyForce(CGVector(dx: 0, dy: 800), duration: TimeInterval(1.5))
        var jumpSequence = [SKAction]()
        
        for _ in 0...4 {
            jumpSequence.append(jumpAction)
        }
        
        // Jump up 5 times
        run(SKAction.sequence(jumpSequence))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
