//
//  GameplayController.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit
import Foundation

class GameplayController: UIViewController {
    private var gameEngine: GameEngine?
    private var bubbleManager: BubbleManager?
    private var gridBubblesPosition: [[GridBubble]]?
    private var launcher: Launcher?
    private var cellWidth: CGFloat = GridSettings.cellWidth
    
    @IBOutlet private var scene: UIView!
    @IBOutlet private weak var cannon: UIImageView!
    @IBOutlet private weak var border: UIView!
    
    private let ERROR_GRID_BUBBLES_NOT_LOADED = "ERROR: gridBubblesAreNotLoaded"
    private let ERROR_BUBBLE_MANAGER_FAILED = "ERROR: Bubble Manager failed to initialised"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGesture()
        setUpEngineAndBubbleManagerAndGridBound()
        createLauncher()
    }
    
    private func setUpEngineAndBubbleManagerAndGridBound() {
        let newGameEngine = GameEngine(scene)
        newGameEngine.setWorldBound()
    
        guard let gridBubbles = gridBubblesPosition else {
            print(ERROR_GRID_BUBBLES_NOT_LOADED)
            return
        }
        guard let bubbleManager = BubbleManager(gridBubbles, newGameEngine) else {
            print(ERROR_BUBBLE_MANAGER_FAILED)
            return
        }
        gridBubblesPosition = nil
        self.bubbleManager = bubbleManager
        setUpGridLowerBound(bubbleManager)
        gameEngine = newGameEngine
    }
    
    private func setUpGesture() {
        let panGestureReg = UIPanGestureRecognizer(target: self, action: #selector((panGesture)))
        panGestureReg.minimumNumberOfTouches = 1
        panGestureReg.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGestureReg)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector((tapGesture))))
    }
    
    private func setUpGridLowerBound(_ bubbleManager: BubbleManager) {
        let oldFrame = border.layer.frame
        border.layer.frame = CGRect(x: oldFrame.minX, y: bubbleManager.getGridLowerBound(), width: oldFrame.width, height: oldFrame.height)
    }
    
    public func loadGridBubblesPosition(_ gridBubblesPosition: [[GridBubble]]) {
        self.gridBubblesPosition = gridBubblesPosition
    }
    
    private func createLauncher() {
        guard let bubbleManager = bubbleManager else {
            return
        }
        let launcher = Launcher(CGVector(UIScreen.main.bounds.size.width/2, UIScreen.main.bounds.size.height - cellWidth/2), bubbleManager)
        self.launcher = launcher
        gameEngine?.add(launcher)
    }

    // Fire bubble at on release
    func panGesture(gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended { 
            let position = gesture.location(in: view)
            launcher?.fireBubble(lookAt: CGVector.toVector(position))
        }
    }
    
    func tapGesture(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let position = gesture.location(in: view)
            launcher?.fireBubble(lookAt: CGVector.toVector(position))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}