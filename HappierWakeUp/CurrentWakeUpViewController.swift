//
//  CurrentWakeUpViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 06/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//
import UIKit

extension UIView {
    func layerGradient() {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.frame.origin = CGPointMake(0.0,0.0)
        
        let colorNight = UIColor(red: 5.0/255.0, green: 20.0/255.0, blue: 40.0/255.0, alpha: 1.0).CGColor
        let colorDay = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor
        let colorDawn = UIColor(red: 252.0/255.0, green: 244.0/255.0, blue: 200.0/255.0, alpha: 1.0).CGColor
        
        layer.colors = [colorNight, colorNight, colorDay, colorDay, colorDawn]
        layer.locations = [0.0, 0.3, 0.6, 0.97, 1.0]
        self.layer.insertSublayer(layer, atIndex: 0)
    }
}

class CurrentWakeUpViewController: UIViewController, getNotifiedOfWakeUp {
    
    let storageKey = "currentWakeUp"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        baseView.layerGradient()
        // Do any additional setup after loading the view, typically from a nib.
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        let storedWakeUp = NSUserDefaults.standardUserDefaults().objectForKey(storageKey)
        if storedWakeUp != nil {
            currentWakeUp = WakeUp(dictionary: storedWakeUp as! NSDictionary)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if currentWakeUp == nil {
            navigateToEditWakeUpViewWith(WakeUp(NSDate(), sleep: nil, prepare: nil))
        } else {
            updateViewWithWakeUp(currentWakeUp!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var baseView: UIView!
    @IBAction func editWakeUp(sender: AnyObject) {
        navigateToEditWakeUpViewWith(currentWakeUp!)
    }
    
    @IBOutlet weak var goToBedInLabel: UILabel!
    
    @IBOutlet weak var wakeUpAtLabel: UILabel!
    @IBOutlet weak var wakeUpOn: UISwitch!

    @IBAction func wakeUpOnOffSet(sender: AnyObject) {
        assert(currentWakeUp != nil)
        setWakeUpOnOff(wakeUpOn.on)
        currentWakeUp?.isOn = wakeUpOn.on
        storeWakeUp(currentWakeUp!)
    }
    
    var currentWakeUp: WakeUp?

    func navigateToEditWakeUpViewWith(wakeUp: WakeUp) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditViewControllerId") as! ViewController
        viewController.wakeUp = wakeUp
        viewController.delegate = self
        self.presentViewController(viewController, animated: true){}
    
    }
    
    func updateViewWithWakeUp(wakeUp: WakeUp) {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        goToBedInLabel.text = "Go to bed in \(wakeUp.goToBedInString()) at \(formatter.stringFromDate(wakeUp.goToBedTime()))"
        wakeUpAtLabel.text = "So you wake up happy at \(formatter.stringFromDate(wakeUp.wakeUpTime))"
        wakeUpOn.on = wakeUp.isOn
    }
    
    func wakeUpWasSetTo(wakeUp: WakeUp) {
        storeWakeUp(wakeUp)
        self.currentWakeUp = wakeUp
        updateViewWithWakeUp(wakeUp)
    }

    func storeWakeUp(wakeUp: WakeUp) {
        NSUserDefaults.standardUserDefaults().setObject(wakeUp.toDictionary(), forKey: storageKey)
    }

    func setWakeUpOnOff(on: Bool) {
        goToBedInLabel.enabled = on
        wakeUpAtLabel.enabled = on
        if on {
            ViewController.setWakeUpForTime(currentWakeUp!)
        } else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
}

