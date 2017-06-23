//
//  Raindrop.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 23..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Raindrop: SKSpriteNode {

    static var rainDropRate: TimeInterval = 1
    static var timeSinceRainDrop: TimeInterval = 0
    static var lastTime: TimeInterval = 0

    class func checkRainDrop(frameRate: TimeInterval, cloud: SKSpriteNode, for gs: GameScene) {
        // Add time to timer
        timeSinceRainDrop += frameRate

        // Return if it hasn't been enogh time to drop raindrop
        if timeSinceRainDrop < rainDropRate {
            return
        } else {
            dropRainDrop(from: cloud, for: gs)
            timeSinceRainDrop = 0
        }
    }

    class func dropRainDrop(from cloud: SKSpriteNode, for gs: GameScene) {
        let scene: SKScene = SKScene(fileNamed: "Raindrop")!
        let raindrop = scene.childNode(withName: "raindrop")
        raindrop?.physicsBody?.categoryBitMask = PhysicsCategory.rainDrop.rawValue
        raindrop?.physicsBody?.collisionBitMask = PhysicsCategory.noCategory.rawValue
        raindrop?.physicsBody?.contactTestBitMask = PhysicsCategory.cat.rawValue | PhysicsCategory.ground.rawValue

        let cloudRadius: Int = Int(cloud.size.width/2) - 20

        var droppingPoint: CGPoint = cloud.position
        // Drop raindrops randomly according to cloud width
        droppingPoint.x += CGFloat(Util.generateRandomNumber(range: -1*cloudRadius...cloudRadius))

        raindrop?.position = droppingPoint
        raindrop?.move(toParent: gs)
    }

}
