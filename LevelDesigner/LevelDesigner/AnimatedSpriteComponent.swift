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
    var loop: Bool = false
    var destroyWhenFinish: Bool = true
    var autoPlay: Bool = true
    var frameSkip: Int = 0
    
    var horizontalImages: Int
    var verticalImages: Int
    
    var animatedSpriteDelegate: AnimatedSpriteDelegate?
    
    init(_ parent: GameObject, _ spriteName: String, _ rect: CGRect, _ horizontalImages: Int, _ verticalImages: Int, _ anchorPoint: CGVector = CGVector.zero) {
        self.horizontalImages = horizontalImages
        self.verticalImages = verticalImages
        super.init(parent, spriteName, rect, anchorPoint)
    }
    
    public func animationFinished() {
        if destroyWhenFinish {
            parent.destroy()
        } else {
            animatedSpriteDelegate?.setFrame(uniqueId, 0)
        }
    }
    
    public func playAnimation() {
        animatedSpriteDelegate?.play(uniqueId)
    }
}
