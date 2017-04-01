//
//  Launcher.swift
//  GameEngine
//
//  Created by limte on 8/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit
import PhysicEngine

class Launcher: GameObject {
    private let bubbleManager: BubbleManager
    public let nextBubbleOffsetPos: CGVector = CGVector(100, 30)
    let speed = CGFloat(1500)
    private(set) var dir: CGVector = CGVector.zero
    private let UPWARD_DIRECTION = CGVector(0, -100)
    
    private let CANNON_SPRITE_Z_POSITION = CGFloat(100)
    private let CANNON_ANIMATION_DURATION = 0.2
    private let CANNON_WIDTH = 136
    private let CANNON_HEIGHT = 228
    private let CANNON_Y_OFFSET = 175
    let TO_DEGREE = 180/M_PI
    
    private let CANNON_SPRITE_1 = "cannon1"
    private let CANNON_SPRITE_2 = "cannon2"
    private let CANNON_SPRITE_3 = "cannon3"
    private let CANNON_SPRITE_4 = "cannon4"
    
    private let SOUND_SHOOT1 = "shoot1"
    private let SOUND_SHOOT2 = "shoot2"
    
    private let cannonAnchor = CGVector(0.5, 0.77)
    let angleOffset: CGFloat = 90
    let leftVector = CGVector(-1, 0)
    
    
    private var verticalPosLimit: CGFloat {
        return position.y - 20
    }
    
    init(_ position: CGVector, _ bubbleManager: BubbleManager) {
        self.bubbleManager = bubbleManager
        super.init()
        self.position = position
        addAnimatedSpriteComponent(CANNON_SPRITE_1, [CANNON_SPRITE_1, CANNON_SPRITE_2, CANNON_SPRITE_3, CANNON_SPRITE_4], CGRect(x: -CANNON_WIDTH/2, y: -CANNON_Y_OFFSET, width: CANNON_WIDTH, height: CANNON_HEIGHT), cannonAnchor)
        guard let animatedSpriteComponent = spriteComponent as? AnimatedSpriteComponent else {
            return
        }
        animatedSpriteComponent.autoPlay = false
        animatedSpriteComponent.destroyWhenFinish = false
        animatedSpriteComponent.animationDuration = CANNON_ANIMATION_DURATION
        animatedSpriteComponent.zPosition = CANNON_SPRITE_Z_POSITION
        
        addSphereColliderComponent(position, GridSettings.cellWidth)
        sphereColliderComponent?.isActive = false
        
        bubbleManager.setCurrentBubbleInQueue(position: position)
        bubbleManager.setNextBubbleInQueue(position: position + nextBubbleOffsetPos)
        
        lookAt(position + UPWARD_DIRECTION)
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
        SoundPlayer.playRandom(soundNames: [SOUND_SHOOT1, SOUND_SHOOT2])
    }
    
    public func lookAt(_ lookAtPosition: CGVector) {
        if !isValidFireAngle(lookAtPosition) {
            return
        }
        
        dir = getLookAtDir(lookAtPosition)
        let dot = CGVector.dot(leftVector, dir)
        rotation = CGFloat(Double(acos(dot)) * TO_DEGREE) - angleOffset
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
