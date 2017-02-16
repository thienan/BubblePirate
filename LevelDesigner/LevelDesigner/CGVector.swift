//
//  CGVector.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit


extension CGVector {
    var x: CGFloat {
        return dx
    }
    
    var y: CGFloat {
        return dy
    }
    
    init(_ dx: CGFloat, _ dy: CGFloat) {
        self.init(dx: dx, dy: dy)
    }
    
    static func + (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(left.x + right.x, left.y + right.y)
    }
    
    static func - (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(left.x - right.x, left.y - right.y)
    }
    
    static func * (left: CGVector, right: CGFloat) -> CGVector {
        return CGVector(left.x * right, left.y * right)
    }
    
    static func / (left: CGVector, right: CGFloat) -> CGVector {
        return CGVector(left.x / right, left.y / right)
    }
    
    static func distance(_ vec: CGVector) -> CGFloat {
        return sqrt(pow(vec.x, 2) + pow(vec.y, 2))
    }
    
    static func distanceSquare(_ vec: CGVector) -> CGFloat {
        return pow(vec.x, 2) + pow(vec.y, 2)
    }
    
    static func toPoint(_ vec: CGVector) -> CGPoint {
        return CGPoint(x: vec.x, y: vec.y)
    }
    
    static func toVector(_ vec: CGPoint) -> CGVector {
        return CGVector(vec.x, vec.y)
    }
    
    static func normalize(_ vec: CGVector) -> CGVector {
        return (vec / distance(vec))
    }
}
