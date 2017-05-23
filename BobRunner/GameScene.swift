//
//  GameScene.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 05. 22..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    var cloud: SKSpriteNode?
    var cat: SKSpriteNode?

    var rainDropRate: TimeInterval = 1
    var timeSinceRainDrop: TimeInterval = 0
    var lastTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        view.showsPhysics = true
        cat = self.childNode(withName: "cat") as? SKSpriteNode
        cloud = self.childNode(withName: "cloud") as? SKSpriteNode

    }

    func touchDown(atPoint pos: CGPoint) {

    }

    func touchMoved(toPoint pos: CGPoint) {

    }

    func touchUp(atPoint pos: CGPoint) {

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        checkRainDrop(currentTime - lastTime)
        lastTime = currentTime
    }

    func checkRainDrop(_ frameRate: TimeInterval) {
        // add time to timer
        timeSinceRainDrop += frameRate

        //return if it hasn't been enogh time to drop raindrop
        if timeSinceRainDrop < rainDropRate {
            return
        } else {
            dropRainDrop()
            timeSinceRainDrop = 0
        }
    }

    func dropRainDrop() {
        let scene: SKScene = SKScene(fileNamed: "Raindrop")!
        let raindrop = scene.childNode(withName: "raindrop")
        let cloudRadius: Int = Int(cloud!.size.width/2) - 20

        var droppingPoint: CGPoint = cloud!.position
        // drop raindrops randomly according to cloud width
        droppingPoint.x += CGFloat(generateRandomNumber(range: -1*cloudRadius...cloudRadius))

        raindrop?.position = droppingPoint
        raindrop?.move(toParent: self)
    }

    func generateRandomNumber(range: ClosedRange<Int>) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }
}
