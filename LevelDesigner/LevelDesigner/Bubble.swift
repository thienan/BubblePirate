//
//  Bubble.swift
//  LevelDesigner
//
//  Created by limte on 1/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit
import PhysicEngine

class Bubble: GameObject {
    enum MoveState {
        case idle
        case move
        case snap
        case swap
    }

    enum BubbleType {
        case normal
        case bomb
        case lightning
        case star
    }

    public var moveState = MoveState.idle
    public var bubbleType = BubbleType.normal
    public var delegate: BubbleDelegate?
    
    private var snapToPos: CGVector = CGVector.init()
    private var snapRatio: CGFloat = 0
    private var snapSpeed: CGFloat = 10
    
    private var moveLinearlyToPos: CGVector = CGVector.init()
    private var moveLinearlyRatio: CGFloat = 0
    private var moveLinearlySpeed: CGFloat = 5
    
    init(_ position: CGVector) {
        super.init()
        self.position = position
    }
    
    public override func update(_ deltaTime: CGFloat) {
        switch moveState {
        case .idle:
            velocity = CGVector(0, 0)
            break
        case .move:
            break
            
        case .snap:
            snapRatio += deltaTime * snapSpeed
            position = CGVector.lerp(position, snapToPos, snapRatio)
            
            if CGVector.distanceSquare(position - snapToPos) < 0.01 {
                delegate?.onBubbleDoneSnapping(self)
                moveState = MoveState.idle
            }
            
        case .swap:
            moveLinearlyRatio += deltaTime * moveLinearlySpeed
            position = CGVector.lerp(position, moveLinearlyToPos, moveLinearlyRatio)
            
            if CGVector.distanceSquare(position - moveLinearlyToPos) < 0.01 {
                moveState = MoveState.idle
            }
        }
    }
    
    public func setVelocity(_ velocity: CGVector) {
        if velocity == CGVector(0, 0) {
            self.velocity = velocity
            moveState = MoveState.idle
        } else {
            moveState = MoveState.move
            self.velocity = velocity
        }
    }

    public override func onCollide(_ other: GameObject) {
        guard let other = other as? Bubble else {
            return
        }
        if moveState == MoveState.move && other.moveState == MoveState.idle {
            velocity = CGVector(0, 0)
            delegate?.onBubbleCollidedWithBubble(self)
        }
    }
    
    public override func onCollideWithLeftWorldBound() {
        flipXVelocity()
    }
    
    public override func onCollideWithRightWorldBound() {
        flipXVelocity()
    }
    
    public override func onCollideWithBtmWorldBound() {
        delegate?.onBubbleCollidedWithBtmWall(self)
    }
    
    public override func onCollideWithTopWorldBound() {
        if moveState == MoveState.move {
            velocity = CGVector(0, 0)
            delegate?.onBubbleCollidedWithTopWall(self)
        }
    }

    private func flipXVelocity() {
        velocity = CGVector(velocity.x * -1, velocity.y)
    }
    
    public func snapTo(_ position: CGVector) {
        snapToPos = position
        moveState = MoveState.snap
        snapRatio = 0
    }
    
    public func moveLinearlyTo(_ position: CGVector) {
        moveLinearlyToPos = position
        moveState = MoveState.swap
        moveLinearlyRatio = 0
    }
    
    public func isSameColor(_ other: Bubble) -> Bool {
        guard let sprite1 = spriteComponent else {
            return false
        }
        guard let sprite2 = other.spriteComponent else {
            return false
        }
        return sprite1.spriteName == sprite2.spriteName
    }
}
