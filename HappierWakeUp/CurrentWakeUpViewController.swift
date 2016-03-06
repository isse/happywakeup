//
//  CurrentWakeUpViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 06/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//
import UIKit

class CurrentWakeUpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //TODO make sure currentWakeUp at a got point on navigating
        goToBedInLabel.text = "Go to bed in \(currentWakeUp.goToBedInString())"
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        wakeUpAtLabel.text = "So you wake up happy at \(formatter.stringFromDate(currentWakeUp.wakeUpTime))"
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var goToBedInLabel: UILabel!
    
    @IBOutlet weak var wakeUpAtLabel: UILabel!
    var currentWakeUp: WakeUp = WakeUp(wakeUpTime: NSDate())

}

