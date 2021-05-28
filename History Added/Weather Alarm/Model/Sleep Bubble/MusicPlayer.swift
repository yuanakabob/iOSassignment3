//
//  MusicPlayer.swift
//  Sleep Bubble
//
//  Created by Yuan Li on 28/4/21.
//

import Foundation
import AVFoundation

class MusicPlayer {
    static let shared = MusicPlayer()
    var audioPlayer: AVAudioPlayer!
    
    
    func playBackgroundMusic(){
        if let bundle = Bundle.main.path(forResource: "happiness-802", ofType: "mp3") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                guard audioPlayer == audioPlayer else { return }
                audioPlayer.numberOfLoops = -1
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
    }
    
    func stopBackgroundMusic(){
        audioPlayer.stop()
    }
    
}
