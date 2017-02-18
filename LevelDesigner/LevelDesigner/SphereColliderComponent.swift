//
//  SphereCollider.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class SphereColliderComponent: Component, SphereCollider {
    private static var idCount = 0
    
    var centre: CGVector
    var radius: CGFloat
    let uniqueId: Int
    
    init(_ parent: GameObject, _ centre: CGVector, _ radius: CGFloat) {
        self.centre = CGVector(0, 0)
        self.radius = radius
        
        uniqueId = SphereColliderComponent.idCount
        SphereColliderComponent.idCount += 1
        
        super.init(parent)
    }
    
    convenience override init(_ parent: GameObject) {
        self.init(parent, CGVector(0, 0), 0)
    }
    
    public func intersect(_ other: SphereCollider) -> Bool {
        let pos1 = getCenterWorldPosition()
        let pos2 = other.getCenterWorldPosition()
        let distanceSquare = CGVector.distanceSquare(pos1 - pos2)

        return distanceSquare < pow(radius + other.radius, 2)
    }
    
    public func intersect(rightVerticalLine: CGFloat) -> Bool {
        let pos = GameEngine.localToWorldPosition(parent, centre)
        return pos.x + radius > rightVerticalLine
    }
    
    public func intersect(leftVerticalLine: CGFloat) -> Bool {
        let pos = GameEngine.localToWorldPosition(parent, centre)
        return pos.x - radius < leftVerticalLine
    }
    
    public func intersect(topHorizontalLine: CGFloat) -> Bool {
        let pos = GameEngine.localToWorldPosition(parent, centre)
        return pos.y - radius < topHorizontalLine
    }
    
    public func intersect(btmHorizontalLine: CGFloat) -> Bool {
        let pos = GameEngine.localToWorldPosition(parent, centre)
        return pos.y + radius > btmHorizontalLine
    }
    
    public func contains(point: CGVector) -> Bool {
        let pos = GameEngine.localToWorldPosition(parent, centre)
        let distanceSquare = CGVector.distanceSquare(pos - point)
        return distanceSquare < (radius * radius)
    }
    
    public func getCenterWorldPosition() -> CGVector {
        return GameEngine.localToWorldPosition(parent, centre)
    }
}
