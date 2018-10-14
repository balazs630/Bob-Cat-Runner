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
        var currentClouds = [String]()
        (1...Constant.clouds[current]!).forEach { index in
            currentClouds.append("cloud\(index)")
        }

        return currentClouds
    }

    static var rainIntensity: Double {
        return Constant.rainIntensity[current]!
    }

    static func isAllCompleted() -> Bool {
        return Stage.current == Stage.maxCount
    }
}
