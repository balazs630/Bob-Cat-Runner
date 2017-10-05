//
//  Util.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 06. 20..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import Foundation

class Util {
    
    class func generateRandomNumber(range: ClosedRange<Int>) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }
    
    class func delay(_ delay: Double, closure:@escaping ()->Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
