//
//  Constants.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 10. 29..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import Foundation
import CoreGraphics

struct Constant {
    static let standardCatTextureScale = CGFloat(1.0)
    static let umbrellaCatTextureScale = CGFloat(1.8)
    static let countDownInitialSeconds = 2
    static let cameraOffset = CGFloat(150)

    // Stage number: cloud count
    static let clouds: [Int: Int] = [
        1: 3,
        2: 5,
        3: 8
    ]

    // Stage number: raindropRate (delay between two raindrops in seconds)
    static let rainIntensity: [Int: Double] = [
        1: 1,
        2: 0.5,
        3: 0.4
    ]
}

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

    struct Layer {
        static let background = "background-layer"
        static let midground = "mid-layer"
        static let foreground = "foreground-layer"
    }
}

struct Button {
    struct NextStage {
        static let name = "btnNext"
        static let tag = 1
    }

    struct ReloadStage {
        static let name = "btnReload"
        static let tag = 2
    }

    struct ReplayGame {
        static let name = "btnReplay"
        static let tag = 3
    }

    enum Frame {
        static let narrow = CGRect(x: 100, y: 100, width: 120, height: 50)
        static let wide = CGRect(x: 100, y: 100, width: 240, height: 50)
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
