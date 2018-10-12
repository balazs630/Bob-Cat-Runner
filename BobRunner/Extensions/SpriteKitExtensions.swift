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
            showsFPS = true
            showsNodeCount = true
            showsDrawCount = true
            showsQuadCount = true
            showsPhysics = true
            showsFields = true
        }
    }

    var isLandscape: Bool {
        return UIDevice.current.orientation.isLandscape
    }

    var hasTopNotch: Bool {
        // iPhone XR, X-XS, XS Max
        let screenHeights = [1792, 2436, 2688]

        if isLandscape {
            return screenHeights.contains(Int(UIScreen.main.nativeBounds.width))
        } else {
            return screenHeights.contains(Int(UIScreen.main.nativeBounds.height))
        }
    }

    var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    func addSubviews(_ subviews: [UIView]) {
        for view in subviews {
            addSubview(view)
        }
    }
}
