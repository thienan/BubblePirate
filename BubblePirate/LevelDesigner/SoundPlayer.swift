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
    private static var soundPlayers: [AVAudioPlayer] = []
    private static let ERROR_URL_NOT_FOUND = "url not found"
    private static let ERROR_AV_PLAYER_CANT_BE_PLAYED = "Error: AVAudioPlayer cant be played"
    private static let EXTENSION = "mp3"
    
    public static func play(_ soundName: String, _ volume: Float = 1.0, _ numOfLoops: Int = 0) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: EXTENSION) else {
            print(ERROR_URL_NOT_FOUND)
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let player: AVAudioPlayer
            var findPlayer = findIdlePlayer(url)
            
            if findPlayer == nil {
                findPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
                guard let findPlayer = findPlayer else { return }
                
                player = findPlayer
                soundPlayers.append(player)
            } else {
                player = findPlayer!
            }
            
            player.prepareToPlay()
            player.numberOfLoops = numOfLoops
            player.volume = volume
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    player.play()
                }
            }
            
        } catch {
            print(ERROR_AV_PLAYER_CANT_BE_PLAYED)
        }
    }
    
    public static func playLoop(_ soundName: String, _ volume: Float = 1.0) {
        self.play(soundName, volume, -1)
    }
    
    public static func playRandom(soundNames: [String], _ volume: Float = 1.0, _ numOfLoops: Int = 0) {
        let soundName = soundNames[Int(arc4random_uniform(UInt32(soundNames.count)))]
        self.play(soundName, volume, numOfLoops)
    }
    
    private static func removeInactivePlayer() {
        for player in soundPlayers {
            if !player.isPlaying {
                guard let index = soundPlayers.index(of: player) else { continue }
                soundPlayers.remove(at: index)
                break
            }
        }
    }
    
    private static func findIdlePlayer(_ url: URL) -> AVAudioPlayer? {
        for player in soundPlayers {
            if !player.isPlaying {
                continue
            }
            if player.url == url {
                return player
            }
        }
        return nil
    }
}
