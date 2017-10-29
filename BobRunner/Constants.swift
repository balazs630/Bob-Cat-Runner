//
//  Constants.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 10. 29..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

struct Scene {
    static let raindrop = "Raindrop"
    static let raindropExplosion = "RaindropExplosion"
}

struct Node {
    static let cat = "cat"
    static let raindrop = "raindrop"
    
    struct Lbl {
        static let lifeCounter = "lblLifeCounter"
        static let umbrellaCountDown = "lblUmbrellaCountDown"
    }
    
    struct Layer {
        static let background = "background-layer"
        static let midground = "mid-layer"
        static let foreground = "foreground-layer"
    }
}

struct Key {
    static let actualStage = "actualStage"
    static let isAppAlreadyLaunchedOnce = "isAppAlreadyLaunchedOnce"
    static let movementMultiplier = "movementMultiplier"
}

extension SKTexture {
    enum AssetIdentifier: String {
        case CatStandLeft = "pusheen-stand-left"
        case CatStandRight = "pusheen-stand-right"
        
        case CatJumpLeft = "pusheen-jump-left"
        case CatJumpRight = "pusheen-jump-right"
        
        case CatUmbrellaLeft = "pusheen-umbrella-left"
        case CatUmbrellaRight = "pusheen-umbrella-right"
        
        case CatDead = "pusheen-dead"
        
        case Raindrop = "raindrop"
    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(imageNamed: assetIdentifier.rawValue)
    }
    
}
