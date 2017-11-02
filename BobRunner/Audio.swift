//
//  Audio.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 03..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

class Audio {
    
    class func setBackgroundMusic(for gs: GameScene) {
        let bgMusic = SKAudioNode(fileNamed: "background_music.m4a")
        bgMusic.autoplayLooped = true
        gs.addChild(bgMusic)
    }
    
}
