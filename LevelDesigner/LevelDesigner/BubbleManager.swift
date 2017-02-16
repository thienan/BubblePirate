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
    private var gameplayMode = GameplayMode.ready
    private var spriteNames: [String] = ["bubble-blue", "bubble-green", "bubble-orange", "bubble-red", "bubble-indestructible", "bubble-lightning", "bubble-bomb", "bubble-star"]
    private var gridLowerBound: CGFloat = 0
    private var nextBubbleQueue = [Bubble]()
    private var offScreenPosition: CGVector = CGVector(-200, -200)
    private let MIN_BUBBLE_IN_QUEUE = 3
    private let MIN_BUBBLE_IN_GROUP = 3
    private let ERROR_CANT_FIND_INDEX_OF_BUBBLE = "UNEXPECTED BEHAVIOUR: cant find index of bubble"
    private let BUBBLE_FADE_OUT_SPEED = CGFloat(0.03)
    private let BUBBLE_ROOTED_FADE_OUT_SPEED = CGFloat(0.02)
    private let BUBBLE_FALLING_SPEED = CGFloat(0.4)
    
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
    
    // TODO CHECK ERROR
    private func addBubbleToNextBubbleQueue() {
        // create bubble off screen
        for i in 0..<4{
            nextBubbleQueue.append(createOffScreenBubble(spriteNames[i]))
        }
    }
    
    private func createBubble(_ bubbleType: GridBubble.BubbleColor, _ position: CGVector) -> Bubble? {
        var spriteName: String
        switch bubbleType {
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
        case .bomb:
            spriteName = spriteNames[6]
            let bubble = createBubbleObject(position, spriteName)
            bubble.bubbleType = Bubble.BubbleType.bomb
            return bubble
        case .star:
            spriteName = spriteNames[7]
        case .none:
            return nil
        }
        return createBubbleObject(position, spriteName)
    }
    
    private func createBubbleObject(_ pos: CGVector, _ spriteName: String, _ velocity: CGVector = CGVector.zero) -> Bubble {
        let bubble = Bubble(CGVector(pos.x, pos.y))
        bubble.addSpriteComponent(spriteName, CGRect(x: -cellWidth/2, y: -cellWidth/2, width: cellWidth, height: cellWidth))
        bubble.addSphereColliderComponent(CGVector.zero, cellWidth/2)
        bubble.setVelocity(velocity)
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
        if gameplayMode != GameplayMode.ready {
            return
        }
        gameplayMode = GameplayMode.waiting
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
    
    private func createAnimatedBubbleObject(_ bubble: Bubble, fadeOutSpeed: CGFloat, fallingSpeed: CGFloat = 0) {
        guard let spriteComponent = bubble.spriteComponent else {
            return
        }
        let bubble = AnimatedBubble(CGVector(bubble.position.x, bubble.position.y), fadeOutSpeed)
        bubble.addSpriteComponent(spriteComponent.spriteName, CGRect(x: -cellWidth/2, y: -cellWidth/2, width: cellWidth, height: cellWidth))
        if fallingSpeed != 0 {
            bubble.setFalling(fallingSpeed: fallingSpeed)
        }
        gameEngine.add(bubble)
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
    
    public func onBubbleCollidedWithBubble(_ bubble: Bubble) {
        handleBubbleCollided(bubble)
    }
    
    public func onBubbleCollidedWithTopWall(_ bubble: Bubble) {
        handleBubbleCollided(bubble)
    }

    public func onBubbleDoneSnapping(_ bubble: Bubble) {
        guard let indexPath = getBubbleIndex(bubble) else {
            print(ERROR_CANT_FIND_INDEX_OF_BUBBLE)
            return
        }
        let specialBubblesIndexPaths: [IndexPath] = findSpecialBubbleAtNeighbour(indexPath)
        print(specialBubblesIndexPaths)
        tryToPopBubble(indexPath, bubble)
        activateSpecialBubbles(specialBubblesIndexPaths)
        checkUnRootedBubble(animate: true)
        gameplayMode = GameplayMode.ready
    }
    
    public func onBubbleCollidedWithBombBubble(_ bombBubble: BombBubble) {
    
    }
    
    private func tryToPopBubble(_ indexPath: IndexPath, _ bubble: Bubble) {
        let visited: [IndexPath:Bool] = bfs(indexPath, bubble)
        let connectedSameColorBubble = getVisitedBubbles(visited)
        
        // if there are less than 3 bubble connected, return
        if connectedSameColorBubble.count < MIN_BUBBLE_IN_GROUP {
            return
        }
        for bubble in connectedSameColorBubble {
            removeBubbleFromGrid(bubble)
            destroyRootedBubble(bubble)
        }
    }
    
    private func activateSpecialBubbles(_ specialBubblesIndexPaths: [IndexPath]) {
        for index in specialBubblesIndexPaths {
            guard let bubble = bubbles[index.row][index.section] else {
                continue
            }
            
            switch bubble.bubbleType {
            case .bomb:
                print("bomb activated")
                print(index)
                activeBombBubble(index)
            case .lightning:
                break
            case .star:
                break
            case .normal:
                break
            }
        }
    }
    
    private func activeBombBubble(_ index: IndexPath) {
        guard let bombBubble = bubbles[index.row][index.section] else {
            return
        }
        
        let adjIndexPaths = findNeighbour(index)
        print("adj")
        print(adjIndexPaths)
        for adjIndex in adjIndexPaths {
            guard let bubble = bubbles[adjIndex.row][adjIndex.section] else {
                return
            }
            
            bubbles[adjIndex.row][adjIndex.section] = nil
            destroyRootedBubble(bubble)
        }
        
        bubbles[index.row][index.section] = nil
        destroyRootedBubble(bombBubble)
    }

    private func handleBubbleCollided(_ bubble: Bubble) {
        if isOutOfBound(bubble) {
            destroyMovingBubble(bubble)
            gameplayMode = GameplayMode.ready
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
    
    private func isOutOfBound(_ bubble: Bubble) -> Bool {
        if bubble.position.y > gridLowerBound {
            return true
        }
        return false
    }
    
    private func destroyRootedBubble(_ bubble: Bubble) {
        createAnimatedBubbleObject(bubble, fadeOutSpeed: BUBBLE_FADE_OUT_SPEED)
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
                bubbles[row][col] = nil
                
                if animate {
                    destroyUnrootedBubble(bubble)
                } else {
                    destroyFreshlyLoadedBubble(bubble)
                }
                
            }
        }
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
    
    private func removeBubbleFromGrid(_ bubble: Bubble) {
        guard let indexPath = getBubbleIndex(bubble) else {
            return
        }
        bubbles[indexPath.row][indexPath.section] = nil
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
    
    private func findSpecialBubbleAtNeighbour(_ indexPath: IndexPath) -> [IndexPath] {
        let indexPaths = findNeighbour(indexPath)
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
    
    private func getColCount(_ row: Int) -> Int {
        return (row % 2 == 0) ? COLUMN_COUNT_EVEN : COLUMN_COUNT_ODD
    }
    
    public func getGridLowerBound() -> CGFloat {
        return gridLowerBound
    }
    
    public func getGameplayMode() -> GameplayMode {
        return gameplayMode
    }
}
