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
        var stageNumber = 0
        while SKScene(fileNamed: "Stage\(stageNumber + 1)") != nil {
            stageNumber += 1
        }
        return stageNumber
    }

    static var current: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserDefaults.Key.actualStage)
        }
        set(newStage) {
            UserDefaults.standard.set(newStage, forKey: UserDefaults.Key.actualStage)
            UserDefaults.standard.synchronize()
        }
    }

    static var name: String {
        return "Stage\(current)"
    }

    static var clouds: [String] {
        // Stage number: cloud names
        let clouds: [Int: Int] = [
            1: 3,
            2: 5,
            3: 8
        ]

        var currentClouds = [String]()
        for index in 1...clouds[current]! {
            currentClouds.append("cloud\(index)")
        }

        return currentClouds
    }

    static var rainIntensity: Double {
        // Stage number: raindropRate (delay between two raindrops)
        let clouds: [Int: Double] = [
            1: 1,
            2: 0.5,
            3: 0.4
        ]

        return clouds[current]!
    }

    static func isAllCompleted() -> Bool {
        return Stage.current == Stage.maxCount ? true : false
    }

}
