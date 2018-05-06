//
//  SpriteKitExtensions.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2018. 05. 06..
//  Copyright © 2018. Horváth Balázs. All rights reserved.
//

import SpriteKit

public extension SKTexture {
    convenience internal init!(assetIdentifier: ImageAssetIdentifier) {
        self.init(imageNamed: assetIdentifier.rawValue)
    }
}

public extension SKAction {
    internal class func playSound(assetIdentifier: SoundAssetIdentifier) -> SKAction {
        return SKAction.playSoundFileNamed(assetIdentifier.rawValue, waitForCompletion: false)
    }
}

public extension SKView {
    func isDebugEnabled(_ state: Bool) {
        if state {
            self.showsFPS = true
            self.showsNodeCount = true
            self.showsDrawCount = true
            self.showsQuadCount = true
            self.showsPhysics = true
            self.showsFields = true
        }
    }
}
