//
//  SKNodeExtension.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2018. 10. 14..
//  Copyright © 2018. Horváth Balázs. All rights reserved.
//

import SpriteKit

extension SKNode {
    func addChilds(_ childs: [SKNode]) {
        childs.forEach { self.addChild($0) }
    }
}
