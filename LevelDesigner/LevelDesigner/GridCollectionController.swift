//
//  GridCollectionController.swift
//  LevelDesigner
//
//  Created by limte on 2/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class GridCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let COLUMN_SPACING = 0
    private let ERROR_FAIL_TO_LOAD_LEVEL = "ERROR: FAIL TO LOAD LEVEL"
    private let ERROR_FAIL_TO_LOAD_BUBBLES = "ERROR: FAIL TO LOAD LEVEL"
    public let GRID_CELL_IDENTIFIER = "cell"
    private var cellWidth: CGFloat = GridSettings.cellWidth
    public let bubbleGridManager = GridBubbleManager()
    public let storageManager = StorageManager()
    private let ROW_OFFSET: CGFloat = -10/80
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true // for navigation bar hide
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return bubbleGridManager.ROW_COUNT
    }
    
    // set minimum spacing for section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(COLUMN_SPACING)
    }
    
    // set inset for section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section % 2 == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            let sectionVecticalOffset = ROW_OFFSET * cellWidth
            return UIEdgeInsets(top: sectionVecticalOffset, left: cellWidth/2, bottom: sectionVecticalOffset, right: cellWidth/2)
        }
    }
    
    // set number of items in section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getColCount(section)
    }
    
    // set cell width
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: GRID_CELL_IDENTIFIER, for: indexPath)
    }
        
    public func loadLevel(levelName: String) {
        loadLevelFromStorageToBubbleManager(levelName)
        self.collectionView?.reloadData()
    }
    
    public func levelNameExists(levelName: String) -> Bool {
        return storageManager.doesLevelExist(level: Level(levelName))
    }
    
    private func loadLevelFromStorageToBubbleManager(_ levelName: String) {
        guard let bubbles = storageManager.loadLevel(levelName: levelName) else {
            print(ERROR_FAIL_TO_LOAD_LEVEL)
            return
        }
        do {
            try bubbleGridManager.loadBubbles(bubbles: bubbles)
        } catch {
            print(ERROR_FAIL_TO_LOAD_BUBBLES)
        }
    }
    
    public func save(level: Level) {
        _ = storageManager.saveLevelStars(level: level)
    }
    
    public func getGridBubblesWithPosition(bubbles: [[GridBubble]]) -> [[GridBubble]] {
        for row in 0..<bubbleGridManager.ROW_COUNT {
            let columnCount = getColCount(row)
            for col in 0..<columnCount {
                let bubble = bubbles[row][col]
                guard let pos = collectionView?.cellForItem(at: IndexPath(row: col, section: row))?.layer.position else {
                    continue
                }
                bubble.position = pos
            }
        }
        return bubbles
    }
    
    public func getGridBubblesWithPosition() -> [[GridBubble]] {
        return getGridBubblesWithPosition(bubbles: bubbleGridManager.getBubbles())
    }
    
    public func getGridBubblesWithPosition(levelName: String) -> [[GridBubble]] {
        loadLevelFromStorageToBubbleManager(levelName)
        return getGridBubblesWithPosition(bubbles: bubbleGridManager.getBubbles())
    }
    
    public func resetGrid() {
        bubbleGridManager.createEmptyBubbleGrid()
        self.collectionView?.reloadData()
    }
    
    private func getColCount(_ row: Int) -> Int {
        return (row % 2 == 0) ? bubbleGridManager.COLUMN_COUNT_EVEN : bubbleGridManager.COLUMN_COUNT_ODD

    }
}
