//
//  CurrentWakeUpViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 06/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//
import UIKit

class CurrentWakeUpViewController: UIViewController, getNotifiedOfWakeUp {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        if notifications?.count > 0 {

            //TODO something reliable
            currentWakeUp = WakeUp((notifications![0]).fireDate!)
            updateViewWithWakeUp(currentWakeUp)
        } else {
            //TODO persisting data
            navigateToEditWakeUpViewWith(WakeUp(NSDate()))
        }
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editWakeUp(sender: AnyObject) {
        navigateToEditWakeUpViewWith(currentWakeUp)
    }
    
    @IBOutlet weak var goToBedInLabel: UILabel!
    
    @IBOutlet weak var wakeUpAtLabel: UILabel!
    @IBOutlet weak var wakeUpOn: UISwitch!

    @IBAction func wakeUpOnOffSet(sender: AnyObject) {
            setWakeUpOnOff(wakeUpOn.on)
    }
    
    var currentWakeUp = WakeUp(NSDate())

    func navigateToEditWakeUpViewWith(wakeUp: WakeUp) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditViewControllerId") as! ViewController
        viewController.wakeUp = wakeUp
        viewController.delegate = self
        self.presentViewController(viewController, animated: true){}
    
    }
    
    func updateViewWithWakeUp(wakeUp: WakeUp) {
        goToBedInLabel.text = "Go to bed in \(wakeUp.goToBedInString())"
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        wakeUpAtLabel.text = "So you wake up happy at \(formatter.stringFromDate(wakeUp.wakeUpTime))"
    }
    
    func wakeUpWasSetTo(wakeUp: WakeUp) {
        currentWakeUp = wakeUp
        updateViewWithWakeUp(currentWakeUp)
    }
    
    func setWakeUpOnOff(on: Bool) {
        goToBedInLabel.enabled = on
        wakeUpAtLabel.enabled = on
        if on {
            ViewController.setWakeUpForTime(currentWakeUp)
        } else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
}

