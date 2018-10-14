//
//  Raindrop.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 23..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Raindrop: SKSpriteNode {

    // MARK: Properties
    static var timeSinceLastRaindrop: TimeInterval = 0
    static var lastTime: TimeInterval = 0
    var initialSize = CGSize(width: 18, height: 24)

    // MARK: Initializers
    init() {
        let texture = SKTexture(assetIdentifier: .raindrop)
        super.init(texture: texture, color: .clear, size: initialSize)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Actions
    class func checkRaindrop(timeBetweenFrames: TimeInterval, in gameScene: GameScene) {
        // Add time to timer
        timeSinceLastRaindrop += timeBetweenFrames

        // Return if it hasn't been enogh time to drop raindrop
        if timeSinceLastRaindrop < Stage.rainIntensity {
            return
        } else {
            // Drop raindrops from each cloud added to the given stage
            Stage.clouds.forEach {
                if let cloud = gameScene.childNode(withName: $0) as? SKSpriteNode {
                    dropRaindrop(from: cloud, in: gameScene)
                }
            }
            timeSinceLastRaindrop = 0
        }
    }

    private class func dropRaindrop(from cloud: SKSpriteNode, in gameScene: GameScene) {
        let cloudRadius = cloud.size.width / 2 - 20

        // Drop raindrops randomly according to cloud width
        var droppingPoint = cloud.position
        droppingPoint.x += CGFloat.random(in: -cloudRadius...cloudRadius)

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
}
