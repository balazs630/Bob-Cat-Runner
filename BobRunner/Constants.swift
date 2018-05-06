//
//  Constants.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 10. 29..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import Foundation

struct Scene {
    static let raindrop = "Raindrop"
    static let raindropExplosion = "RaindropExplosion"
    static let hudStandard = "HUD-Standard"
    static let hudIphoneX = "HUD-IPhoneX"
}

struct Node {
    static let camera = "camera"
    static let hud = "hud"
    static let cat = "cat"
    static let raindrop = "raindrop"

    struct Lbl {
        static let lifeCounter = "//lblLifeCounter"
        static let umbrellaCountDown = "//lblUmbrellaCountDown"
    }

    struct Button {
        static let reload = "btnReload"
    }

    struct Layer {
        static let background = "background-layer"
        static let midground = "mid-layer"
        static let foreground = "foreground-layer"
    }
}

extension UserDefaults {
    struct Key {
        static let actualStage = "actualStage"
        static let isAppAlreadyLaunchedOnce = "isAppAlreadyLaunchedOnce"
    }
}

struct UserData {
    struct Key {
        static let movementMultiplier = "movementMultiplier"
    }
}

enum GameOverType {
    case flood
    case drown
}

enum ImageAssetIdentifier: String {
    case catStandLeft = "pusheen-stand-left"
    case catStandRight = "pusheen-stand-right"

    case catJumpLeft = "pusheen-jump-left"
    case catJumpRight = "pusheen-jump-right"

    case catUmbrellaLeft = "pusheen-umbrella-left"
    case catUmbrellaRight = "pusheen-umbrella-right"

    case catDead = "pusheen-dead"

    case raindrop = "raindrop"
}

enum SoundAssetIdentifier: String {
    case backgroundMusic = "background_music.m4a"
    case collectUmbrella = "collectUmbrella.m4a"
    case raindropHitCat = "raindrop_hit_cat.m4a"
    case raindropHitUmbrella = "raindrop_hit_umbrella.m4a"
    case crowdCelebrate = "crowd_celebrate.m4a"
    case gameover = "gameover.m4a"
}
