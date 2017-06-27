//
//  Umbrella.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 26..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Umbrella: SKSpriteNode {
    
    var protectDuration: Int = 3
    var initialSize: CGSize = CGSize(width: 70, height: 60)
    
    init() {
        self.protectDuration = 3
        let texture = SKTexture(imageNamed: "umbrella")
        super.init(texture: texture, color: UIColor.clear, size: initialSize)
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: initialSize.width, height: initialSize.height))
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.umbrella.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.cat.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
