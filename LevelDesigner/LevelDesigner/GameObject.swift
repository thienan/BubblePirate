//
//  GameObject.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit
import PhysicEngine

class GameObject: Equatable, PhysicObject {
    private static var idCount = 0
    public var position: CGVector
    public var rotation: CGFloat
    let uniqueId: Int
    private(set) var isWaitingToBeDestroyed = false
    public var velocity: CGVector
    
    private(set) var sphereColliderComponent: SphereColliderComponent?
    private(set) var spriteComponent: SpriteComponent?

    init() {
        position = CGVector(0, 0)
        velocity = CGVector(0, 0)
        rotation = 0

        uniqueId = GameObject.idCount
        GameObject.idCount += 1
    }

    public func update(_ deltaTime: CGFloat) {
    }

    public func addSpriteComponent(_ spriteName: String, _ rect: CGRect, _ anchorPoint: CGVector = CGVector.zero) {
        spriteComponent = SpriteComponent(self, spriteName, rect, anchorPoint)
    }
    
    public func addAnimatedSpriteComponent(_ spriteName: String, _ animatedSpriteNames: [String], _ rect: CGRect, _ anchorPoint: CGVector = CGVector.zero) {
        spriteComponent = AnimatedSpriteComponent(self, spriteName, animatedSpriteNames, rect, anchorPoint)
    }
    
    public func addSphereColliderComponent(_ centre: CGVector, _ radius: CGFloat) {
        sphereColliderComponent = SphereColliderComponent(self, centre, radius)
    }
    
    public func getSpriteComponent() -> SpriteComponent? {
        if spriteComponent?.isActive == true {
            return spriteComponent
        } else {
            return nil
        }
    }
    
    public func getSphereColliderComponent() -> SphereColliderComponent? {
        if sphereColliderComponent?.isActive == true {
            return sphereColliderComponent
        } else {
            return nil
        }
    }
    
    public func getSphereCollider() -> SphereCollider? {
        if sphereColliderComponent?.isActive == true {
            return sphereColliderComponent
        } else {
            return nil
        }
    }
    
    public func onCollide(_ other: GameObject) {
    }
    
    public func onCollide(_ other: PhysicObject) {
        guard let otherGameObject = other as? GameObject else {
            return
        }
        onCollide(otherGameObject)
    }
    
    public func onCollideWithLeftWorldBound() {}
    
    public func onCollideWithRightWorldBound() {}

    public func onCollideWithTopWorldBound() {}
    
    public func onCollideWithBtmWorldBound() {}

    // wating for game engine to destroy this game object
    public func destroy() {
        isWaitingToBeDestroyed = true
    }
    
    // called by game engine when this game object is about to be destroyed
    public func onDestroyed() {}
    
    public func isAlive() -> Bool {
        return !isWaitingToBeDestroyed
    }
    
    static func == (lhs: GameObject, rhs: GameObject) -> Bool {
        return lhs.uniqueId == rhs.uniqueId
    }
    
    public func isEqual(_ other: PhysicObject) -> Bool {
        if self.uniqueId == other.uniqueId {
            return true
        }
        return false
    }
}
