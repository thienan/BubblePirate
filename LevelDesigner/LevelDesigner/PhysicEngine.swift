//
//  PhysicEngine.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class PhysicEngine {
    private(set) var worldBound: Bool = false
    private(set) var worldBoundRect: CGRect = CGRect.init()
    
    public init() {
    }

    public func update(_ deltaTime: CGFloat, _ physicObjects: [PhysicObject]) {
        for physicObject1 in physicObjects {
            if isStatic(physicObject1) {
                continue
            }
            updatePhysicObject(deltaTime, physicObject1)
            checkCollisionWithWorldBound(physicObject1)

            for physicObject2 in physicObjects {
                checkCollision(physicObject1, physicObject2)
            }
        }
    }
    
    private func updatePhysicObject(_ deltaTime: CGFloat, _ physicObject: PhysicObject) {
        var physicObject = physicObject
        physicObject.position = physicObject.position + (physicObject.velocity * deltaTime)
    }
    
    private func isStatic(_ physicObject: PhysicObject) -> Bool {
        return physicObject.velocity == CGVector.zero
    }
    
    private func checkCollision(_ physicObject1: PhysicObject, _ physicObject2: PhysicObject) {
        if physicObject1.isEqual(physicObject2) {
            return
        }
        if !physicObject1.isAlive() || !physicObject2.isAlive() {
            return
        }
        guard let collider1 = physicObject1.getSphereCollider() else {
            return
        }
        guard let collider2 = physicObject2.getSphereCollider() else {
            return
        }
        if collider1.intersect(collider2) {
            physicObject1.onCollide(physicObject2)
            physicObject2.onCollide(physicObject1)
        }
    }
    
    private func checkCollisionWithWorldBound(_ physicObject: PhysicObject) {
        if !worldBound {
            return
        }
        guard let collider = physicObject.getSphereCollider() else {
            return
        }
        if collider.intersect(leftVerticalLine: worldBoundRect.minX) {
            physicObject.onCollideWithLeftWorldBound()
        }
        if collider.intersect(rightVerticalLine: worldBoundRect.maxX) {
            physicObject.onCollideWithRightWorldBound()
        }
        if collider.intersect(topHorizontalLine: worldBoundRect.minY) {
            physicObject.onCollideWithTopWorldBound()
        }
        if collider.intersect(btmHorizontalLine: worldBoundRect.maxY) {
            physicObject.onCollideWithBtmWorldBound()
        }
    }
    
    public func setWorldBound(_ worldBoundRect: CGRect) {
        self.worldBound = true
        self.worldBoundRect = worldBoundRect
    }
}
