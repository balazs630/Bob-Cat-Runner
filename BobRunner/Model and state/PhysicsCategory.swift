//
//  PhysicsCategory.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2018. 05. 06..
//  Copyright © 2018. Horváth Balázs. All rights reserved.
//

enum PhysicsCategory: UInt32 {
    case noCategory = 0
    case ground = 1
    case cat = 2
    case cloud = 4
    case raindrop = 8
    case umbrella = 16
    case house = 32
    case dangerZone = 64
}
