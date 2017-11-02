//
//  Raindrop.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 23..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Raindrop: SKSpriteNode {
    static var timeSinceLastRaindrop: TimeInterval = 0
    static var lastTime: TimeInterval = 0
    var initialSize = CGSize(width: 18, height: 24)
    
    init() {
        let texture = SKTexture(assetIdentifier: .raindrop)
        super.init(texture: texture, color: UIColor.clear, size: initialSize)
    }
    
    class func checkRaindrop(timeBetweenFrames: TimeInterval, stage: Stage, in gameScene: GameScene) {
        // Add time to timer
        timeSinceLastRaindrop += timeBetweenFrames
        
        // Return if it hasn't been enogh time to drop raindrop
        if timeSinceLastRaindrop < stage.rainIntensity {
            return
        } else {
            // Drop raindrops from each cloud added to the given stage
            for cloudName in stage.clouds {
                if let cloud = gameScene.childNode(withName: cloudName) as? SKSpriteNode {
                    dropRaindrop(from: cloud, in: gameScene)
                }
            }
            timeSinceLastRaindrop = 0
        }
    }
    
    class func dropRaindrop(from cloud: SKSpriteNode, in gameScene: GameScene) {
        let cloudRadius = Int(cloud.size.width/2) - 20
        
        // Drop raindrops randomly according to cloud width
        var droppingPoint = cloud.position
        droppingPoint.x += CGFloat(Util.generateRandomNumber(range: -1*cloudRadius...cloudRadius))
        
        var raindrop = Raindrop()
        let raindropScene = SKScene(fileNamed: Scene.raindrop)
        if let raindropNode = raindropScene?.childNode(withName: Node.raindrop) as? Raindrop {
            raindrop = raindropNode
        }
        
        raindrop.position = droppingPoint
        raindrop.move(toParent: gameScene)
    }
    
    class func explode(raindrop: SKNode, in gameScene: GameScene) {
        let raindropExplosion = SKEmitterNode(fileNamed: Scene.raindropExplosion)!
        raindropExplosion.position = raindrop.position
        gameScene.addChild(raindropExplosion)
        raindrop.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
