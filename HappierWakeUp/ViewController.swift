//
//  ViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 06/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//

import UIKit

protocol GetNotifiedOfWakeUp {
    func setWakeUpWhenNavigatingBack(wakeUp: WakeUp)
}

class ViewController: UIViewController, NotificationSettingsRegistered, AlertPlayerDelegate {
    
    var delegate: GetNotifiedOfWakeUp?
    var wakeUp: WakeUp!
    var wakeUpPlayer = AlertPlayer()
    let playImage = UIImage(named: "ic_play_arrow")
    let stopImage = UIImage(named: "ic_stop")

    @IBOutlet var baseView: UIView!
    @IBOutlet weak var timeToWakeUp: UIDatePicker!
    @IBOutlet weak var repeatInterval: UISegmentedControl!
    @IBOutlet weak var needSleep: UISegmentedControl!
    @IBOutlet weak var timeToPrepare: UISegmentedControl!

    @IBAction func doneSettingWakeUp(sender: AnyObject) {
        if ViewController.havePermissionForNotification() {
            setWakeUpWithViewDataAndDismis()
        } else {
            ViewController.getPermissionForNotification()
        }
        // TODO or else?
    }

    @IBOutlet weak var playWakeUpBtn: UIButton!
    
    @IBAction func tryWakeUp(sender: AnyObject) {
        if tryWakeUpIsPlaying() {
            stopWakeUpPlayer()
        }
        else {
            playWakeUp()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timeToWakeUp.date = wakeUp.wakeUpTime
        repeatInterval.selectedSegmentIndex = wakeUp.repeatOnlyWeekdays ? 0 : 1
        needSleep.selectedSegmentIndex = wakeUp.needHoursOfSleep.toUIIndex()
        timeToPrepare.selectedSegmentIndex = wakeUp.timeReadyForBed.toUIIndex()
        self.view.layerGradient(baseView.frame.size, dark: false)
        wakeUpPlayer.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func setWakeUpWithViewDataAndDismis() {
        wakeUp = WakeUp(
            timeToWakeUp.date,
            sleep: HoursOfSleep.fromIndex(needSleep.selectedSegmentIndex),
            prepare: TimeReadyForBed.fromIndex(timeToPrepare.selectedSegmentIndex),
            repeatOnlyWeekdays: repeatInterval.selectedSegmentIndex == 0
        )
        stopWakeUpPlayer()
        ViewController.setWakeUpForTime(wakeUp)
        delegate?.setWakeUpWhenNavigatingBack(wakeUp)
        dismissViewControllerAnimated(true){}
    }

    static func setWakeUpForTime(wakeUp: WakeUp){
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            let goToBeds = wakeUp.getGoToBedNotification()
            let wakeUps = wakeUp.getWakeUpNotification()
            for notification in goToBeds {
                ViewController.SetNotification(notification)
            }
            for notification in wakeUps {
                ViewController.SetNotification(notification)
            }
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
    
    //protocol notificationSettingsRegistered
    func notificationSettingsRegistered(granted: Bool) {
        if granted {
            setWakeUpWithViewDataAndDismis()
        } else {
            showNotificationAlertViewController()
        }
    }
    
    // AlertPlayerDelegate
    func alertPlayingStopped() {
        playWakeUpBtn.setImage(playImage, forState: .Normal)
    }
    
    func playWakeUp() {
        wakeUpPlayer.playWakeUp()
        playWakeUpBtn.setImage(stopImage, forState: .Normal)
    }
    
    func stopWakeUpPlayer() {
        wakeUpPlayer.stopWakeUpPlayer()
    }

    func tryWakeUpIsPlaying() -> Bool {
        if playWakeUpBtn.currentImage == stopImage {
            return true
        } else {
            return false
        }
    }
}

