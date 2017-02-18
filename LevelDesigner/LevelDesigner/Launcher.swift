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
    var dir: CGVector = CGVector.zero
    
    private var verticalPosLimit: CGFloat {
        return position.y - 20
    }
    
    init(_ position: CGVector, _ bubbleManager: BubbleManager) {
        self.bubbleManager = bubbleManager
        super.init()
        self.position = position
        // magic number
        addSpriteComponent("background", CGRect(x: -30/2, y: -100, width: 30, height: 100), CGVector(0.5, 1))
    }
    
    public override func update(_ deltaTime: CGFloat) {
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
    }
    
    public func lookAt(_ lookAtPosition: CGVector) {
        if !isValidFireAngle(lookAtPosition) {
            return
        }
        
        dir = getLookAtDir(lookAtPosition)
        let dot = CGVector.dot(CGVector(-1, 0), dir)
        rotation = CGFloat(Double(acos(dot)) * 180/M_PI) - 90
    }
    
    // prevent from shooting toward the btm of the screen
    private func isValidFireAngle(_ lookAt: CGVector) -> Bool {
        if lookAt.y > verticalPosLimit {
            return false
        }
        return true
    }
}
