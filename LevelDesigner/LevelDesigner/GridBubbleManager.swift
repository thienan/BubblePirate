//
//  BubbleGridManager.swift
//  LevelDesigner
//
//  Created by limte on 2/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

public enum BubbleGridError: Error {
    case indexOutOfBound
}

class GridBubbleManager {
    let ROW_COUNT: Int
    let COLUMN_COUNT_EVEN: Int
    let COLUMN_COUNT_ODD: Int
    
    private var bubbleGrid: [[GridBubble]] = []
    
    init() {
        ROW_COUNT = GridSettings.ROW_COUNT
        COLUMN_COUNT_EVEN = GridSettings.COLUMN_COUNT_EVEN
        COLUMN_COUNT_ODD = GridSettings.COLUMN_COUNT_ODD
        createEmptyBubbleGrid()
    }

    public func createEmptyBubbleGrid() {
        bubbleGrid = []
        for row in 0..<ROW_COUNT {
            bubbleGrid.append([GridBubble]())
            let columnCount = getColCount(row)
            for _ in 0..<columnCount {
                bubbleGrid[row].append(GridBubble(color: GridBubble.BubbleColor.none))
            }
        }
    }

    public func setBubbleColor(indexRow: Int, indexCol: Int, bubbleColor: GridBubble.BubbleColor) throws {
        guard isValid(indexRow, indexCol) else {
            throw BubbleGridError.indexOutOfBound
        }
        
        let bubble = bubbleGrid[indexRow][indexCol]
        bubble.color = bubbleColor
    }
    
    public func getBubbleAt(indexRow: Int, indexCol: Int) -> GridBubble? {
        guard isValid(indexRow, indexCol) else {
            return nil
        }
        
        return bubbleGrid[indexRow][indexCol]
    }

    public func cycleBubbleColor(indexRow: Int, indexCol: Int) throws {
        guard isValid(indexRow, indexCol) else {
            throw BubbleGridError.indexOutOfBound
        }
        
        let bubble = bubbleGrid[indexRow][indexCol]
        bubble.cycleToNextColor()
    }

    public func getBubbles() -> [[GridBubble]] {
        return bubbleGrid
    }
    
    public func loadBubbles(bubbles: [[GridBubble]]) throws {
        guard isValid(bubbles: bubbles) else {
            throw BubbleGridError.indexOutOfBound
        }
        self.bubbleGrid = bubbles
    }
    
    private func isValid(_ indexRow: Int, _ indexCol: Int) -> Bool {
        guard indexRow < ROW_COUNT else {
            return false
        }
        
        let colCount = getColCount(indexRow)
        return indexCol < colCount
    }
    
    private func isValid(bubbles: [[GridBubble]]) -> Bool {
        guard bubbles.count == ROW_COUNT else {
            return false
        }

        for row in 0..<ROW_COUNT {
            let colCount = getColCount(row)
            guard bubbles[row].count == colCount else {
                return false
            }
        }
        return true
    }
    
    private func getColCount(_ row: Int) -> Int {
        return (row % 2 == 0) ? COLUMN_COUNT_EVEN : COLUMN_COUNT_ODD
    }
}
