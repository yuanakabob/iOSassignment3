//
//  SettingViewController.swift
//  Sleep Bubble
//
//  Created by Yuan Li on 16/4/21.
//  Student ID 13670056
//

import UIKit

class SettingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var timeReader: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBAction func timeSlider(_ sender: UISlider) {
        let currentTime = Int(sender.value)
        timeReader.text = "\(currentTime)"
    }
    @IBOutlet weak var bubbleReader: UILabel!
    @IBOutlet weak var bubbleSlider: UISlider!
    
    // show max bubble number
    @IBAction func bubbleSlider(_ sender: UISlider) {
        
        let maxBubbleNumber = Int(sender.value)
        bubbleReader.text = "\(maxBubbleNumber)"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        //set default time and bubble numbser setting
        timeSlider.value = 60
        bubbleSlider.value = 15
    }
    
    //remove keyboard when user press Enter
 //   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     //   nameTextField.resignFirstResponder()
    //    return true
   // }
    
    //limit the lenghth of user name
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let textFieldText = nameTextField.text,
//              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
//            return false
//        }
//        let substringToReplace = textFieldText[rangeOfTextToReplace]
//        let count = textFieldText.count - substringToReplace.count + string.count
//        return count <= 10
//    }
    
    //passing data to GameViewController
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            let VC = segue.destination as! GameViewController
        //    VC.name = nameTextField.text
            VC.remainingTime = Int(timeSlider.value)
            VC.maxBubbleNumber = Int(bubbleSlider.value)
        }
    }
}
