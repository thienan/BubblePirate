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
    public var x: CGFloat {
        return dx
    }
    
    public var y: CGFloat {
        return dy
    }
    
    public init(_ dx: CGFloat, _ dy: CGFloat) {
        self.init(dx: dx, dy: dy)
    }
    
    public static func + (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(left.x + right.x, left.y + right.y)
    }
    
    public static func - (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(left.x - right.x, left.y - right.y)
    }
    
    public static func * (left: CGVector, right: CGFloat) -> CGVector {
        return CGVector(left.x * right, left.y * right)
    }
    
    public static func / (left: CGVector, right: CGFloat) -> CGVector {
        return CGVector(left.x / right, left.y / right)
    }
    
    public static func distance(_ vec: CGVector) -> CGFloat {
        return sqrt(pow(vec.x, 2) + pow(vec.y, 2))
    }
    
    public static func distanceSquare(_ vec: CGVector) -> CGFloat {
        return pow(vec.x, 2) + pow(vec.y, 2)
    }
    
    public static func toPoint(_ vec: CGVector) -> CGPoint {
        return CGPoint(x: vec.x, y: vec.y)
    }
    
    public static func toVector(_ vec: CGPoint) -> CGVector {
        return CGVector(vec.x, vec.y)
    }
    
    public static func normalize(_ vec: CGVector) -> CGVector {
        return (vec / distance(vec))
    }
    
    public static func dot(_ vec1: CGVector, _ vec2: CGVector) -> CGFloat {
        return (vec1.x * vec2.x) + (vec1.y * vec2.y)
    }
    
    public static func lerp(_ vec1: CGVector, _ vec2: CGVector, _ t: CGFloat) -> CGVector {
        return vec1 + ((vec2 - vec1) * t)
    }
}
