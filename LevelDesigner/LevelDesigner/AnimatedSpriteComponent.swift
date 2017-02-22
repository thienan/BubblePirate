//
//  AnimatedSpriteComponent.swift
//  GameEngine
//
//  Created by limte on 18/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class AnimatedSpriteComponent: SpriteComponent {
    var destroyWhenFinish: Bool = true
    var autoPlay: Bool = true

    var animatedSpriteDelegate: AnimatedSpriteDelegate?
    
    var animationDuration: TimeInterval = 0.5
    var animationRepeatCount: Int = 1
    
    var animatedSpriteNames: [String]
    
    init(_ parent: GameObject, _ spriteName: String, _ animatedSpriteNames: [String], _ rect: CGRect, _ anchorPoint: CGVector = CGVector.zero) {
        self.animatedSpriteNames = animatedSpriteNames
        super.init(parent, spriteName, rect, anchorPoint)
    }
    
    @objc public func animationFinished() {
        if destroyWhenFinish {
            parent.destroy()
        }
    }
    
    public func playAnimation() {
        animatedSpriteDelegate?.play(self)
    }
}
