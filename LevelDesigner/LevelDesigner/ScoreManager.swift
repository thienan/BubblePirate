//
//  ScoreManager.swift
//  GameEngine
//
//  Created by limte on 23/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

class ScoreManager: BubbleManagerDelegate {
    let bubbleManager: BubbleManager
    var delegate: ScoreManagerDelegate?
    
    init(_ bubbleManager: BubbleManager) {
        self.bubbleManager = bubbleManager
    }
    
    func bubbleDestroyed(_ bubble: Bubble) {
        if bubbleManager.getBubbleCount() == 0 {
            delegate?.gameWon()
        }
    }

    func bubbleSnapped(_ bubble: Bubble) {
        if bubbleManager.isLastRowFull() {
            delegate?.gameLost()
        }
    }
}
