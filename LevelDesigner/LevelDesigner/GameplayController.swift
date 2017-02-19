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
    
    private let WORLD_BOUND_Y_OFFSET = CGFloat(100)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGesture()
        setUpEngineAndBubbleManagerAndGridBound()
        createLauncher()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        navigationController?.navigationBar.isHidden = true // for navigation bar hide
    }
    
    private func setUpEngineAndBubbleManagerAndGridBound() {
        let newGameEngine = GameEngine(scene)
        newGameEngine.setWorldBound(CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height + WORLD_BOUND_Y_OFFSET))
    
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
        let position = gesture.location(in: view)
        launcher?.lookAt(CGVector.toVector(position))
        if gesture.state == .ended {
            launcher?.fireBubble(lookAtPosition: CGVector.toVector(position))
            scene.shake()
        }
    }
    
    func tapGesture(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let position = gesture.location(in: view)
            launcher?.fireBubble(lookAtPosition: CGVector.toVector(position))
            launcher?.tapped(CGVector.toVector(position))
            scene.shake2(count: 3, for: 0.3, withTranslation: 3)
            scene.shake()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.3
        //animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        animation.values = [-3.0, 0.0, 1.0, 3.0, 2.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
}

public extension UIView {
    
    func shake2(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.repeatCount = count ?? 2
        animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation ?? -5
        layer.add(animation, forKey: "shake")
    }    
}
