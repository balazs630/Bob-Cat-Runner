//
//  SKViewExtensions.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2018. 05. 06..
//  Copyright © 2018. Horváth Balázs. All rights reserved.
//

import SpriteKit

extension SKView {
    func isDebugEnabled(_ state: Bool) {
        showsFPS = state
        showsNodeCount = state
        showsDrawCount = state
        showsQuadCount = state
        showsPhysics = state
        showsFields = state
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
        subviews.forEach { addSubview($0) }
    }

    var topLeftCorner: CGPoint {
        return CGPoint(x: -1 * self.frame.width / 2,
                       y: self.frame.height / 2)
    }

    var topRightCorner: CGPoint {
        return CGPoint(x: self.frame.width / 2,
                       y: self.frame.height / 2)
    }
}
