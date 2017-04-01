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

    public func checkStartGame() {
        checkWinCondition()
    }
    
    func bubbleDestroyed(_ bubble: Bubble) {
        checkWinCondition()
    }

    func bubbleSnapped(_ bubble: Bubble) {
        if bubbleManager.isLastRowFull() {
            delegate?.gameLost()
        }
    }
    
    private func checkWinCondition() {
        if bubbleManager.getBubbleCount() == 0 {
            delegate?.gameWon()
        }
    }
}
