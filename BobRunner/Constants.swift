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
    static let camera = "camera"
    static let cat = "cat"
    static let raindrop = "raindrop"
    
    static let cloud1 = "cloud1"
    static let cloud2 = "cloud2"
    static let cloud3 = "cloud3"
    static let cloud4 = "cloud4"
    static let cloud5 = "cloud5"
    static let cloud6 = "cloud6"
    static let cloud7 = "cloud7"
    static let cloud8 = "cloud8"
    
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
        case catStandLeft = "pusheen-stand-left"
        case catStandRight = "pusheen-stand-right"
        
        case catJumpLeft = "pusheen-jump-left"
        case catJumpRight = "pusheen-jump-right"
        
        case catUmbrellaLeft = "pusheen-umbrella-left"
        case catUmbrellaRight = "pusheen-umbrella-right"
        
        case catDead = "pusheen-dead"
        
        case raindrop = "raindrop"
    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(imageNamed: assetIdentifier.rawValue)
    }
    
}
