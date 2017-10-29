//
//  Raindrop.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 23..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Raindrop: SKSpriteNode {
    
    static var timeSinceRainDrop: TimeInterval = 0
    static var lastTime: TimeInterval = 0
    
    var initialSize: CGSize = CGSize(width: 18, height: 24)
    
    init() {
        let texture = SKTexture(assetIdentifier: .Raindrop)
        super.init(texture: texture, color: UIColor.clear, size: initialSize)
    }
    
    class func checkRainDrop(frameRate: TimeInterval, rainDropRate: Double, stage: Stage, scene gs: GameScene) {
        // Add time to timer
        timeSinceRainDrop += frameRate
        
        // Return if it hasn't been enogh time to drop raindrop
        if timeSinceRainDrop < rainDropRate {
            return
        } else {
            // Drop raindrops from each cloud added to the given stage
            for cloudName in stage.currentClouds {
                dropRainDrop(from: gs.childNode(withName: cloudName) as! SKSpriteNode, scene: gs)
            }
            timeSinceRainDrop = 0
        }
    }
    
    class func dropRainDrop(from cloud: SKSpriteNode, scene gs: GameScene) {
        let cloudRadius: Int = Int(cloud.size.width/2) - 20
        
        // Drop raindrops randomly according to cloud width
        var droppingPoint: CGPoint = cloud.position
        droppingPoint.x += CGFloat(Util.generateRandomNumber(range: -1*cloudRadius...cloudRadius))
        
        var raindrop = Raindrop()
        let raindropScene = SKScene(fileNamed: Scene.raindrop)
        if let rainDropNode = raindropScene?.childNode(withName: Node.raindrop) as? Raindrop {
            raindrop = rainDropNode
        }
        
        raindrop.position = droppingPoint
        raindrop.move(toParent: gs)
    }
    
    class func explode(raindrop: SKNode, scene gs: GameScene) {
        let rainDropExplosion: SKEmitterNode = SKEmitterNode(fileNamed: Scene.raindropExplosion)!
        rainDropExplosion.position = raindrop.position
        gs.addChild(rainDropExplosion)
        raindrop.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
