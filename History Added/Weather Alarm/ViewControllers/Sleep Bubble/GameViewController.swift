//
//  GameViewController.swift
//  Sleep Bubble
//
//  Created by Yuan Li on 16/4/21.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var trueGameView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var breathIn: UILabel!
    @IBOutlet weak var breathOut: UILabel!
    
    var name: String?
    var remainingTime = 60
    var timer = Timer()
    var maxBubbleNumber: Int!
    var score = 0
    var bubbleArray = [Bubble]()
    var bubbleRemovedArray = [Bubble]()
    var scoreRecord:[String:Int] = [:]
    
    let userDefaults = UserDefaults()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //hide temperatory labels
        breathIn.alpha = 0
        breathOut.alpha = 0
        
        //add relaxing music for better meditation
        MusicPlayer.shared.playBackgroundMusic()
        
        //show user datas
//        nameLabel.text = "\(name!)"
        remainingTimeLabel.text = " \(String(remainingTime))"
        scoreLabel.text = "\(score)"
        
        //get previous data
        if let value = userDefaults.value(forKey: "scoreRecord") as? [String:Int] {
            scoreRecord = value
        }
        
        //active text animation before game start, which also means before timers counting down
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {
            time in
            
            self.animateText()
            
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {
            time in
            
            self.startGame()
            
        }
    }

    override public func viewDidDisappear(_ animated: Bool) {
        MusicPlayer.shared.stopBackgroundMusic()
    }
  
//    public func viewWillDisappear() {
//        MusicPlayer.shared.stopBackgroundMusic()
//    }
    
    func startGame(){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            time in
            
            self.countingDown()
            self.bubbleGenerate()
            self.bubbleReducing()
            
        }
    }
    
    //Text animation, only appear before game start to encourage user to have a good deep breath
    func animateText(){
        
        UIView.animate(withDuration: 2.0, delay: 1.0, animations: { self.breathIn.alpha = 1.0}, completion: {(Completion: Bool) -> Void in
            UIView.animate(withDuration: 2.0, delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
                self.breathIn.alpha = 0
                
            }, completion: {
                (Completion : Bool) -> Void in
            })
        }
        )
        
        UIView.animate(withDuration: 6.0, delay: 1.0, animations: {
                        self.breathOut.alpha = 1.0}, completion: {(Completion: Bool) -> Void in
                            UIView.animate(withDuration: 1.0, delay: 2.0, options: UIView.AnimationOptions.curveLinear, animations: {
                                self.breathOut.alpha = 0
                            }, completion: {
                                (Completion : Bool) -> Void in
                            })
                        }
        )
        
    }
    
    //same current score under a specific players name, the current socre will be only saved when it greater than the highest score the player got before.
//    func saveScore() {
//        if scoreRecord.keys.contains("\(name!)") {
//            if score > scoreRecord["\(name!)"]! {
//                scoreRecord["\(name!)"] = score
//            } else {
//                return
//            }
//        } else {
//            scoreRecord["\(name!)"] = score
//        }
//        userDefaults.setValue(scoreRecord, forKey: "scoreRecord")
//    }
    
    
    
    // Time counting down by the interval of 1 sec, and show the remainning time on the screen.
    @objc func countingDown(){
        remainingTime -= 1
        remainingTimeLabel.text = " \(String(remainingTime))"
        
        //Game finishes when time is out, and the players score will be saved/updated/ignored depends on if they achieved their highest score. The socre data will be pass to ScoreViewController.
        if remainingTime == 0 {
            
            timer.invalidate()
            
            let vc = storyboard?.instantiateViewController(identifier: "SettingViewController") as! SettingViewController
              // vc.navigationItem.setHidesBackButton(true, animated: true)
             self.navigationController?.pushViewController(vc, animated: true)
            
           // let vc = storyboard?.instantiateViewController(identifier: "ScoreViewController") as! ScoreViewController
         //   self.navigationController?.pushViewController(vc, animated: true)
         //   vc.navigationItem.setHidesBackButton(true, animated: true)
            
            //saveScore()
        }
    }
    
    //Prepare for bubbleGenerate: check if any two or more bubbles overlap each other.
    func intersection (bubble: Bubble) -> Bool {
        
        for i in bubbleArray{
            if bubble.frame.intersects((i as AnyObject).frame){
                return true
            }
        }
        return false
    }
    
    //Generate bubble randomly every seconds.
    @objc func bubbleGenerate (){
        
        /*
         Only generate bubbles when the bubble on the screen less than the max bubble numbser
         Use array to manage bubbles, so that the bubbles on the screen can be easily counted.
         */
        var bubblesCanGenerate = maxBubbleNumber - bubbleArray.count
        
        //generate random numbers of bubbles within a legal range
        let bubblesGenerate = arc4random_uniform(UInt32(maxBubbleNumber - bubbleArray.count))
        
        //Only generate bubbles when there is capacity.
        while bubblesGenerate < bubblesCanGenerate {
            
            let bubble = Bubble()
            // when bubbles has been pressed active the related function: bubblePressed
            bubble.addTarget(self, action: #selector(bubblePressed), for: .touchUpInside)
            
            /* Only the bubbles not overlap to each other are valid. Only valid bubbles will be showed on the screen, and added to the bubble array.
             When a valid bubble has been generated, the number of bubbles we can generate correspondingly reduces.
             */
            if intersection(bubble: bubble) == false {
                
                bubbleArray += [bubble]
                bubblesCanGenerate -= 1
                
                self.view.addSubview(bubble)
            }
        }
    }
    
    
    /* When bubbles have been pressed by players, they will be removed from both the screen and the bubble array, and added to bubble removed array.
     bubbleRemovedArray has been created to manage and compare if the current pressed bubble and the previous pressed bubble.
     */
    @IBAction func bubblePressed (bubble:Bubble){
        
        //Get current pressed bubble's index.
        let bubbleIndex = bubbleArray.firstIndex(of: bubble)
        
        /* If it is first bubble has been pressed, the point will be added straight away, otherwise, the current pressed bubble will be compared to the previous pressed bubble. If the colour/point are same, the point will be add with an extra.
         */
        if bubbleRemovedArray.count == 0 {
            score += bubble.point
        } else {
            if bubbleArray[bubbleIndex!].point == bubbleRemovedArray[(bubbleRemovedArray.count - 1)].point {
                score += Int(Double(bubbleArray[bubbleIndex!].point) * 1.5)
            }
            else {
                score += bubbleArray[bubbleIndex!].point
            }
        }
        
        //remove the bubble has been pressed from bubble array
        bubbleArray.remove(at: bubbleIndex!)
        
        //undate score label when score is updated
        scoreLabel.text = "\(score)"
        
        //add the pressed bubble to another array
        bubbleRemovedArray += [bubble]
    }
    
    //reduce bubbles randomly when there are too many of them on the screen. In the author's view, more than 8 is too many.
    @objc func bubbleReducing (){
        
        //choose random bubble that on the screen currently
        let bubbleToReduce = bubbleArray.randomElement()
        
        //find its index
        let bubbleIndex = bubbleArray.firstIndex(of: bubbleToReduce!)
        
        if bubbleArray.count > 8 {
            bubbleArray[bubbleIndex!].removeFromSuperview()
            
            bubbleArray.remove(at: bubbleIndex!)
            
        }
    }
}


