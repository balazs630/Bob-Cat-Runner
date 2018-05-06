//
//  SKTextureExtension.swift
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
