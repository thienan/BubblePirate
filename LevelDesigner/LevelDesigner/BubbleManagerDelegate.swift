//
//  BubbleManagerDelegate.swift
//  GameEngine
//
//  Created by limte on 24/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

protocol BubbleManagerDelegate {
    func bubbleDestroyed(_ bubble: Bubble)
    func bubbleSnapped(_ bubble: Bubble)
}
