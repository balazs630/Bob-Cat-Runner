//
//  Cloud.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 23..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Cloud: SKSpriteNode {

    var initialSize: CGSize = CGSize(width: 155, height: 100)
    var flyingCloudAnimation = SKAction()

    init() {
        let texture = SKTexture(imageNamed: "cloud")
        super.init(texture: texture, color: UIColor.clear, size: initialSize)

        createFlyingCloudAnimation()
        run(flyingCloudAnimation)

        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: initialSize.width, height: initialSize.height))
        anchorPoint = CGPoint(x: 0.5, y: 0)
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.cloud.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.noCategory.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.cat.rawValue
    }

    func createFlyingCloudAnimation() {
        let flyAction: SKAction = SKAction.moveBy(x: 400, y: 0, duration: 6)
        flyAction.timingMode = .easeInEaseOut
        let reversedflyAction: SKAction = flyAction.reversed()
        let sequence: SKAction = SKAction.sequence([flyAction, reversedflyAction])
        flyingCloudAnimation = SKAction.repeatForever(sequence)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
