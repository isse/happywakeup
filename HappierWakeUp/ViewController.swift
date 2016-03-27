//
//  ViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 06/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//

import UIKit

enum WakeUpAppError: ErrorType {
    case InvalidHoursOfSleep(Int)
    case InvalidTimeReadyForBed(Int)
}

enum HoursOfSleep: Int {
    case Six = 6, Seven, Eight, Nine, Ten
    
    func asTimeInterval() -> NSTimeInterval {
        return NSTimeInterval(self.rawValue * 60 * 60)
    }
    
    func toUIIndex() -> Int {
        switch self {
        case .Six:
            return 0
        case .Seven:
            return 1
        case .Eight:
            return 2
        case .Nine:
            return 3
        case .Ten:
            return 4
        default:
            assert(false, "Unkown HoursOfSleep \(self.rawValue)")
        }
    }

    static func fromIndex(index: Int) -> HoursOfSleep {
        switch index {
            case 0:
                return .Six
            case 1:
                return .Seven
            case 2:
                return .Eight
            case 3:
                return .Nine
            case 4:
                return .Ten
            default:
                assert(false, "Invalid HoursOfSleep \(index)")
        }
    }
}

enum TimeReadyForBed: Int {
    case Half = 30
    case Hour = 60
    case Two = 120
    
    func asTimeInterval() -> NSTimeInterval {
        return NSTimeInterval(self.rawValue * 60)
    }
    func toUIIndex() -> Int {
        switch self {
            case .Half:
                return 0
            case .Hour:
                return 1
            case .Two:
                return 2
            default:
                assert(false, "Unkown TimeReadyForBed \(self.rawValue)")
            }
    }
    
    static func fromIndex(index: Int) -> TimeReadyForBed {
        switch index {
        case 0:
            return .Half
        case 1:
            return .Hour
        case 2:
            return .Two
        default:
            assert(false, "Invalid TimeReadyForBed \(index)")
        }
    }
}

struct WakeUp{
    let wakeUpTime: NSDate
    let wakeUpText = "It's time to wake up"
    let goToBedText = "Get ready for bed so you'll get enough sleep for tomorrow"
    var needHoursOfSleep: HoursOfSleep
    var timeReadyForBed: TimeReadyForBed
    var isOn: Bool
    var repeatOnlyWeekdays: Bool

    static let wakeUpTimeKey = "wakeUpTimeKey"
    static let needHoursOfSleepKey = "needHoursOfSleepKey"
    static let timeReadyForBedKey = "timeReadyForBedKey"
    static let isOnKey = "isOnKey"
    
    init(_ time: NSDate, sleep: HoursOfSleep?, prepare: TimeReadyForBed?, isOn: Bool = true, repeatOnlyWeekdays: Bool = true) {
        wakeUpTime = WakeUp.getTimeInFuture(time)
        needHoursOfSleep = (sleep != nil ? sleep! : .Eight)
        timeReadyForBed = (prepare != nil ? prepare! : .Hour)
        self.isOn = isOn
        self.repeatOnlyWeekdays = repeatOnlyWeekdays;
    }
    
    init?(dictionary: NSDictionary) {
        let time = dictionary.objectForKey(WakeUp.wakeUpTimeKey) as! NSDate
        let sleep = HoursOfSleep(rawValue: dictionary.objectForKey(WakeUp.needHoursOfSleepKey) as! Int)
        let prepare = TimeReadyForBed(rawValue: dictionary.objectForKey(WakeUp.timeReadyForBedKey) as! Int)
        let on = dictionary.objectForKey(WakeUp.isOnKey) as! Bool
        self.init(time, sleep: sleep, prepare: prepare, isOn: on)
    }
    
    func toDictionary() -> NSDictionary {
        return NSDictionary(objects: [wakeUpTime, needHoursOfSleep.rawValue, timeReadyForBed.rawValue, isOn], forKeys: [WakeUp.wakeUpTimeKey, WakeUp.needHoursOfSleepKey, WakeUp.timeReadyForBedKey, WakeUp.isOnKey])
    }
    
    func goToBedTime() -> NSDate {
        return wakeUpTime.dateByAddingTimeInterval(-needHoursOfSleep.asTimeInterval())
    }
    
    func goToBedInString() -> String {
        return timeIntervalString(goToBedTime().timeIntervalSinceDate(NSDate()))
    }
    
    func timeIntervalString(interval:NSTimeInterval) -> String {
        
        let interval = NSInteger(interval)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        if hours > 0 {
            return String(format: "in %0.2d h %0.2d min", hours, minutes)
        } else if minutes > 0 {
            return String(format: "in %0.2d min", minutes)
        } else {
            return "now"
        }
        
    }
    
    func getWakeUpNotification() -> [UILocalNotification] {
        let days = 2...6
        return WakeUp.notificationForWakeUp(wakeUpTime, message: wakeUpText, days: days, repeatOnlyWeekdays: repeatOnlyWeekdays)
    }

    func getGoToBedNotification() -> [UILocalNotification] {
        let time = wakeUpTime.dateByAddingTimeInterval(-needHoursOfSleep.asTimeInterval() - timeReadyForBed.asTimeInterval())
        let days = 1...5
        return WakeUp.notificationForWakeUp(time, message: goToBedText, days: days, repeatOnlyWeekdays: repeatOnlyWeekdays)
    }
    
    static func notificationForWakeUp(time: NSDate, message: String, days: Range<Int>, repeatOnlyWeekdays: Bool = true) -> [UILocalNotification] {
        if repeatOnlyWeekdays {
            let calendar = (NSCalendar(identifier: NSCalendarIdentifierGregorian))!
            let flags : NSCalendarUnit = [.Hour, .Minute, .Weekday, .Day, .Month]
            let components = calendar.components(flags, fromDate: time)
            let notifications: [UILocalNotification] = days.map {
                (let day) -> UILocalNotification in
                let diff = day - components.weekday;
                var multiplier = 0
                if diff != 0 {
                    multiplier = diff > 0 ? diff : (diff == 0 ? diff : diff + 7 )
                }
                let weekdayTime = time.dateByAddingTimeInterval(Double(multiplier * 24 * 60 * 60))
                return notificationForOneDay(weekdayTime, message: message, interval: NSCalendarUnit.WeekOfYear)
            }
            return notifications
            
        } else {
            return [notificationForOneDay(time, message: message, interval: NSCalendarUnit.Day)]
        }
    }
    
    
    static func notificationForOneDay(time: NSDate, message: String, interval: NSCalendarUnit) -> UILocalNotification {
        let notification = UILocalNotification()
        notification.fireDate = time
        notification.alertBody = message
        notification.alertAction = "Happy wake up"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.repeatInterval = interval
        return notification
    }

    static func getTimeInFuture(time: NSDate) -> NSDate {
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
        needSleep.selectedSegmentIndex = wakeUp.needHoursOfSleep.toUIIndex()
        timeToPrepare.selectedSegmentIndex = wakeUp.timeReadyForBed.toUIIndex()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func setAlarm(sender: AnyObject) {
        wakeUp = WakeUp(
            timeToWakeUp.date,
            sleep: HoursOfSleep.fromIndex(needSleep.selectedSegmentIndex),
            prepare: TimeReadyForBed.fromIndex(timeToPrepare.selectedSegmentIndex),
            repeatOnlyWeekdays: repeatInterval.selectedSegmentIndex == 0
        )
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
    
    var delegate: getNotifiedOfWakeUp?
    
    @IBOutlet weak var setWakeUp: UIButton!
    @IBOutlet weak var timeToWakeUp: UIDatePicker!
    @IBOutlet weak var repeatInterval: UISegmentedControl!
    
    @IBOutlet weak var needSleep: UISegmentedControl!
    @IBOutlet weak var timeToPrepare: UISegmentedControl!
    
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

