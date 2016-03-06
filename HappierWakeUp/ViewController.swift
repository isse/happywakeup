//
//  ViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 06/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//

import UIKit

struct WakeUp {
    var wakeUpTime: NSDate
    
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
    
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func setAlarm(sender: AnyObject) {
    }
    
    @IBOutlet weak var setWakeUp: UIButton!
    @IBOutlet weak var timeToWakeUp: UIDatePicker!
    func SetNotification(time: NSDate, message: String) {
        let wakeUpNotification = UILocalNotification()
        wakeUpNotification.fireDate = time
        wakeUpNotification.alertBody = message
        wakeUpNotification.alertAction = "Happy wake up"
        wakeUpNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(wakeUpNotification)
        
    }
    
    var wakeUp: WakeUp?
    
    func setWakeUpForTime() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let time = getWakeUpTimeInFuture(timeToWakeUp.date)
        // TODO INTERVAL
        SetNotification(time.dateByAddingTimeInterval(-15), message: "Get ready for bed so you'll get enough sleep for tomorrow")
        SetNotification(time, message: "It's time to wake up")
        wakeUp = WakeUp(wakeUpTime: time)
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if setWakeUp === sender {
            //TODO maybe remove seque and navigate in click handler only if notification set succesfullly. Also check if have permission for notifications or say something
            let destination = segue.destinationViewController as! CurrentWakeUpViewController
            setWakeUpForTime()
            destination.currentWakeUp = wakeUp!
        }
    }
    
    func getWakeUpTimeInFuture(time: NSDate) -> NSDate {
        if NSDate().compare(time) == NSComparisonResult.OrderedDescending {
            return time.dateByAddingTimeInterval(24 * 60 * 60)
        }
        
        return time
    }
    
    
}

