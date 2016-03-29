//
//  CurrentWakeUpViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 06/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//
import UIKit

extension UIView {
    func layerGradient(landscape: Bool, size: CGSize) {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame = self.bounds
        layer.frame.size = size
        layer.frame.origin = CGPointMake(0.0,0.0)
        if(landscape) {
            layer.startPoint = CGPointMake(0.0, 0.5)
            layer.endPoint = CGPointMake(1.0, 0.5)
        } else {
            layer.startPoint = CGPointMake(0.5, 0.0)
            layer.endPoint = CGPointMake(0.5, 1.0)
        }
        
        let colorNight = UIColor(red: 0.0/255.0, green: 62.0/255.0, blue: 84.0/255.0, alpha: 1.0).CGColor
        let colorDawn = UIColor(red: 255.0/255.0, green: 186.0/255.0, blue: 152.0/255.0, alpha: 1.0).CGColor
        
        //TODO orientation change, subviews won't behave :(
        layer.colors = [colorNight, colorDawn]
        layer.locations = [0.0, 1.0]
        self.layer.insertSublayer(layer, atIndex: 0)
    }
}

class CurrentWakeUpViewController: UIViewController, GetNotifiedOfWakeUp, NotificationSettingsRegistered {
    
    let storageKey = "currentWakeUp"
    var currentWakeUp: WakeUp?
    var updateView: NSTimer?
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
 
        self.view.layerGradient(UIDevice.currentDevice().orientation.isLandscape.boolValue, size: baseView.frame.size)
        // Do any additional setup after loading the view, typically from a nib.
        
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
        //TODO these get garbage collected?
        updateView = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(CurrentWakeUpViewController.updateIfWakeUpSet), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.view.layerGradient(UIDevice.currentDevice().orientation.isLandscape.boolValue, size: size)
    }

    func navigateToEditWakeUpViewWith(wakeUp: WakeUp) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditViewControllerId") as! ViewController
        viewController.wakeUp = wakeUp
        viewController.delegate = self
        self.presentViewController(viewController, animated: true){}
    }
    
    func setWakeUpWhenNavigatingBack(wakeUp: WakeUp) {
        storeWakeUp(wakeUp)
        self.currentWakeUp = wakeUp
        updateViewWithWakeUp(wakeUp)
    }
    
    func updateIfWakeUpSet() {
        if self.currentWakeUp != nil {
            updateViewWithWakeUp(self.currentWakeUp!)
        }
    }
    
    func updateViewWithWakeUp(wakeUp: WakeUp) {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        goToBedInLabel.text = "Go to bed \(wakeUp.goToBedInString())"
        wakeUpAtLabel.text = "So you wake up happy at \(formatter.stringFromDate(wakeUp.wakeUpTime))"
        wakeUpOn.on = wakeUp.isOn
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
    
    //protocol NotificationSettingsRegistered
    func notificationSettingsRegistered(granted: Bool) {
    }

}

