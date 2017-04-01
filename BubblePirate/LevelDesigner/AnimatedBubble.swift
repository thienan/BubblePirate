//
//  AnimatedBubble.swift
//  GameEngine
//
//  Created by limte on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit
import PhysicEngine

class AnimatedBubble: GameObject {
    var fadeOutSpeed: CGFloat
    var isFalling: Bool = false
    var fallingSpeed: CGFloat = 0
    
    init(_ position: CGVector, _ fadeOutSpeed: CGFloat) {
        self.fadeOutSpeed = fadeOutSpeed
        super.init()
        self.position = position
    }
    
    public func setFalling(fallingSpeed: CGFloat) {
        isFalling = true
        self.fallingSpeed = fallingSpeed
    }

    public override func update(_ deltaTime: CGFloat) {
        guard let spriteComponent = spriteComponent else {
            return
        }
        
        spriteComponent.alpha -= fadeOutSpeed
        
        if spriteComponent.alpha <= CGFloat(0) {
            destroy()
        }
        
        if isFalling {
            position = position + CGVector(0, fallingSpeed)
        }
    }
}
