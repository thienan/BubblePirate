//
//  SoundPlayer.swift
//  GameEngine
//
//  Created by limte on 23/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import AVFoundation

class SoundPlayer {
    private static var player: AVAudioPlayer?

    private static var loopSounds: [AVAudioPlayer] = []
    
    public static func play(_ soundName: String, _ volume: Float = 1.0, _ numOfLoops: Int = 0) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /// change fileTypeHint according to the type of your audio file (you can omit this)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)

            guard let player = player else {
                return
            }
            
            player.prepareToPlay()
            player.numberOfLoops = numOfLoops
            player.volume = volume
            
            if numOfLoops == -1 {
                loopSounds.append(player)
            }
            
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    player.play()
                }
            }
            
            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    public static func playLoop(_ soundName: String, _ volume: Float = 1.0) {
        self.play(soundName, volume, -1)
    }
    
    public static func playRandom(soundNames: [String], _ volume: Float = 1.0, _ numOfLoops: Int = 0) {
        let soundName = soundNames[Int(arc4random_uniform(UInt32(soundNames.count)))]
        self.play(soundName, volume, numOfLoops)
    }
}
