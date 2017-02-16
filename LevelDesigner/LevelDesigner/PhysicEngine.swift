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
    
    init() {
    }

    public func update(_ collidableObjects: [CollidableObject]) {
        for collidableObject1 in collidableObjects {
            if collidableObject1.isStatic {
                continue
            }
            checkCollisionWithWorldBound(collidableObject1)
            
            for collidableObject2 in collidableObjects {
                checkCollision(collidableObject1, collidableObject2)
            }
        }
    }
    
    private func checkCollision(_ collidableObject1: CollidableObject, _ collidableObject2: CollidableObject) {
        if collidableObject1.isEqual(collidableObject2) {
            return
        }
        if !collidableObject1.isAlive() || !collidableObject2.isAlive() {
            return
        }
        guard let collider1 = collidableObject1.getSphereCollider() else {
            return
        }
        guard let collider2 = collidableObject2.getSphereCollider() else {
            return
        }
        if collider1.intersect(collider2) {
            collidableObject1.onCollide(collidableObject2)
            collidableObject2.onCollide(collidableObject1)
        }
    }
    
    private func checkCollisionWithWorldBound(_ collidableObject: CollidableObject) {
        if !worldBound {
            return
        }
        guard let collider = collidableObject.getSphereCollider() else {
            return
        }
        if collider.intersect(leftVerticalLine: worldBoundRect.minX) {
            collidableObject.onCollideWithLeftWorldBound()
        }
        if collider.intersect(rightVerticalLine: worldBoundRect.maxX) {
            collidableObject.onCollideWithRightWorldBound()
        }
        if collider.intersect(topHorizontalLine: worldBoundRect.minY) {
            collidableObject.onCollideWithTopWorldBound()
        }
        if collider.intersect(btmHorizontalLine: worldBoundRect.maxY) {
            collidableObject.onCollideWithBtmWorldBound()
        }
    }
    
    public func setWorldBound(_ worldBoundRect: CGRect) {
        self.worldBound = true
        self.worldBoundRect = worldBoundRect
    }
}
