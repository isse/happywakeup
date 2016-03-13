//
//  ViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 06/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//

import UIKit

struct WakeUp {
    
    init(_ time: NSDate) {
        wakeUpTime = WakeUp.getWakeUpTimeInFuture(time)
    }
    
    let wakeUpTime: NSDate
    let wakeUpText = "It's time to wake up"
    let goToBedText = "Get ready for bed so you'll get enough sleep for tomorrow"
    
    func goToBedTime() -> NSDate {
        return wakeUpTime.dateByAddingTimeInterval(-8 * 60 * 60)
    }
    
    func goToBedInString() -> String {
        return timeIntervalString(goToBedTime().timeIntervalSinceDate(NSDate()))
    }
    
    func timeIntervalString(interval:NSTimeInterval) -> String {
        
        let interval = NSInteger(interval)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        return String(format: "%0.2d h %0.2d min",hours,minutes)
    }
    
    func getWakeUpNotification() -> UILocalNotification {
        let time = WakeUp.getWakeUpTimeInFuture(wakeUpTime)
        return WakeUp.notificationForWakeUp(time, message: wakeUpText)
    }

    func getGoToBedNotification() -> UILocalNotification {
        let time = WakeUp.getWakeUpTimeInFuture(wakeUpTime).dateByAddingTimeInterval(-15)
        return WakeUp.notificationForWakeUp(time, message: goToBedText)
    }
    
    static func notificationForWakeUp(time: NSDate, message: String) -> UILocalNotification {
        let notification = UILocalNotification()
        notification.fireDate = time
        notification.alertBody = message
        notification.alertAction = "Happy wake up"
        notification.soundName = UILocalNotificationDefaultSoundName
        return notification
    }

    static func getWakeUpTimeInFuture(time: NSDate) -> NSDate {
        // TODO maybe not elegant
        let calendar = (NSCalendar(identifier: NSCalendarIdentifierGregorian))!
        let now = NSDate()
        let dateFlags : NSCalendarUnit = [.Day, .Month, .Year]
        let nowComponents = calendar.components(dateFlags, fromDate: now)
        let timeFlags : NSCalendarUnit = [.Hour, .Minute]
        let wakeUpComponents = calendar.components(timeFlags, fromDate: time)
        nowComponents.setValue(wakeUpComponents.hour, forComponent: .Hour)
        nowComponents.setValue(wakeUpComponents.minute, forComponent: .Minute)
        let wakeUpFromNow = (calendar.dateFromComponents(nowComponents))!
        if NSDate().compare(wakeUpFromNow) == NSComparisonResult.OrderedDescending {
            return wakeUpFromNow.dateByAddingTimeInterval(24 * 60 * 60)
        }
        return wakeUpFromNow
    }

}

protocol getNotifiedOfWakeUp {
    func wakeUpWasSetTo(wakeUp: WakeUp)
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timeToWakeUp.date = wakeUp.wakeUpTime
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func setAlarm(sender: AnyObject) {
        wakeUp = WakeUp(timeToWakeUp.date)
        if ViewController.setWakeUpForTime(wakeUp) {
            delegate?.wakeUpWasSetTo(wakeUp)
            dismissViewControllerAnimated(true){}
        }
        // TODO or else?
    }
    static func setWakeUpForTime(wakeUp: WakeUp) -> Bool {
        ViewController.getPermissionForNotification()
        if ViewController.havePermissionForNotification() {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            ViewController.SetNotification(wakeUp.getGoToBedNotification())
            ViewController.SetNotification(wakeUp.getWakeUpNotification())
            return true
        }
        return false;
    }
    
    var delegate: getNotifiedOfWakeUp?
    
    @IBOutlet weak var setWakeUp: UIButton!
    @IBOutlet weak var timeToWakeUp: UIDatePicker!
    
    
    static func SetNotification(notification: UILocalNotification) {
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    var wakeUp: WakeUp!
    
    
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

