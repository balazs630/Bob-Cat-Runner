//
//  Stage.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 10. 06..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import Foundation

struct Stage {
    static let maxStageCount = 2
    
    var actual: Int {
        get {
            return UserDefaults.standard.integer(forKey: Key.actualStage)
        }
        set(newStage) {
            UserDefaults.standard.set(newStage, forKey: Key.actualStage)
            UserDefaults.standard.synchronize()
        }
    }
    
    var actualStageName: String {
        get {
            return "Stage\(actual)"
        }
    }
    
    var currentClouds: [String] {
        get {
            // Stage number : cloud names
            let clouds: [Int: [String]] = [
                1: ["cloud1"],
                2: ["cloud1", "cloud2"]
            ]
            
            return clouds[actual].unsafelyUnwrapped
        }
    }
    
    var currentRainIntensity: Double {
        get {
            // Stage number : rainDropRate (delay between two raindrops)
            let clouds: [Int: Double] = [
                1 : 1,
                2 : 0.5,
                3 : 0.1
            ]
            
            return clouds[actual]!
        }
    }
}
