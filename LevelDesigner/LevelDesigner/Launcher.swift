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
    private let nextBubbleOffsetPos: CGVector = CGVector(100, 50)
    let speed = CGFloat(1500)
    
    private var verticalPosLimit: CGFloat {
        return position.y - 20
    }
    
    init(_ position: CGVector, _ bubbleManager: BubbleManager) {
        self.bubbleManager = bubbleManager
        super.init()
        self.position = position
    }
    
    public override func update(_ deltaTime: CGFloat) {
        if bubbleManager.getGameplayMode() == BubbleManager.GameplayMode.ready {
            bubbleManager.setCurrentBubbleInQueue(position: position)
            bubbleManager.setNextBubbleInQueue(position: position + nextBubbleOffsetPos)
        }
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
    
    public func fireBubble(lookAt: CGVector) {
        if !isValidFireAngle(lookAt) {
            return
        }
        
        let dir = getLookAtDir(lookAt)
        bubbleManager.fireBubble(position, dir * speed)
    }
    
    // prevent from shooting toward the btm of the screen
    private func isValidFireAngle(_ lookAt: CGVector) -> Bool {
        if lookAt.y > verticalPosLimit {
            return false
        }
        return true
    }
}
