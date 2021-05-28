//
//  BubbleSound.swift
//  Sleep Bubble
//
//  Created by Yuan Li on 28/4/21.
//
//
import Foundation
import AVFoundation

class BubbleSound {
    static let shared = BubbleSound()
    var audioPlayer: AVAudioPlayer!
    
    func playSoundEffect(soundEffect: String) {
        if let bundle = Bundle.main.path(forResource: "watery-bubble", ofType: "mp3") {
            let soundEffectUrl = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf:soundEffectUrl as URL)
                guard let audioPlayer = audioPlayer else { return }
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
    }
}
