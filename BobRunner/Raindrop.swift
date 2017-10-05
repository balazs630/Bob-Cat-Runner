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
    
    var initialSize: CGSize = CGSize(width: 20, height: 25)
    
    init() {
        let texture = SKTexture(imageNamed: "raindrop")
        super.init(texture: texture, color: UIColor.clear, size: initialSize)
        
        physicsBody = SKPhysicsBody(circleOfRadius: initialSize.width / 2)
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.rainDrop.rawValue
        physicsBody?.collisionBitMask = PhysicsCategory.noCategory.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.cat.rawValue | PhysicsCategory.ground.rawValue
    }
    
    class func checkRainDrop(frameRate: TimeInterval, cloud: SKSpriteNode, scene gs: GameScene) {
        // Add time to timer
        timeSinceRainDrop += frameRate
        
        // Return if it hasn't been enogh time to drop raindrop
        if timeSinceRainDrop < rainDropRate {
            return
        } else {
            dropRainDrop(from: cloud, scene: gs)
            timeSinceRainDrop = 0
        }
    }
    
    class func dropRainDrop(from cloud: SKSpriteNode, scene gs: GameScene) {
        let cloudRadius: Int = Int(cloud.size.width/2) - 20
        
        // Drop raindrops randomly according to cloud width
        var droppingPoint: CGPoint = cloud.position
        droppingPoint.x += CGFloat(Util.generateRandomNumber(range: -1*cloudRadius...cloudRadius))
        
        let raindrop = Raindrop()
        raindrop.position = droppingPoint
        raindrop.move(toParent: gs)
    }
    
    class func explode(raindrop: SKNode, scene gs: GameScene) {
        let rainDropExplosion: SKEmitterNode = SKEmitterNode(fileNamed: "RainDropExplosion")!
        rainDropExplosion.position = raindrop.position
        gs.addChild(rainDropExplosion)
        raindrop.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
