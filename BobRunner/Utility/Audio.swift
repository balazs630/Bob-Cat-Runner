//
//  Audio.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 03..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Audio {
    class func setBackgroundMusic(for gamescene: GameScene) {
        let backgroundMusic = SKAudioNode(fileNamed: SoundAssetIdentifier.backgroundMusic.rawValue)
        backgroundMusic.autoplayLooped = true
        gamescene.addChild(backgroundMusic)
    }
}
