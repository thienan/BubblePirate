//
//  BubbleManager.swift
//  GameEngine
//
//  Created by limte on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit
import PhysicEngine

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
    private let EMPTY_STRING = ""
    private var gridLowerBound: CGFloat = 0
    private var nextBubbleQueue = [Bubble]()
    private var offScreenPosition: CGVector = CGVector(-200, -200)
    private let MIN_BUBBLE_IN_QUEUE = 3
    private let MIN_BUBBLE_IN_GROUP = 3
    private let MIN_BUBBLE_IN_QUEUE_FOR_SWAPPING = 2
    private let ERROR_CANT_FIND_INDEX_OF_BUBBLE = "UNEXPECTED BEHAVIOUR: cant find index of bubble"
    private let MIDDLE_ANCHOR = CGVector(0.5, 0.5)
    
    private let BUBBLE_FADE_OUT_SPEED = CGFloat(0.03)
    private let BUBBLE_ROOTED_FADE_OUT_SPEED = CGFloat(0.02)
    private let BUBBLE_FALLING_SPEED = CGFloat(0.4)
    private let BUBBLE_ANIMATION_SPEED = 0.3
    
    private let IMAGE_BUBBLE_BLUE = "ball-blue"
    private let IMAGE_BUBBLE_GREEN = "ball-green"
    private let IMAGE_BUBBLE_PURPLE = "ball-purple"
    private let IMAGE_BUBBLE_RED = "ball-red"
    private let IMAGE_BUBBLE_BLACK = "ball-black"
    private let IMAGE_BUBBLE_LIGHTNING = "ball-lightning"
    private let IMAGE_BUBBLE_BOMB = "ball-bomb"
    private let IMAGE_BUBBLE_STAR = "ball-star"
    
    private let IMAGE_EXPLODE_BOMB = "bomb-explode"
    private let IMAGE_EXPLODE_LIGHTNING = "lightning-explode"
    private let IMAGE_EXPLODE_BLUE = "blue-explode"
    private let IMAGE_EXPLODE_GREEN = "green-explode"
    private let IMAGE_EXPLODE_PURPLE = "purple-explode"
    private let IMAGE_EXPLODE_RED = "red-explode"
    
    private let SOUNDS_COMBO = ["combo_01", "combo_02", "combo_03", "combo_04"]
    private let SOUND_EXPLOSION = "explosion"
    private let SOUND_LIGHTNING = "lightning"
    private let SOUND_STAR = "star"
    
    private let STRING_1 = "1"
    private let STRING_2 = "2"
    private let STRING_3 = "3"
    
    private var isLightningActivated = false
    private var isBombSoundPlayed = false
    private var isLightningSoundPlayed = false
    
    public var isGameEnded = false
    
    public var delegate: BubbleManagerDelegate?
    
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
            spriteName = IMAGE_BUBBLE_BLUE
        case .green:
            spriteName = IMAGE_BUBBLE_GREEN
        case .purple:
            spriteName = IMAGE_BUBBLE_PURPLE
        case .red:
            spriteName = IMAGE_BUBBLE_RED
        case .black:
            spriteName = IMAGE_BUBBLE_BLACK
        case .lightning:
            spriteName = IMAGE_BUBBLE_LIGHTNING
            bubbleType = Bubble.BubbleType.lightning
        case .bomb:
            spriteName = IMAGE_BUBBLE_BOMB
            bubbleType = Bubble.BubbleType.bomb
        case .star:
            spriteName = IMAGE_BUBBLE_STAR
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
    
    private func createColourBubblePopObject(_ bubble: Bubble) {
        guard let spriteComponent = bubble.spriteComponent else {
            return
        }
        var spriteName = EMPTY_STRING
        switch spriteComponent.spriteName {
        case IMAGE_BUBBLE_BLUE:
            spriteName = IMAGE_EXPLODE_BLUE
            
        case IMAGE_BUBBLE_GREEN:
            spriteName = IMAGE_EXPLODE_GREEN
            
        case IMAGE_BUBBLE_PURPLE:
            spriteName = IMAGE_EXPLODE_PURPLE
            
        case IMAGE_BUBBLE_RED:
            spriteName = IMAGE_EXPLODE_RED
        
        default:
            return
        }
        createBubblePopObject(bubble, spriteName)
    }
    
    private func createBubblePopObject(_ bubble: Bubble, _ spriteName: String) {
        createBubblePopObject(bubble, spriteName, bubble.position)
    }
    
    private func createBubblePopObject(_ bubble: Bubble, _ spriteName: String, _ position: CGVector) {
        guard let spriteComponent = bubble.spriteComponent else {
            return
        }
        
        let sprite1 = spriteName + STRING_1
        let sprite2 = spriteName + STRING_2
        let sprite3 = spriteName + STRING_3
        
        let bubblePop = GameObject()
        bubblePop.position = CGVector(position.x, position.y)
        bubblePop.addAnimatedSpriteComponent(EMPTY_STRING, [sprite1, sprite2, sprite3], spriteComponent.rect, MIDDLE_ANCHOR)
        bubblePop.rotation = CGFloat(arc4random_uniform(360))
        gameEngine.add(bubblePop)
        
        guard let animatedSpriteComponent = bubblePop.spriteComponent as? AnimatedSpriteComponent else {
            return
        }
        animatedSpriteComponent.animationDuration = BUBBLE_ANIMATION_SPEED
    }
    
// ************************************** Queue Functions ******************************************//
    private func addBubbleToNextBubbleQueue() {
        let colourBubbleSpriteNames = [IMAGE_BUBBLE_BLUE, IMAGE_BUBBLE_GREEN, IMAGE_BUBBLE_PURPLE, IMAGE_BUBBLE_RED]
        var newArray: [Bubble] = []
        // create bubble off screen
        for spriteName in colourBubbleSpriteNames {
            newArray.append(createOffScreenBubble(spriteName))
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
        if nextBubbleQueue.count < MIN_BUBBLE_IN_QUEUE_FOR_SWAPPING {
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
        if nextBubbleQueue.count < MIN_BUBBLE_IN_QUEUE_FOR_SWAPPING {
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
        if isOutOfBound(bubble) || isGameEnded {
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
        delegate?.bubbleSnapped(bubble)
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
        SoundPlayer.playRandom(soundNames: SOUNDS_COMBO)
        gameEngine.shake()
    }
    
    private func activateNeighbourSpecialBubble(_ indexPath: IndexPath, _ sourceBubble: Bubble) {
        let adjIndexPaths: [IndexPath] = findNeighbour(indexPath)
        for index in adjIndexPaths {
            activateStarBubble(index, sourceBubble)
        }
        
        resetBombAndLightningSound()
        resetLightningBubble()
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
        var isBomb = true
        
        switch specialBubbleType {
        case .bomb:
            isBomb = true
            adjIndexPaths = findNeighbour(index)
            playBombSound()
            removeBubbleFromGrid(indexPath: index)
            destroyBubbleWithBomb(specialBubble)
        case .lightning:
            isBomb = false
            adjIndexPaths = findRowNeighbour(index)
            playLightingSound()
            removeBubbleFromGrid(indexPath: index)
            activateLightningEffect(index.row, specialBubble)
        default:
            return
        }
        
        for adjIndex in adjIndexPaths {
            guard let bubble = bubbles[adjIndex.row][adjIndex.section] else {
                continue
            }
            if bubble.bubbleType == Bubble.BubbleType.bomb || bubble.bubbleType == Bubble.BubbleType.lightning {
                activateBombAndLightning(adjIndex)
            } else {
                removeBubbleFromGrid(indexPath: adjIndex)
                isBomb ? destroyBubbleWithBomb(bubble) : destroyBubble(bubble)
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
        destroyStarBubble(specialBubble)
        removeBubbleWithSameColor(sourceBubble)
        
        SoundPlayer.play(SOUND_STAR)
        gameEngine.shake()
    }
    
    private func resetLightningBubble() {
        isLightningActivated = false
    }

    
// ************************************ Bubble Removal Functions ***************************************//
    private func destroyStarBubble(_ bubble: Bubble) {
        createAnimatedBubbleObject(bubble, fadeOutSpeed: BUBBLE_FADE_OUT_SPEED)
        bubble.destroy()
        delegate?.bubbleDestroyed(bubble)
    }
    
    private func destroyBubbleWithBomb(_ bubble: Bubble) {
        createBubblePopObject(bubble, IMAGE_EXPLODE_BOMB)
        bubble.destroy()
        delegate?.bubbleDestroyed(bubble)
    }
    
    private func destroyRootedBubble(_ bubble: Bubble) {
        createColourBubblePopObject(bubble)
        bubble.destroy()
        delegate?.bubbleDestroyed(bubble)
    }
    
    private func destroyMovingBubble(_ bubble: Bubble) {
        createAnimatedBubbleObject(bubble, fadeOutSpeed: BUBBLE_FADE_OUT_SPEED)
        bubble.destroy()
        delegate?.bubbleDestroyed(bubble)
    }
    
    private func destroyUnrootedBubble(_ bubble: Bubble) {
        createAnimatedBubbleObject(bubble, fadeOutSpeed: BUBBLE_ROOTED_FADE_OUT_SPEED, fallingSpeed: BUBBLE_FALLING_SPEED)
        bubble.destroy()
        delegate?.bubbleDestroyed(bubble)
    }
    
    private func destroyFreshlyLoadedBubble(_ bubble: Bubble) {
        bubble.destroy()
        delegate?.bubbleDestroyed(bubble)
    }
    
    private func destroyBubble(_ bubble: Bubble) {
        bubble.destroy()
        delegate?.bubbleDestroyed(bubble)
    }
    
    private func activateLightningEffect(_ row: Int, _ bubble: Bubble) {
        
        if !isLightningActivated {
            isLightningActivated = true
            
            for col in 0..<gridCellPositions[row].count {
                createBubblePopObject(bubble, IMAGE_EXPLODE_LIGHTNING, gridCellPositions[row][col])
                
                if col > 0 {
                    let midPoint: CGVector = (gridCellPositions[row][col-1] + gridCellPositions[row][col]) / 2
                    createBubblePopObject(bubble, IMAGE_EXPLODE_LIGHTNING, midPoint)
                }
            }
        }
        bubble.destroy()
        delegate?.bubbleDestroyed(bubble)
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
                delegate?.bubbleDestroyed(bubble)
                
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
    
    public func getBubbleCount() -> Int {
        var count = 0
        for row in 0..<bubbles.count {
            for col in 0..<bubbles[row].count {
                guard bubbles[row][col] != nil else {
                    continue
                }
                count += 1
            }
        }
        return count
    }
    
    public func isLastRowFull() -> Bool {
        let lastIndex = ROW_COUNT-1
        var colCount = getColCount(lastIndex)
        for col in 0..<bubbles[lastIndex].count {
            guard bubbles[lastIndex][col] != nil else {
                continue
            }
            colCount -= 1
        }
        return colCount == 0
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
    
// ************************************ Sound Functions ***************************************//
    private func playBombSound() {
        if !isBombSoundPlayed {
            SoundPlayer.play(SOUND_EXPLOSION)
            isBombSoundPlayed = true
        }
    }
    
    private func playLightingSound() {
        if !isLightningSoundPlayed {
            SoundPlayer.play(SOUND_LIGHTNING)
            isLightningSoundPlayed = true
        }
    }
    
    private func resetBombAndLightningSound() {
        isBombSoundPlayed = false
        isLightningSoundPlayed = false
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
