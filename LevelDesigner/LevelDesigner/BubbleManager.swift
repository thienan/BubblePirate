//
//  BubbleManager.swift
//  GameEngine
//
//  Created by limte on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class BubbleManager: BubbleDelegate {
    enum GameplayMode {
        case ready
        case waiting
    }
    
    private let ROW_COUNT: Int
    private let COLUMN_COUNT_EVEN: Int
    private let COLUMN_COUNT_ODD: Int
    private let gameEngine: GameEngine
    private var bubbles: [[Bubble?]] = []
    private var gridCellPositions: [[CGVector]] = []
    private var cellWidth: CGFloat = GridSettings.cellWidth
    //private var spriteNames: [String] = ["bubble-blue", "bubble-green", "bubble-orange", "bubble-red", "bubble-indestructible", "bubble-lightning", "bubble-bomb", "bubble-star"]
    private var spriteNames: [String] = ["ball-blue", "ball-green", "ball-yellow", "ball-red", "ball-black", "ball-lightning", "bubble-bomb", "ball-star"]
    private var gridLowerBound: CGFloat = 0
    private var nextBubbleQueue = [Bubble]()
    private var offScreenPosition: CGVector = CGVector(-200, -200)
    private let MIN_BUBBLE_IN_QUEUE = 3
    private let MIN_BUBBLE_IN_GROUP = 3
    private let ERROR_CANT_FIND_INDEX_OF_BUBBLE = "UNEXPECTED BEHAVIOUR: cant find index of bubble"
    private let BUBBLE_FADE_OUT_SPEED = CGFloat(0.03)
    private let BUBBLE_ROOTED_FADE_OUT_SPEED = CGFloat(0.02)
    private let BUBBLE_FALLING_SPEED = CGFloat(0.4)
    private let NUM_OF_COLOR_BUBBLE = 4
    
    init?(_ gridBubbles: [[GridBubble]], _ gameEngine: GameEngine) {
        ROW_COUNT = GridSettings.ROW_COUNT
        COLUMN_COUNT_EVEN = GridSettings.COLUMN_COUNT_EVEN
        COLUMN_COUNT_ODD = GridSettings.COLUMN_COUNT_ODD
        
        self.gameEngine = gameEngine
        
        if !isValid(gridBubbles: gridBubbles) {
            return nil
        }

        initGrids(gridBubbles)
        calculateGridLowerBound()
        checkUnRootedBubble(animate: false)
        addBubbleToNextBubbleQueue()
    }
    
// ************************************ grid init Functions ***************************************//
    // check validity
    private func initGrids(_ gridBubbles: [[GridBubble]]) {
        for row in 0..<gridBubbles.count {
            bubbles.append([Bubble?]())
            gridCellPositions.append([CGVector]())
            
            for col in 0..<gridBubbles[row].count {
                let gridBubble = gridBubbles[row][col]
                let gridCellPos = CGVector.toVector(gridBubble.position)

                bubbles[row].append(nil)
                bubbles[row][col] = createBubble(gridBubble.color, gridCellPos)
                gridCellPositions[row].append(gridCellPos)
            }
        }
    }
    
    private func calculateGridLowerBound() {
        let lastRow = gridCellPositions.last
        guard let posOfLowestCell = lastRow?.first else {
            gridLowerBound = 0
            return
        }
        gridLowerBound = posOfLowestCell.y + cellWidth/2
    }
    
    private func isValid(gridBubbles: [[GridBubble]]) -> Bool {
        guard gridBubbles.count == ROW_COUNT else {
            return false
        }
        for row in 0..<ROW_COUNT {
            let colCount = getColCount(row)
            guard gridBubbles[row].count == colCount else {
                return false
            }
        }
        return true
    }
    
    
 // ************************************ Bubble Creation Functions ***************************************//
    private func createBubble(_ gridBubbleType: GridBubble.BubbleColor, _ position: CGVector) -> Bubble? {
        var spriteName: String
        var bubbleType: Bubble.BubbleType = Bubble.BubbleType.normal
        
        switch gridBubbleType {
        case .blue:
            spriteName = spriteNames[0]
        case .green:
            spriteName = spriteNames[1]
        case .orange:
            spriteName = spriteNames[2]
        case .red:
            spriteName = spriteNames[3]
        case .black:
            spriteName = spriteNames[4]
        case .lightning:
            spriteName = spriteNames[5]
            bubbleType = Bubble.BubbleType.lightning
        case .bomb:
            spriteName = spriteNames[6]
            bubbleType = Bubble.BubbleType.bomb
        case .star:
            spriteName = spriteNames[7]
            bubbleType = Bubble.BubbleType.star
        case .none:
            return nil
        }
        return createBubbleObject(position, spriteName, CGVector.zero, bubbleType)
    }
    
    private func createBubbleObject(_ pos: CGVector, _ spriteName: String, _ velocity: CGVector = CGVector.zero, _ bubbleType: Bubble.BubbleType = Bubble.BubbleType.normal) -> Bubble {
        let bubble = Bubble(CGVector(pos.x, pos.y))
        bubble.addSpriteComponent(spriteName, CGRect(x: -cellWidth/2, y: -cellWidth/2, width: cellWidth, height: cellWidth))
        bubble.addSphereColliderComponent(CGVector.zero, cellWidth/2)
        bubble.setVelocity(velocity)
        bubble.bubbleType = bubbleType
        bubble.delegate = self
        gameEngine.add(bubble)
        return bubble
    }
    
    public func createBubble(_ pos: CGVector, _ spriteName: String, _ velocity: CGVector = CGVector.zero) {
        _ = createBubbleObject(pos, spriteName, velocity)
    }

    private func createOffScreenBubble(_ spriteName: String) -> Bubble {
        let bubble = createBubbleObject(offScreenPosition, spriteName, CGVector.zero)
        bubble.sphereColliderComponent?.isActive = false
        bubble.spriteComponent?.isActive = false
        return bubble
    }
    
    public func fireBubble(_ pos: CGVector, _ velocity: CGVector) {
        let bubble = nextBubbleQueue.removeFirst()
        bubble.position = pos
        bubble.setVelocity(velocity)
        bubble.sphereColliderComponent?.isActive = true
        bubble.spriteComponent?.isActive = true
        
        // refil
        if nextBubbleQueue.count < MIN_BUBBLE_IN_QUEUE {
            addBubbleToNextBubbleQueue()
        }
    }
    
// ************************************** Bubble Animation Functions ******************************************//
    private func createAnimatedBubbleObject(_ bubble: Bubble, fadeOutSpeed: CGFloat, fallingSpeed: CGFloat = 0) {
        guard let spriteComponent = bubble.spriteComponent else {
            return
        }
        let bubble = AnimatedBubble(CGVector(bubble.position.x, bubble.position.y), fadeOutSpeed)
        bubble.addSpriteComponent(spriteComponent.spriteName, spriteComponent.rect)
        if fallingSpeed != 0 {
            bubble.setFalling(fallingSpeed: fallingSpeed)
        }
        gameEngine.add(bubble)
    }
    
    private func createBubblePopObject(_ bubble: Bubble) {
        
        guard let spriteComponent = bubble.spriteComponent else {
            return
        }
        let bubblePop = GameObject()
        bubblePop.position = CGVector(bubble.position.x, bubble.position.y)
        bubblePop.addAnimatedSpriteComponent("red-explode1", ["red-explode1", "red-explode2", "red-explode3"], spriteComponent.rect)
        gameEngine.add(bubblePop)
        
        guard let animatedSpriteComponent = bubblePop.spriteComponent as? AnimatedSpriteComponent else {
            return
        }
        animatedSpriteComponent.animationDuration = 0.3
    }
    
// ************************************** Queue Functions ******************************************//
    private func addBubbleToNextBubbleQueue() {
        if NUM_OF_COLOR_BUBBLE < 1 {
            return
        }
        var newArray: [Bubble] = []
        // create bubble off screen
        for i in 0..<NUM_OF_COLOR_BUBBLE {
            newArray.append(createOffScreenBubble(spriteNames[i]))
        }
        newArray = newArray.shuffled()
        
        var zPosition = CGFloat(newArray.count)
        for bubble in newArray {
            bubble.spriteComponent?.zPosition = zPosition
            zPosition -= 1
        }
        
        nextBubbleQueue.append(contentsOf: newArray)
    }
    
    public func setCurrentBubbleInQueue(position: CGVector) {
        guard let bubble = nextBubbleQueue.first else {
            return
        }
        bubble.spriteComponent?.isActive = true
        bubble.position = position
    }
    
    public func setNextBubbleInQueue(position: CGVector) {
        if nextBubbleQueue.count < 2 {
            return
        }
        let bubble = nextBubbleQueue[1]
        bubble.position = position
        bubble.sphereColliderComponent?.isActive = false
        bubble.spriteComponent?.isActive = true
    }
    
    public func moveCurrentBubbleInQueue(position: CGVector) {
        guard let bubble = nextBubbleQueue.first else {
            return
        }
        bubble.spriteComponent?.isActive = true
        bubble.moveLinearlyTo(position)
    }

    public func swapBubble() {
        if nextBubbleQueue.count < 2 {
            return
        }
        guard let firstBubble = nextBubbleQueue.first else {
            return
        }
        let secondBubble = nextBubbleQueue[1]
        
        firstBubble.moveLinearlyTo(secondBubble.position)
        secondBubble.moveLinearlyTo(firstBubble.position)
        nextBubbleQueue[0] = secondBubble
        nextBubbleQueue[1] = firstBubble
    }
    
// ************************************** Bubble Collision/Delegates Functions **************************************//
    public func onBubbleCollidedWithBubble(_ bubble: Bubble) {
        handleBubbleCollided(bubble)
    }
    
    public func onBubbleCollidedWithTopWall(_ bubble: Bubble) {
        handleBubbleCollided(bubble)
    }
    
    public func onBubbleCollidedWithBtmWall(_ bubble: Bubble) {
        removeBubbleFromGrid(bubble: bubble)
        destroyRootedBubble(bubble)
    }
    
    private func handleBubbleCollided(_ bubble: Bubble) {
        if isOutOfBound(bubble) {
            destroyMovingBubble(bubble)
            return
        }
        let pos_index = findClosestGridCellPositionAndIndex(bubble.position)
        let pos = pos_index.0
        let index = pos_index.1
        
        // add bubble to bubbles array
        bubbles[index.row][index.section] = bubble
        
        // snap the bubble to the grid cell position
        bubble.snapTo(pos)
    }

    public func onBubbleDoneSnapping(_ bubble: Bubble) {
        guard let indexPath = getBubbleIndex(bubble) else {
            print(ERROR_CANT_FIND_INDEX_OF_BUBBLE)
            return
        }
        tryToPopBubble(indexPath, bubble)
        activateNeighbourSpecialBubble(indexPath, bubble)
        checkUnRootedBubble(animate: true)
    }
    
// ************************************** Check Bubble Action Functions ******************************************//
    private func tryToPopBubble(_ indexPath: IndexPath, _ bubble: Bubble) {
        let visited: [IndexPath:Bool] = bfs(indexPath, bubble)
        let connectedSameColorBubble = getVisitedBubbles(visited)
        
        // if there are less than 3 bubble connected, return
        if connectedSameColorBubble.count < MIN_BUBBLE_IN_GROUP {
            return
        }
        for bubble in connectedSameColorBubble {
            removeBubbleFromGrid(bubble: bubble)
            destroyRootedBubble(bubble)
        }
        gameEngine.shake()
    }
    
    private func activateNeighbourSpecialBubble(_ indexPath: IndexPath, _ sourceBubble: Bubble) {
        let adjIndexPaths: [IndexPath] = findNeighbour(indexPath)
        for index in adjIndexPaths {
            activateStarBubble(index, sourceBubble)
        }
        for index in adjIndexPaths {
            activateBombAndLightning(index)
        }
    }
    
    private func checkUnRootedBubble(animate: Bool) {
        if ROW_COUNT <= 0 {
            return
        }
        var visited: [IndexPath:Bool] = [IndexPath:Bool]()
        
        guard let firstRowBubbles = bubbles.first else {
            return
        }
        // for all bubble at first row
        for col in 0..<firstRowBubbles.count {
            guard let bubble = firstRowBubbles[col] else {
                continue
            }
            visited = bfs(IndexPath(row: 0, section: col), bubble, false, visited)
        }
        removeUnrootedBubble(visited, animate)
    }
    
// ************************************** Special Bubble Functions ******************************************//
    private func activateBombAndLightning(_ index: IndexPath) {
        guard let specialBubble = bubbles[index.row][index.section] else {
            return
        }
        let specialBubbleType = specialBubble.bubbleType
        var adjIndexPaths: [IndexPath] = []

        switch specialBubbleType {
        case .bomb:
            adjIndexPaths = findNeighbour(index)
        case .lightning:
            adjIndexPaths = findRowNeighbour(index)
        default:
            return
        }
        
        removeBubbleFromGrid(indexPath: index)
        destroySpecialBubble(specialBubble)
        
        for adjIndex in adjIndexPaths {
            guard let bubble = bubbles[adjIndex.row][adjIndex.section] else {
                continue
            }
            if bubble.bubbleType == Bubble.BubbleType.bomb || bubble.bubbleType == Bubble.BubbleType.lightning {
                activateBombAndLightning(adjIndex)
            } else {
                removeBubbleFromGrid(indexPath: adjIndex)
                destroyRootedBubble(bubble)
            }
        }
        gameEngine.shake()
    }
    
    private func activateStarBubble(_ index: IndexPath, _ sourceBubble: Bubble) {
        guard let specialBubble = bubbles[index.row][index.section] else {
            return
        }
        guard specialBubble.bubbleType == Bubble.BubbleType.star else {
            return
        }
        removeBubbleFromGrid(indexPath: index)
        destroySpecialBubble(specialBubble)
        removeBubbleWithSameColor(sourceBubble)
        gameEngine.shake()
    }
    
// ************************************ Bubble Removal Functions ***************************************//
    private func destroySpecialBubble(_ bubble: Bubble) {
        createAnimatedBubbleObject(bubble, fadeOutSpeed: BUBBLE_FADE_OUT_SPEED)
        bubble.destroy()
    }
    
    private func destroyRootedBubble(_ bubble: Bubble) {
        //createAnimatedBubbleObject(bubble, fadeOutSpeed: BUBBLE_FADE_OUT_SPEED)
        createBubblePopObject(bubble)
        bubble.destroy()
    }
    
    private func destroyMovingBubble(_ bubble: Bubble) {
        createAnimatedBubbleObject(bubble, fadeOutSpeed: BUBBLE_FADE_OUT_SPEED)
        bubble.destroy()
    }
    
    private func destroyUnrootedBubble(_ bubble: Bubble) {
        createAnimatedBubbleObject(bubble, fadeOutSpeed: BUBBLE_ROOTED_FADE_OUT_SPEED, fallingSpeed: BUBBLE_FALLING_SPEED)
        bubble.destroy()
    }
    
    private func destroyFreshlyLoadedBubble(_ bubble: Bubble) {
        bubble.destroy()
    }
    
    private func removeUnrootedBubble(_ visited: [IndexPath:Bool], _ animate: Bool) {
        for row in 0..<bubbles.count {
            for col in 0..<bubbles[row].count {
                // if bubble is not visited
                if visited[IndexPath(row: row, section: col)] != nil {
                    continue
                }
                // if bubble is not nil
                guard let bubble = bubbles[row][col] else {
                    continue
                }
                // remove bubble
                removeBubbleFromGrid(indexPath: IndexPath(row: row, section: col))
                
                if animate {
                    destroyUnrootedBubble(bubble)
                } else {
                    destroyFreshlyLoadedBubble(bubble)
                }
                
            }
        }
    }
    
    private func removeBubbleWithSameColor(_ bubble: Bubble) {
        for row in 0..<bubbles.count {
            for col in 0..<bubbles[row].count {
                guard let bubbleInGrid = bubbles[row][col] else {
                    continue
                }
                if bubbleInGrid.isSameColor(bubble) {
                    removeBubbleFromGrid(indexPath: IndexPath(row: row, section: col))
                    destroyRootedBubble(bubbleInGrid)
                }
            }
        }
    }
    
// ************************************ Helper Functions ***************************************//
    private func getColCount(_ row: Int) -> Int {
        return (row % 2 == 0) ? COLUMN_COUNT_EVEN : COLUMN_COUNT_ODD
    }
    
    public func getGridLowerBound() -> CGFloat {
        return gridLowerBound
    }
    
    private func getBubbleIndex(_ bubble: Bubble) -> IndexPath? {
        for row in 0..<bubbles.count {
            for col in 0..<bubbles[row].count {
                guard let bubbleInGrid = bubbles[row][col] else {
                    continue
                }
                if bubbleInGrid == bubble {
                    return IndexPath(row: row, section: col)
                }
            }
        }
        return nil
    }
    
    private func removeBubbleFromGrid(indexPath: IndexPath) {
        bubbles[indexPath.row][indexPath.section] = nil
    }
    
    private func removeBubbleFromGrid(bubble: Bubble) {
        guard let indexPath = getBubbleIndex(bubble) else {
            return
        }
        removeBubbleFromGrid(indexPath: indexPath)
    }
    
    private func isOutOfBound(_ bubble: Bubble) -> Bool {
        if bubble.position.y > gridLowerBound {
            return true
        }
        return false
    }
    
// ************************************ Traversal Functions ***************************************//
    private func bfs(_ startIndexPath: IndexPath, _ startBubble: Bubble, _ checkSameColor: Bool = true, _ visitedDict: [IndexPath:Bool] = [IndexPath:Bool]()) -> [IndexPath:Bool] {
        var visited: [IndexPath:Bool] = visitedDict
        visited[startIndexPath] = true
        var queue = Queue<IndexPath>()
        queue.enqueue(startIndexPath)
        
        while !queue.isEmpty {
            guard let indexPath = queue.dequeue() else {
                break
            }
            let adjs = findNeighbour(indexPath)
            for adj in adjs {
                // if visited continue
                if visited[adj] != nil {
                    continue
                }
                // if nil continue
                guard let adjBubble = bubbles[adj.row][adj.section] else {
                    continue
                }
                // if not same color continue
                if checkSameColor && !adjBubble.isSameColor(startBubble) {
                    continue
                }
                visited[adj] = true
                queue.enqueue(adj)
            }
        }
        return visited
    }
    
    private func findRowNeighbour(_ indexPath: IndexPath) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        let colCount = getColCount(indexPath.row)

        var col = 0
        
        while col < colCount {
            if col == indexPath.section {
                col += 1
                continue
            }
            indexPaths.append(IndexPath(row: indexPath.row, section: col))
            col += 1
        }
        
        return indexPaths
    }
    
    private func findNeighbour(_ indexPath: IndexPath) -> [IndexPath] {
        let row = indexPath.row
        let col = indexPath.section
        
        // up down left right direction
        var indexPaths: [IndexPath] = []
        indexPaths.append(IndexPath(row: row-1, section: col))
        indexPaths.append(IndexPath(row: row+1, section: col))
        indexPaths.append(IndexPath(row: row, section: col-1))
        indexPaths.append(IndexPath(row: row, section: col+1))
        
        if indexPath.row % 2 == 0 {
            // north east
            indexPaths.append(IndexPath(row: row-1, section: col-1))
            // south east
            indexPaths.append(IndexPath(row: row+1, section: col-1))
        } else {
            // north west
            indexPaths.append(IndexPath(row: row-1, section: col+1))
            // south west
            indexPaths.append(IndexPath(row: row+1, section: col+1))
        }

        indexPaths = indexPaths.filter{($0.row >= 0) && ($0.row < ROW_COUNT)}
        indexPaths = indexPaths.filter{($0.section >= 0) && ($0.section < getColCount($0.row))}
        return indexPaths
    }
    
    private func getVisitedBubbles(_ visited: [IndexPath:Bool]) -> [Bubble] {
        var visitedBubbles: [Bubble] = [Bubble]()
        let indexPaths: [IndexPath] = Array(visited.keys)
        
        for indexPath in indexPaths {
            guard let bubble = bubbles[indexPath.row][indexPath.section] else {
                continue
            }
            visitedBubbles.append(bubble)
        }
        return visitedBubbles
    }
    
    private func findClosestGridCellPositionAndIndex(_ bubblePosition: CGVector) -> (CGVector, IndexPath) {
        var minDist = CGFloat.greatestFiniteMagnitude
        var closestPosition: CGVector = CGVector.zero
        var index = IndexPath(row: 0, section: 0)
        
        func checkMinDist(_ inRow: Int, _ inCol: Int) {
            let gridCellPosition = gridCellPositions[inRow][inCol]
            let dist = CGVector.distance(gridCellPosition - bubblePosition)
            if dist  < minDist {
                minDist = dist
                closestPosition = gridCellPosition
                index = IndexPath(row: inRow, section: inCol)
            }
        }
        for row in 0..<ROW_COUNT {
            let columnCount = getColCount(row)
            for col in 0..<columnCount {
                checkMinDist(row, col)
            }
        }
        return (closestPosition, index)
    }
}

// ************************************ Array utils Functions ***************************************//
extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else {
            return
        }
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else {
                continue
            }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
