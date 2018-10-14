//
//  SKTextureExtension.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2018. 10. 14..
//  Copyright © 2018. Horváth Balázs. All rights reserved.
//

import SpriteKit

extension SKTexture {
    convenience internal init!(assetIdentifier: ImageAssetIdentifier) {
        self.init(imageNamed: assetIdentifier.rawValue)
    }
}
