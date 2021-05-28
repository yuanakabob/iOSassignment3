//
//  Bubble.swift
//  Sleep Bubble
//
//  Created by Yuan Li on 17/4/21.
//

import UIKit

//Let bubble size more adaptable/suitable for different screen size.
var screeSize = UIScreen.main.bounds
var diameter =
    UInt32(sqrt(UIScreen.main.bounds.width * UIScreen.main.bounds.height) / 8)


class Bubble: UIButton {
    
    let i = Int.random(in: 1...100)
    
    //generate random x, y location while making sure the bubble won't be out of the true game view.
    let xPosition = 10 + arc4random_uniform(UInt32(screeSize.width - CGFloat(diameter) - 20))
    let yPosition = 160 + arc4random_uniform(UInt32(screeSize.maxY - CGFloat(diameter) - 180))
    
    var point: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Give the appropriate bubble size and location(random).
        self.frame = CGRect(x: CGFloat(xPosition), y: CGFloat(yPosition), width: CGFloat(diameter), height: CGFloat(diameter))
        //Making bubble shape: round.
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        //Set different colours and corresponding points to bubbles with given possibility using switch.
        switch i {
        case 1...40:
            self.backgroundColor = .init(hue: 348/360, saturation: 0.82, brightness: 1, alpha: 0.6)
            self.point = 1
        case 41...70:
            self.backgroundColor = .init(hue: 322/360, saturation: 0.82, brightness: 1, alpha: 0.6)
            self.point = 2
        case 71...85:
            self.backgroundColor = .init(hue: 83/360, saturation: 0.52, brightness: 1, alpha: 0.6)
            self.point = 5
        case 86...95:
            self.backgroundColor = .init(hue: 175/360, saturation: 0.38, brightness: 1, alpha: 0.6)
            self.point = 8
        case 96...100:
            self.backgroundColor = .init(white: 0.3, alpha: 0.6)
            self.point = 10
        default:
            self.backgroundColor = .red
            self.point = 0
        }
        self.addTarget(self, action: #selector(bubblePressed), for: .touchUpInside)
        animation()
    }
    
    //when bubble has been pressed, it will be removed from view and the sound effect will be activated.
    @IBAction func bubblePressed (_ sender: UIButton){
        
        UIButton.animate(withDuration: 0.2, delay: 0.0, animations: {self.flash()}, completion: nil)
        UIButton.animate(withDuration: 0.1, delay: 0.2, animations: {sender.removeFromSuperview()}, completion: nil)
        
        BubbleSound.shared.playSoundEffect(soundEffect: "Watery-bubble")
        // sound source: https://www.zapsplat.com/sound-effect-category/bubbles/
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animation() {
        let springAnimation = CASpringAnimation(keyPath: "transform.scale")
        springAnimation.duration = 0.6
        springAnimation.fromValue = 1
        springAnimation.toValue = 0.8
        springAnimation.repeatCount = 1
        springAnimation.initialVelocity = 0.5
        springAnimation.damping = 1
        layer.add(springAnimation, forKey: nil)
    }

    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        layer.add(flash, forKey: nil)
    }
}
