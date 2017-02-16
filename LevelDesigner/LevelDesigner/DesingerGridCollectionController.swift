//
//  DesingerGridCollectionController.swift
//  GameEngine
//
//  Created by limte on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class DesignerGridCollectionController: GridCollectionController {
    public enum DesignMode {
        case ADD
        case ERASE
        case IDLE
        case GAME_LOAD
    }
    private let IMAGE_BUBBLE_BLUE = "bubble-blue"
    private let IMAGE_BUBBLE_GREEN = "bubble-green"
    private let IMAGE_BUBBLE_ORANGE = "bubble-orange"
    private let IMAGE_BUBBLE_RED = "bubble-red"
    
    private let ALERT_LEVEL_NAMES_TITLE = "Level Names"
    private let ALERT_LEVEL_INVALID_NAME = "Invalid Level Name"
    private let ALERT_INDEX_OUT_OF_BOUND = "ERROR: INDEX OUT OF BOUND"
    private let ALERT_OK = "OK"
    private let ERROR_INDEX_OUT_OF_BOUND = "ERROR: INDEX OUT OF BOUND"
    
    private let BUTTON_BACKGROUND_ALPHA = 0.3
    private let BUTTON_BORDER_WIDTH = 1.0

    private var designMode = DesignMode.IDLE
    private var selectedBubbleColor = GridBubble.BubbleColor.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGestures()
    }
    
    private func initGestures() {
        collectionView?.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector((longPressGesture))))
        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector((tapGesture))))
        
        // This is required for touch interaction with the view
        let panGestureReg = UIPanGestureRecognizer(target: self, action: #selector((panGesture)))
        panGestureReg.minimumNumberOfTouches = 1
        panGestureReg.maximumNumberOfTouches = 1
        collectionView?.addGestureRecognizer(panGestureReg)
    }
    
    // set properties of each cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GRID_CELL_IDENTIFIER, for: indexPath) as? GridCollectionCell else {
            return GridCollectionCell()
        }
        cell.layer.cornerRadius = cell.layer.frame.width / 2
        cell.layer.borderWidth = CGFloat(1.0)
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.masksToBounds = true
        cell.layer.backgroundColor = UIColor.gray.withAlphaComponent(CGFloat(BUTTON_BACKGROUND_ALPHA)).cgColor
        
        guard let bubble = bubbleGridManager.getBubbleAt(indexRow: indexPath.section, indexCol: indexPath.row) else {
            return cell
        }
        guard bubble.color != GridBubble.BubbleColor.none else {
            cell.clearImage()
            return cell
        }
        guard let image = getImage(bubbleColor: bubble.color) else {
            return cell
        }
        cell.setImage(image: image)
        return cell
    }

    func longPressGesture(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let position = gesture.location(in: collectionView)
            guard let indexPath = collectionView?.indexPathForItem(at: position) else {
                return
            }
            onCellLongPressed(indexPath)
        }
    }
    
    func panGesture(gesture: UIPanGestureRecognizer) {
        let position = gesture.location(in: collectionView)
        guard let indexPath = collectionView?.indexPathForItem(at: position) else {
            return
        }
        onCellPanned(indexPath)
    }
    
    func tapGesture(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let position = gesture.location(in: collectionView)
            guard let indexPath = collectionView?.indexPathForItem(at: position) else {
                return
            }
            onCellTapped(indexPath)
        }
    }
    
    private func onCellTapped(_ indexPath: IndexPath) {
        if designMode == DesignMode.ADD {
            setBubbleColor(indexPath, selectedBubbleColor)
            self.collectionView?.reloadItems(at: [indexPath])
            
        } else if designMode == DesignMode.ERASE {
            setBubbleColor(indexPath, GridBubble.BubbleColor.none)
            self.collectionView?.reloadItems(at: [indexPath])
            
        } else if designMode == DesignMode.IDLE {
            cycleBubbleColor(indexPath)
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
    private func onCellLongPressed(_ indexPath: IndexPath) {
        setBubbleColor(indexPath, GridBubble.BubbleColor.none)
        self.collectionView?.reloadItems(at: [indexPath])
    }
    
    private func onCellPanned(_ indexPath: IndexPath) {
        if designMode == DesignMode.ADD {
            setBubbleColor(indexPath, selectedBubbleColor)
            self.collectionView?.reloadItems(at: [indexPath])
            
        } else if designMode == DesignMode.ERASE {
            setBubbleColor(indexPath, GridBubble.BubbleColor.none)
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
    private func setBubbleColor(_ indexPath: IndexPath, _ bubbleColor: GridBubble.BubbleColor) {
        do {
            try bubbleGridManager.setBubbleColor(indexRow: indexPath.section, indexCol: indexPath.row, bubbleColor: bubbleColor)
        } catch {
            print(ALERT_INDEX_OUT_OF_BOUND)
        }
    }
    
    private func cycleBubbleColor(_ indexPath: IndexPath) {
        do {
            try bubbleGridManager.cycleBubbleColor(indexRow: indexPath.section, indexCol: indexPath.row)
        } catch {
            print(ERROR_INDEX_OUT_OF_BOUND)
        }
    }
    
    public func getImage(bubbleColor: GridBubble.BubbleColor) -> UIImage? {
        switch bubbleColor {
        case GridBubble.BubbleColor.blue :
            return UIImage(named: IMAGE_BUBBLE_BLUE)
        case GridBubble.BubbleColor.green :
            return UIImage(named: IMAGE_BUBBLE_GREEN)
        case GridBubble.BubbleColor.red :
            return UIImage(named: IMAGE_BUBBLE_RED)
        case GridBubble.BubbleColor.orange :
            return UIImage(named: IMAGE_BUBBLE_ORANGE)
        case GridBubble.BubbleColor.none :
            return nil
        }
    }
    
    public func selectBubble(bubbleColor: GridBubble.BubbleColor) {
        designMode = DesignMode.ADD
        selectedBubbleColor = bubbleColor
    }
    
    public func setEraseMode() {
        designMode = DesignMode.ERASE
    }
    
    public func setIdleMode() {
        designMode = DesignMode.IDLE
    }
    
    public func setGameLoadMode() {
        designMode = DesignMode.GAME_LOAD
        print("load")
    }
    
    public func getDesignMode() -> DesignMode {
        return designMode
    }
    
    public func save(levelName: String) {
        guard storageManager.save(levelName: levelName, bubbles: bubbleGridManager.getBubbles()) else {
            createSaveFailedAlert()
            return
        }
    }
    
    private func createLoadAlert(_ levelNames: [String]) {
        let alert = UIAlertController(title: ALERT_LEVEL_NAMES_TITLE, message: nil, preferredStyle: .actionSheet)
        
        for levelName in levelNames {
            alert.addAction(UIAlertAction(title: levelName, style: .default, handler: {(action) in
                self.loadLevel(levelName: levelName)
            }))
        }
        
        alert.popoverPresentationController?.sourceView = collectionView
        self.present(alert, animated: true, completion: nil)
    }
    
    public func load() {
        createLoadAlert(storageManager.getLevelNames())
    }

    private func createSaveFailedAlert() {
        let alert = UIAlertController(title: ALERT_LEVEL_INVALID_NAME, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: ALERT_OK, style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
