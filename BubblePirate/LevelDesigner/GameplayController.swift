//
//  GameplayController.swift
//  GameEngine
//
//  Created by limte on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit
import Foundation
import PhysicEngine

class GameplayController: UIViewController, ScoreManagerDelegate {
    enum LoadMode {
        case gridBubbles
        case levelName
        case none
    }
    
    private var gameEngine: GameEngine?
    private var bubbleManager: BubbleManager?
    private var scoreManager: ScoreManager?
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private var scene: UIView!
    @IBOutlet private weak var border: UIView!
    @IBOutlet weak var settingMenu: UIView!
    @IBOutlet weak var blackBackground: UIImageView!
    @IBOutlet weak var gameOverMenu: UIView!
    @IBOutlet weak var gameOverBanner: UIImageView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    
    private var launcher: Launcher?
    private let launcherYOffSet = CGFloat(100)
    private var cellWidth: CGFloat = GridSettings.cellWidth
    
    private let ERROR_GRID_BUBBLES_NOT_LOADED = "ERROR: gridBubblesAreNotLoaded"
    private let ERROR_BUBBLE_MANAGER_FAILED = "ERROR: Bubble Manager failed to initialised"
    private let SEQ_GRID = "grid"
    private let UI_Z_Position = CGFloat(1000)
    private let WORLD_BOUND_Y_OFFSET = CGFloat(100)
    private let BORDER_Y_OFFSET = CGFloat(20)
    
    private var loadMode: LoadMode = LoadMode.none
    private var gridController: GridCollectionController?
    private var gridBubbles: [[GridBubble]]?
    private var levelName: String = ""
    
    private let MENU_ANIMATE_APPEAR_DURATION: TimeInterval = 1
    private let MENU_ANIMATE_DISAPPEAR_DURATION: TimeInterval = 0.3
    private let MENU_SPRINT_DAMPING: CGFloat = 0.6
    private let MENU_INITIAL_VELOCITY: CGFloat = 2
    
    private let STAR_INITIAL_TRANSFORM = CGAffineTransform(scaleX: 0, y: 0)
    private let STAR_FINAL_TRANSFORM = CGAffineTransform(scaleX: 1.3, y: 1.3)
    private let STAR_SPRINT_DAMPING: CGFloat = 0.4
    private let STAR_INITIAL_VELOCITY: CGFloat = 2
    private let STAR_1_DELAY: TimeInterval = 0.5
    private let STAR_ANIMATION_DURATION: TimeInterval = 0.6
    
    private let SOUND_STAR1 = "star-win1"
    private let SOUND_STAR2 = "star-win2"
    private let SOUND_STAR3 = "star-win3"
    private let SOUND_GAME_WON = "game-won"
    private let SOUND_GAME_LOST = "game-lost"
    
    private let IMAGE_WIN_BANNER = "win-banner"
    private let IMAGE_LOSE_BANNER = "lose-banner"
    private let IMAGE_CANNON_BACKGROUND = "cannon-background"
    
    private let winStar1 = UIImageView(image: UIImage(named: "star-win1"))
    private let winStar2 = UIImageView(image: UIImage(named: "star-win2"))
    private let winStar3 = UIImageView(image: UIImage(named: "star-win3"))
    
    private var isPaused = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGesture()
        settingMenu.center = CGPoint(x: -settingMenu.frame.width, y: UIScreen.main.bounds.size.height/2)
        gameOverMenu.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height + settingMenu.frame.height)
        blackBackground.isHidden = true
        blackBackground.layer.zPosition = UI_Z_Position
        settingMenu.layer.zPosition = UI_Z_Position
        gameOverMenu.layer.zPosition = UI_Z_Position
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
        
        
        switch loadMode {
        case .gridBubbles:
            guard let gridBubbles = gridBubbles else {
                print(ERROR_GRID_BUBBLES_NOT_LOADED)
                return
            }
            guard let gridBubblesFromGridController = gridController?.getGridBubblesWithPosition(bubbles: gridBubbles) else { return }
            gridBubblesWithPosition = gridBubblesFromGridController
            self.gridBubbles = nil

            
        case .levelName:
            guard let gridBubblesFromGridController = gridController?.getGridBubblesWithPosition(levelName: levelName) else { return }
            gridBubblesWithPosition = gridBubblesFromGridController
            
        case .none:
            guard let gridBubblesFromGridController = gridController?.getGridBubblesWithPosition() else { return }
            gridBubblesWithPosition = gridBubblesFromGridController
        }
        
        guard let bubbleManager = BubbleManager(gridBubblesWithPosition, newGameEngine) else {
            print(ERROR_BUBBLE_MANAGER_FAILED)
            return
        }
        
        self.bubbleManager = bubbleManager
        setUpGridLowerBound(bubbleManager)
        scoreManager = ScoreManager(bubbleManager)
        bubbleManager.delegate = scoreManager
        scoreManager?.delegate = self
        scoreManager?.checkStartGame()
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
        border.layer.frame = CGRect(x: oldFrame.minX, y: bubbleManager.getGridLowerBound() + BORDER_Y_OFFSET, width: oldFrame.width, height: oldFrame.height)
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
        guard let gameEngine = gameEngine else {
            return
        }
        
        let launcher = Launcher(CGVector(UIScreen.main.bounds.size.width/2, UIScreen.main.bounds.size.height - launcherYOffSet), bubbleManager)
        self.launcher = launcher
        gameEngine.add(launcher)
        
        createCannonBackground(launcher.position)
        
        let launcherRing = LauncherRing(launcher.position + launcher.nextBubbleOffsetPos)
        gameEngine.add(launcherRing)
        
        createCannonBackground(launcherRing.position)
        
        let pathManager = PathManager(launcher, gameEngine)
        gameEngine.add(pathManager)
    }
    
    private func createCannonBackground(_ position: CGVector) {
        let cannonBackground = GameObject()
        cannonBackground.position = position
        cannonBackground.addSpriteComponent(IMAGE_CANNON_BACKGROUND, CGRect(x: -cellWidth/2, y: -cellWidth/2, width: cellWidth, height: cellWidth))
        gameEngine?.add(cannonBackground)
    }

    // Fire bubble at on release
    public func panGesture(gesture: UIPanGestureRecognizer) {
        if isPaused { return }
        let position = gesture.location(in: view)
        launcher?.lookAt(CGVector.toVector(position))
        if gesture.state == .ended {
            launcher?.fireBubble(lookAtPosition: CGVector.toVector(position))
        }
    }
    
    public func tapGesture(gesture: UITapGestureRecognizer) {
        if isPaused { return }
        if gesture.state == .ended {
            let position = gesture.location(in: view)
            launcher?.fireBubble(lookAtPosition: CGVector.toVector(position))
            launcher?.tapped(CGVector.toVector(position))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEQ_GRID {
            gridController = segue.destination as? GridCollectionController
        } else {
            gameEngine?.turnOffEngine()
        }
    }
    
    @IBAction func onSettingButtonPressed(_ sender: Any) {
        if isPaused { return }
        isPaused = true
        UIView.animate(withDuration: MENU_ANIMATE_APPEAR_DURATION, delay: 0, usingSpringWithDamping: MENU_SPRINT_DAMPING, initialSpringVelocity: MENU_INITIAL_VELOCITY, options: .curveEaseInOut, animations: ({
            self.settingMenu.center.x = UIScreen.main.bounds.size.width/2
        }), completion: nil)
        blackBackground.isHidden = false
    }
    
    @IBAction func onResumeButtonPressed(_ sender: Any) {
        isPaused = false
        UIView.animate(withDuration: MENU_ANIMATE_DISAPPEAR_DURATION, delay: 0, options: .curveLinear, animations: ({
            self.settingMenu.center.x = -self.settingMenu.frame.width
        }), completion: nil)
        blackBackground.isHidden = true
    }
    
    private func gameOver() {
        if isPaused { return }
        isPaused = true
        bubbleManager?.isGameEnded = true
        UIView.animate(withDuration: MENU_ANIMATE_APPEAR_DURATION, delay: 0, usingSpringWithDamping: MENU_SPRINT_DAMPING, initialSpringVelocity: MENU_INITIAL_VELOCITY, options: .curveEaseInOut, animations: ({
            self.gameOverMenu.center.y = UIScreen.main.bounds.size.height/2
        }), completion: nil)
        blackBackground.isHidden = false
    }
    
    func gameWon() {
        if isPaused { return }
        gameOverBanner.image = UIImage(named: IMAGE_WIN_BANNER)
        SoundPlayer.play(SOUND_GAME_WON)
        gameOver()
        if loadMode == LoadMode.levelName {
            let level = Level(levelName)
            level.setFullStar()
            gridController?.save(level: level)
        }
        createWinStars()
    }

    func gameLost() {
        if isPaused { return }
        gameOverBanner.image = UIImage(named: IMAGE_LOSE_BANNER)
        SoundPlayer.play(SOUND_GAME_LOST)
        gameOver()
    }
    
    private func createWinStars() {
        winStar1.frame = star1.frame
        winStar2.frame = star2.frame
        winStar3.frame = star3.frame
        
        winStar1.center = star1.center
        winStar2.center = star2.center
        winStar3.center = star3.center
        
        winStar2.isHidden = true
        winStar3.isHidden = true

        winStar1.transform = STAR_INITIAL_TRANSFORM
        winStar2.transform = STAR_INITIAL_TRANSFORM
        winStar3.transform = STAR_INITIAL_TRANSFORM
        
        UIView.animate(withDuration: STAR_ANIMATION_DURATION, delay: STAR_1_DELAY, usingSpringWithDamping: STAR_SPRINT_DAMPING, initialSpringVelocity: STAR_INITIAL_VELOCITY, options: .curveEaseInOut, animations: ({
            
            self.winStar1.transform = self.STAR_FINAL_TRANSFORM
        }), completion: star1Complete)
        
        Timer.scheduledTimer(withTimeInterval: STAR_1_DELAY, repeats: false) { (timer) in
            SoundPlayer.play(self.SOUND_STAR1)
        }
        
        gameOverMenu.addSubview(winStar1)
        gameOverMenu.addSubview(winStar2)
        gameOverMenu.addSubview(winStar3)
    }
    
    private func star1Complete(_ completed: Bool) {
        winStar2.isHidden = false
        SoundPlayer.play(self.SOUND_STAR2)
        
        UIView.animate(withDuration: STAR_ANIMATION_DURATION, delay: 0, usingSpringWithDamping: STAR_SPRINT_DAMPING, initialSpringVelocity: STAR_INITIAL_VELOCITY, options: .curveEaseInOut, animations: ({
            self.winStar2.transform = self.STAR_FINAL_TRANSFORM
        }), completion: star2Complete)
    }
    
    private func star2Complete(_ completed: Bool) {
        winStar3.isHidden = false
        SoundPlayer.play(self.SOUND_STAR3)
        
        UIView.animate(withDuration: STAR_ANIMATION_DURATION, delay: 0, usingSpringWithDamping: STAR_SPRINT_DAMPING, initialSpringVelocity: STAR_INITIAL_VELOCITY, options: .curveEaseInOut, animations: ({
            self.winStar3.transform = self.STAR_FINAL_TRANSFORM
        }), completion: nil)
    }
}


