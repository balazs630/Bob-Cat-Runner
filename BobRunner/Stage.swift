//
//  Stage.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 10. 06..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import SpriteKit

struct Stage {
    
    static var maxCount: Int {
        var i = 0
        while SKScene(fileNamed: "Stage\(i+1)") != nil {
            i+=1
        }
        return i
    }
    
    var current: Int {
        get {
            return UserDefaults.standard.integer(forKey: Key.actualStage)
        }
        set(newStage) {
            UserDefaults.standard.set(newStage, forKey: Key.actualStage)
            UserDefaults.standard.synchronize()
        }
    }
    
    var name: String {
        return "Stage\(current)"
    }
    
    var clouds: [String] {
        // Stage number : cloud names
        let clouds: [Int: [String]] = [
            1: [Node.cloud1],
            2: [Node.cloud1, Node.cloud2],
            3: [Node.cloud1, Node.cloud2]
        ]
        
        return clouds[current].unsafelyUnwrapped
    }
    
    var rainIntensity: Double {
        // Stage number : raindropRate (delay between two raindrops)
        let clouds: [Int: Double] = [
            1 : 1,
            2 : 0.5,
            3 : 0.3
        ]
        
        return clouds[current]!
    }
    
}
