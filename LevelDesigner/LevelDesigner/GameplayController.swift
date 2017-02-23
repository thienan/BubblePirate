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
    enum LoadMode {
        case gridBubbles
        case levelName
        case none
    }
    
    private var gameEngine: GameEngine?
    private var bubbleManager: BubbleManager?
    
    private var launcher: Launcher?
    private let launcherYOffSet = CGFloat(100)
    private var cellWidth: CGFloat = GridSettings.cellWidth
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private var scene: UIView!
    @IBOutlet private weak var border: UIView!
    
    private let ERROR_GRID_BUBBLES_NOT_LOADED = "ERROR: gridBubblesAreNotLoaded"
    private let ERROR_BUBBLE_MANAGER_FAILED = "ERROR: Bubble Manager failed to initialised"
    private let SEQ_GRID = "grid"
    
    private let WORLD_BOUND_Y_OFFSET = CGFloat(100)
    
    private var loadMode: LoadMode = LoadMode.none
    private var gridController: GridCollectionController?
    private var gridBubbles: [[GridBubble]]?
    private var levelName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGesture()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        navigationController?.navigationBar.isHidden = true // for navigation bar hide
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpEngineAndBubbleManagerAndGridBound()
        createLauncher()
    }
    
    private func setUpEngineAndBubbleManagerAndGridBound() {
        let newGameEngine = GameEngine(scene)
        newGameEngine.setWorldBound(CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height + WORLD_BOUND_Y_OFFSET))
        
        var gridBubblesWithPosition: [[GridBubble]] = []
        if loadMode == LoadMode.gridBubbles {
            guard let gridBubbles = gridBubbles else {
                print(ERROR_GRID_BUBBLES_NOT_LOADED)
                return
            }
            guard let gridBubblesFromGridController = gridController?.getGridBubblesWithPosition(bubbles: gridBubbles) else {
                return
            }
            gridBubblesWithPosition = gridBubblesFromGridController
            self.gridBubbles = nil
            
        } else if loadMode == LoadMode.levelName {
            //gridController?.loadLevel(levelName: levelName)
            guard let gridBubblesFromGridController = gridController?.getGridBubblesWithPosition(levelName: levelName) else {
                return
            }
            gridBubblesWithPosition = gridBubblesFromGridController

        } else if loadMode == LoadMode.none {
            guard let gridBubblesFromGridController = gridController?.getGridBubblesWithPosition() else {
                return
            }
            gridBubblesWithPosition = gridBubblesFromGridController
        }
        
        guard let bubbleManager = BubbleManager(gridBubblesWithPosition, newGameEngine) else {
            print(ERROR_BUBBLE_MANAGER_FAILED)
            return
        }
        
        self.bubbleManager = bubbleManager
        setUpGridLowerBound(bubbleManager)
        gameEngine = newGameEngine
        containerView.removeFromSuperview()
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

    public func playWithBubbles(_ gridBubbles: [[GridBubble]]) {
        loadMode = LoadMode.gridBubbles
        self.gridBubbles = gridBubbles
    }
    
    public func playWithLevelName(_ levelName: String) {
        loadMode = LoadMode.levelName
        self.levelName = levelName
    }
    
    private func createLauncher() {
        guard let bubbleManager = bubbleManager else {
            return
        }
        let launcher = Launcher(CGVector(UIScreen.main.bounds.size.width/2, UIScreen.main.bounds.size.height - launcherYOffSet), bubbleManager)
        self.launcher = launcher
        gameEngine?.add(launcher)
    }

    // Fire bubble at on release
    public func panGesture(gesture: UIPanGestureRecognizer) {
        let position = gesture.location(in: view)
        launcher?.lookAt(CGVector.toVector(position))
        if gesture.state == .ended {
            launcher?.fireBubble(lookAtPosition: CGVector.toVector(position))
            //scene.shake()
        }
    }
    
    public func tapGesture(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let position = gesture.location(in: view)
            launcher?.fireBubble(lookAtPosition: CGVector.toVector(position))
            launcher?.tapped(CGVector.toVector(position))
            //scene.shake2(count: 3, for: 0.3, withTranslation: 3)
            //scene.shake()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEQ_GRID {
            gridController = segue.destination as? GridCollectionController
        }
    }
}


