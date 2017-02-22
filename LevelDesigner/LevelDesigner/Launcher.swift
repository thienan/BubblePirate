//
//  Launcher.swift
//  GameEngine
//
//  Created by limte on 8/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class Launcher: GameObject {
    private let bubbleManager: BubbleManager
    private let nextBubbleOffsetPos: CGVector = CGVector(100, 30)
    let speed = CGFloat(1500)
    private var dir: CGVector = CGVector.zero
    private let spriteName = "cannon2"
    
    private var verticalPosLimit: CGFloat {
        return position.y - 20
    }
    
    init(_ position: CGVector, _ bubbleManager: BubbleManager) {
        self.bubbleManager = bubbleManager
        super.init()
        self.position = position
        // magic number
        //addSpriteComponent(spriteName, CGRect(x: -112/2, y: -100, width: 112, height: 144), CGVector(0.5, 0.7))

        addAnimatedSpriteComponent("cannon-shoot-2", CGRect(x: -112/2, y: -144, width: 112, height: 456), 4, 1, CGVector(0.5, 0.7))
        guard let animatedSpriteComponent = spriteComponent as? AnimatedSpriteComponent else {
            return
        }
        animatedSpriteComponent.frameSkip = 4
        animatedSpriteComponent.autoPlay = false
        animatedSpriteComponent.destroyWhenFinish = false
        //animatedSpriteComponent.zPosition = 100
        
        addSphereColliderComponent(position, 32)
        sphereColliderComponent?.isActive = false
        bubbleManager.setCurrentBubbleInQueue(position: position)
        bubbleManager.setNextBubbleInQueue(position: position + nextBubbleOffsetPos)
        
    }

    public func getLookAtDir(_ lookAtPoint: CGVector) -> CGVector {
        return CGVector.normalize(lookAtPoint - position)
    }
    
    public func getLaunchPosition() -> CGVector {
        return position
    }

    public func getLaunchPositionAtTip() -> CGVector {
        guard let sc = spriteComponent else {
            return CGVector.zero
        }
        return position + CGVector(0, -sc.rect.height)
    }
    
    public func fireBubble(lookAtPosition: CGVector) {
        if !isValidFireAngle(lookAtPosition) {
            return
        }
        lookAt(lookAtPosition)
        bubbleManager.fireBubble(position, dir * speed)
        
        bubbleManager.moveCurrentBubbleInQueue(position: position)
        bubbleManager.setNextBubbleInQueue(position: position + nextBubbleOffsetPos)
        
        guard let animatedSpriteComponent = spriteComponent as? AnimatedSpriteComponent else {
            return
        }
        animatedSpriteComponent.playAnimation()
    }
    
    public func lookAt(_ lookAtPosition: CGVector) {
        if !isValidFireAngle(lookAtPosition) {
            return
        }
        
        dir = getLookAtDir(lookAtPosition)
        let dot = CGVector.dot(CGVector(-1, 0), dir)
        rotation = CGFloat(Double(acos(dot)) * 180/M_PI) - 90
    }
    
    public func tapped(_ position: CGVector) {
        guard let sphereColliderComponent = sphereColliderComponent else {
            return
        }
        if sphereColliderComponent.contains(point: position) {
            bubbleManager.swapBubble()
        }
    }
    
    // prevent from shooting toward the btm of the screen
    private func isValidFireAngle(_ lookAt: CGVector) -> Bool {
        if lookAt.y > verticalPosLimit {
            return false
        }
        return true
    }
}
