//
//  SoundsAndMusic.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 03..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit
import AVFoundation

class Audio: SKScene {

    class func setBackgroundMusic(for gs: GameScene) {
        let bgMusic: SKAudioNode = SKAudioNode(fileNamed: "background_music.m4a")
        bgMusic.autoplayLooped = true
        gs.addChild(bgMusic)
    }

    class func preloadSounds() {
        do {
            let sounds: [String] = ["raindrop_hit_cat", "gameover"]
            for sound in sounds {
                let path: String = Bundle.main.path(forResource: sound, ofType: "m4a")!
                let url: URL = URL(fileURLWithPath: path)
                let audioPlayer: AVAudioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.prepareToPlay()
            }
        } catch {
            print("Error thrown in func preloadSounds(): \(error)")
        }
    }

}
