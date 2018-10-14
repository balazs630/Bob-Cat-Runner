//
//  SKActionExtensions.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2018. 10. 14..
//  Copyright © 2018. Horváth Balázs. All rights reserved.
//

import SpriteKit

extension SKAction {
    internal class func playSound(assetIdentifier: SoundAssetIdentifier) -> SKAction {
        return SKAction.playSoundFileNamed(assetIdentifier.rawValue, waitForCompletion: false)
    }
}
