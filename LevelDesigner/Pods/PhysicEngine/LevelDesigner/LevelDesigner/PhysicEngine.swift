//
//  PhysicEngine.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

public class PhysicEngine {
    public private(set) var worldBound: Bool = false
    public private(set) var worldBoundRect: CGRect = CGRect.init()
    
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
            if !isStatic(physicObject1) && isStatic(physicObject2) {
                handleDynamicStaticCollision(physicObject1, physicObject2)
            }
            if !isStatic(physicObject1) && !isStatic(physicObject2) {
                handleDynamicDynamicCollision(physicObject1, physicObject2)
            }
            physicObject1.onCollide(physicObject2)
            physicObject2.onCollide(physicObject1)
        }
    }
    
    private func handleDynamicStaticCollision(_ physicObject1: PhysicObject, _ physicObject2: PhysicObject) {
        var physicObject1 = physicObject1
        var physicObject2 = physicObject2
        guard let collider1 = physicObject1.getSphereCollider() else {
            return
        }
        guard let collider2 = physicObject2.getSphereCollider() else {
            return
        }
        let dir = CGVector.normalize(physicObject1.position - physicObject2.position)
        physicObject1.position = physicObject2.position + (dir * collider1.radius) + (dir * collider2.radius)
    }
    
    private func handleDynamicDynamicCollision(_ physicObject1: PhysicObject, _ physicObject2: PhysicObject) {
        var physicObject1 = physicObject1
        var physicObject2 = physicObject2
        guard let collider1 = physicObject1.getSphereCollider() else {
            return
        }
        guard let collider2 = physicObject2.getSphereCollider() else {
            return
        }
        let midPoint = (physicObject1.position + physicObject2.position) / 2
        let dir2To1 = CGVector.normalize(physicObject1.position - physicObject2.position)
        physicObject1.position = midPoint + (dir2To1 * collider1.radius)
        
        let dir1To2 = CGVector.normalize(physicObject2.position - physicObject1.position)
        physicObject2.position = midPoint + (dir1To2 * collider2.radius)
        
        let momentum = CGVector.dot(physicObject1.velocity, dir1To2) - CGVector.dot(physicObject2.velocity, dir1To2)
        
        physicObject1.velocity = physicObject1.velocity - dir1To2 * momentum
        physicObject2.velocity = physicObject2.velocity + dir1To2 * momentum
    }
    
    private func checkCollisionWithWorldBound(_ physicObject: PhysicObject) {
        var physicObject = physicObject
        if !worldBound {
            return
        }
        guard let collider = physicObject.getSphereCollider() else {
            return
        }
        if collider.intersect(leftVerticalLine: worldBoundRect.minX) {
            physicObject.position = CGVector(worldBoundRect.minX + collider.radius, physicObject.position.y)
            physicObject.onCollideWithLeftWorldBound()
        }
        if collider.intersect(rightVerticalLine: worldBoundRect.maxX) {
            physicObject.position = CGVector(worldBoundRect.maxX - collider.radius, physicObject.position.y)
            physicObject.onCollideWithRightWorldBound()
        }
        if collider.intersect(topHorizontalLine: worldBoundRect.minY) {
            physicObject.position = CGVector(physicObject.position.x, worldBoundRect.minY + collider.radius)
            physicObject.onCollideWithTopWorldBound()
        }
        if collider.intersect(btmHorizontalLine: worldBoundRect.maxY) {
            physicObject.position = CGVector(physicObject.position.x, worldBoundRect.maxY - collider.radius)
            physicObject.onCollideWithBtmWorldBound()
        }
    }

    public func rayCast(_ physicObjects: [PhysicObject], _ physicObjectBody: PhysicObject) -> [CGVector] {
        var physicObjectBody = physicObjectBody
        var positions = [CGVector]()
        var moving = true
        
        if !worldBound {
            return []
        }
        
        guard let collider1 = physicObjectBody.getSphereCollider() else {
            return []
        }
        
        while moving {
            for physicObject in physicObjects {
                guard let collider2 = physicObject.getSphereCollider() else {
                    continue
                }
                if isStatic(physicObject) && collider1.intersect(collider2) {
                    moving = false
                    positions.append(physicObjectBody.position)
                    break
                }
            }
            
            if collider1.intersect(leftVerticalLine: worldBoundRect.minX) {
                physicObjectBody.position = CGVector(worldBoundRect.minX + collider1.radius, physicObjectBody.position.y)
                physicObjectBody.velocity = CGVector(-physicObjectBody.velocity.x, physicObjectBody.velocity.y)
            }
            if collider1.intersect(rightVerticalLine: worldBoundRect.maxX) {
                physicObjectBody.position = CGVector(worldBoundRect.maxX - collider1.radius, physicObjectBody.position.y)
                physicObjectBody.velocity = CGVector(-physicObjectBody.velocity.x, physicObjectBody.velocity.y)
            }
            if collider1.intersect(topHorizontalLine: worldBoundRect.minY) {
                positions.append(physicObjectBody.position)
                physicObjectBody.position = CGVector(physicObjectBody.position.x, worldBoundRect.minY + collider1.radius)
                moving = false
                break
            }
            
            positions.append(physicObjectBody.position)
            physicObjectBody.position = physicObjectBody.position + physicObjectBody.velocity
        }

        return positions
    }
    
    public func setWorldBound(_ worldBoundRect: CGRect) {
        self.worldBound = true
        self.worldBoundRect = worldBoundRect
    }
}
