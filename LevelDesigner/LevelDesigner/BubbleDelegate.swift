//
//  BubbleDelegate.swift
//  GameEngine
//
//  Created by limte on 10/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

protocol BubbleDelegate {
    func onBubbleCollidedWithBubble(_ bubble: Bubble)
    
    func onBubbleCollidedWithTopWall(_ bubble: Bubble)
    
    func onBubbleDoneSnapping(_ bubble: Bubble)
    
    func onBubbleCollidedWithBombBubble(_ bombBubble: BombBubble)
}
