//
//  MainMenuViewController.swift
//  GameEngine
//
//  Created by limte on 19/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    private let GAME_MUSIC_VOLUME: Float = 0.1
    private static var isBackgroundMusicPlayed = false
    
    func playBackgroundMusic() {
        if !MainMenuViewController.isBackgroundMusicPlayed {
            SoundPlayer.playLoop("game_music", GAME_MUSIC_VOLUME)
            MainMenuViewController.isBackgroundMusicPlayed = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundMusic()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
