//
//  PreLoader.swift
//  GameEngine
//
//  Created by limte on 26/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

class PreLoader {
    static let sharedInstance: PreLoader = {
        let instance = PreLoader()
        return instance
    }()
    
    let storageManager = StorageManager()
    
    let LEVEL_NAME_1 = "Lonely"
    let LEVEL_NAME_2 = "Effortless"
    let LEVEL_NAME_3 = "Point Blank"
    
    private init() {
        createLevel1()
        createLevel2()
        createLevel3()
    }
    
    private func createLevel1() {
        let bubbleManager = GridBubbleManager()
        try? bubbleManager.setBubbleColor(indexRow: 0, indexCol: GridSettings.COLUMN_COUNT_EVEN/2, bubbleColor: GridBubble.BubbleColor.blue)
        let level = Level(LEVEL_NAME_1)
        _ = storageManager.save(level: level, bubbles: bubbleManager.getBubbles())
    }

    private func createLevel2() {
        let bubbleManager = GridBubbleManager()
        for col in 0..<GridSettings.COLUMN_COUNT_EVEN {
            try? bubbleManager.setBubbleColor(indexRow: 0, indexCol: col, bubbleColor: GridBubble.BubbleColor.red)
        }
        let level = Level(LEVEL_NAME_2)
        _ = storageManager.save(level: level, bubbles: bubbleManager.getBubbles())
    }
    
    private func createLevel3() {
        let bubbleManager = GridBubbleManager()
        for row in 0..<(GridSettings.ROW_COUNT-1) {
            for col in 0..<GridSettings.COLUMN_COUNT_EVEN {
                try? bubbleManager.setBubbleColor(indexRow: row, indexCol: col, bubbleColor: GridBubble.BubbleColor.bomb)
            }
        }
        let level = Level(LEVEL_NAME_3)
        _ = storageManager.save(level: level, bubbles: bubbleManager.getBubbles())
    }
}
