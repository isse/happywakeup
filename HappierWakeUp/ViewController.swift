//
//  ViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 06/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//

import UIKit


protocol getNotifiedOfWakeUp {
    func setWakeUpWhenNavigatingBack(wakeUp: WakeUp)
}

class ViewController: UIViewController {
    
    var delegate: getNotifiedOfWakeUp?
    var wakeUp: WakeUp!

    @IBOutlet weak var timeToWakeUp: UIDatePicker!
    @IBOutlet weak var repeatInterval: UISegmentedControl!
    
    @IBOutlet weak var needSleep: UISegmentedControl!
    @IBOutlet weak var timeToPrepare: UISegmentedControl!

    @IBAction func doneSettingWakeUp(sender: AnyObject) {
        wakeUp = WakeUp(
            timeToWakeUp.date,
            sleep: HoursOfSleep.fromIndex(needSleep.selectedSegmentIndex),
            prepare: TimeReadyForBed.fromIndex(timeToPrepare.selectedSegmentIndex),
            repeatOnlyWeekdays: repeatInterval.selectedSegmentIndex == 0
        )
        if ViewController.setWakeUpForTime(wakeUp) {
            delegate?.setWakeUpWhenNavigatingBack(wakeUp)
            dismissViewControllerAnimated(true){}
        }
        // TODO or else?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timeToWakeUp.date = wakeUp.wakeUpTime
        needSleep.selectedSegmentIndex = wakeUp.needHoursOfSleep.toUIIndex()
        timeToPrepare.selectedSegmentIndex = wakeUp.timeReadyForBed.toUIIndex()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    static func setWakeUpForTime(wakeUp: WakeUp) -> Bool {
        ViewController.getPermissionForNotification()
        if ViewController.havePermissionForNotification() {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            let goToBeds = wakeUp.getGoToBedNotification()
            let wakeUps = wakeUp.getWakeUpNotification()
            for notification in goToBeds {
                ViewController.SetNotification(notification)
            }
            for notification in wakeUps {
                ViewController.SetNotification(notification)
            }
            return true
        }
        return false;
    }
    
    
    static func SetNotification(notification: UILocalNotification) {
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    
    static func getPermissionForNotification() {
        let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType([.Alert, .Badge, .Sound]), categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    static func havePermissionForNotification() -> Bool {
        let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        //TODO this ok?
        return notificationSettings?.types.contains([.Alert, .Sound, .Badge]) === true
    }
    
}

