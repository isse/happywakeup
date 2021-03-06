//
//  CurrentWakeUpViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 06/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//
import UIKit
import Crashlytics // If using Answers with Crashlytics

extension UIView {
    func addBackground() {
        // screen width and height:
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: "iPhone 6")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}

class CurrentWakeUpViewController: UIViewController, GetNotifiedOfWakeUp, NotificationSettingsRegistered {
    
    let storageKey = "currentWakeUp"
    let wakeUpPlayer = AlertPlayer()
    var currentWakeUp: WakeUp?
    var updateView: NSTimer?
    var wakeUpTimers: [NSTimer] = []
    
    let answersItemNameSet = "Wake up set"
    let answersItemTypeSet = "Wake up set"
    let answersIdSet = "sku-1"

    let answersItemNameEnable = "Wake up enabled"
    let answersItemTypeEnable = "Wake up enabled"
    let answersIdEnable = "sku-2"

    let answersEventDisable = "Disable wake up"

    @IBOutlet weak var goodMorningLabel: UILabel!
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var goToBedInLabel: UILabel!
    @IBOutlet weak var wakeUpAtLabel: UILabel!
    @IBOutlet weak var wakeUpOn: UISwitch!

    @IBAction func editWakeUp(sender: AnyObject) {
        navigateToEditWakeUpViewWith(currentWakeUp!)
    }
    
    @IBAction func wakeUpOnOffSet(sender: AnyObject) {
        assert(currentWakeUp != nil)
        setWakeUpOnOff(wakeUpOn.on)
        currentWakeUp?.isOn = wakeUpOn.on
        storeWakeUp(currentWakeUp!)

        if wakeUpOn.on {
            Answers.logPurchaseWithPrice(1,
                                         currency: "USD",
                                         success: true,
                                         itemName: answersItemNameEnable,
                                         itemType: answersItemTypeEnable,
                                         itemId: answersIdEnable,
                                         customAttributes: currentWakeUp?.answersCustomAttributes()
            )
        } else {
            Answers.logCustomEventWithName(answersEventDisable,
                                           customAttributes: currentWakeUp?.answersCustomAttributes())
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
 
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector (CurrentWakeUpViewController.applicationDidBecomeActive),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector (CurrentWakeUpViewController.applicationWillResignActive),
            name: UIApplicationWillResignActiveNotification,
            object: nil)

        self.view.addBackground()
        // Do any additional setup after loading the view, typically from a nib.
        
        let storedWakeUp = NSUserDefaults.standardUserDefaults().objectForKey(storageKey)
        if storedWakeUp != nil {
            currentWakeUp = WakeUp(dictionary: storedWakeUp as! NSDictionary)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (CurrentWakeUpViewController.handleTap))
        baseView.addGestureRecognizer(tapGesture)
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        // do something
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if delegate.launchedFromNotification == WakeUp.wakeUpValue {
            goodMorningLabel.hidden = false
            wakeUpAtLabel.alpha = 0.4
            goToBedInLabel.alpha = 0.4
            UIView.animateWithDuration(15, animations: { [weak self] in
                if let selfish = self {
                    selfish.goodMorningLabel.alpha = 0.0
                    selfish.wakeUpAtLabel.alpha = 1.0
                    selfish.goToBedInLabel.alpha = 1.0
                }
            })
        } else if currentWakeUp != nil {
            rescheduleTimers(currentWakeUp!)
        }
    }

    func applicationWillResignActive(notification: NSNotification) {
        invalidateTimers()
        stopOnGoingAlert()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if currentWakeUp == nil {
            navigateToEditWakeUpViewWith(WakeUp(NSDate(), sleep: nil, prepare: nil))
        } else {
            updateViewWithWakeUp(currentWakeUp!)
            rescheduleTimers(currentWakeUp!)

        }
        updateView = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(CurrentWakeUpViewController.updateIfWakeUpSet), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        invalidateTimers()
        stopOnGoingAlert()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        rescheduleTimers(wakeUp)
        
        let attributes = wakeUp.answersCustomAttributes()
        Answers.logPurchaseWithPrice(1,
                                     currency: "USD",
                                     success: true,
                                     itemName: answersItemNameSet,
                                     itemType: answersItemTypeSet,
                                     itemId: answersIdSet,
                                     customAttributes: attributes
        )
    }
    
    func rescheduleTimers(wakeUp: WakeUp) {
        invalidateTimers()
        wakeUpTimers = setTimersWithAlerts(wakeUp.getWakeUpAlerts(), selector: #selector (CurrentWakeUpViewController.wakeUpAlert))
    }
    
    func invalidateTimers() {
        for timer in wakeUpTimers {
            timer.invalidate()
        }
    }
    
    func setTimersWithAlerts(alerts: [AlertTime], selector: Selector) -> [NSTimer] {
        let timers = alerts.map {
            (let alert) -> NSTimer in
            return NSTimer.init(fireDate: alert.time, interval: alert.repeatInterval(), target: self, selector: selector, userInfo: nil, repeats: true)
        }
        let runLoop = NSRunLoop.currentRunLoop()
        for timer in timers {
            runLoop.addTimer(timer, forMode: NSRunLoopCommonModes)
        }
        return timers
    }
    
    func wakeUpAlert() {
        wakeUpPlayer.playWakeUp()
        goodMorningLabel.hidden = false
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        stopOnGoingAlert()
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
        wakeUpAtLabel.text = "So you wake up happy at \n \(formatter.stringFromDate(wakeUp.wakeUpTime))"
        goToBedInLabel.enabled = wakeUp.isOn
        wakeUpAtLabel.enabled = wakeUp.isOn
        wakeUpOn.on = wakeUp.isOn
    }
    
    func storeWakeUp(wakeUp: WakeUp) {
        NSUserDefaults.standardUserDefaults().setObject(wakeUp.toDictionary(), forKey: storageKey)
    }

    func setWakeUpOnOff(on: Bool) {
        if on {
            if ViewController.havePermissionForNotification() {
                currentWakeUp!.isOn = true
                ViewController.setWakeUpForTime(currentWakeUp!)
                goToBedInLabel.enabled = on
                wakeUpAtLabel.enabled = on
            } else {
                wakeUpOn.on = false
                showNotificationAlertViewController()
            }
        } else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            currentWakeUp!.isOn = false
            goToBedInLabel.enabled = on
            wakeUpAtLabel.enabled = on
        }
    }
    
    func stopOnGoingAlert() {
        wakeUpPlayer.stopWakeUpPlayer()
        goodMorningLabel.hidden = true
    }
    
    //protocol NotificationSettingsRegistered
    func notificationSettingsRegistered(granted: Bool) {}
    }

