//
//  WakeUp.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 28/03/16.
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
    static let notificationUserInfoKey = "notificationUserInfoKey"
    static let wakeUpValue = "WakeUpValue"
    static let goToBedValue = "goToBedUserInfo"
    
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
        return WakeUp.getTimeInFuture(wakeUpTime).dateByAddingTimeInterval(-needHoursOfSleep.asTimeInterval())
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
        return WakeUp.notificationForWakeUp(wakeUpTime, message: wakeUpText, days: days, userInfo: WakeUp.wakeUpValue, repeatOnlyWeekdays: repeatOnlyWeekdays)
    }
    
    func getGoToBedNotification() -> [UILocalNotification] {
        let time = wakeUpTime.dateByAddingTimeInterval(-needHoursOfSleep.asTimeInterval() - timeReadyForBed.asTimeInterval())
        let days = 1...5
        return WakeUp.notificationForWakeUp(time, message: goToBedText, days: days, userInfo: WakeUp.goToBedValue,repeatOnlyWeekdays: repeatOnlyWeekdays)
    }
    
    static func notificationForWakeUp(time: NSDate, message: String, days: Range<Int>, userInfo: String, repeatOnlyWeekdays: Bool = true) -> [UILocalNotification] {
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
                return notificationForOneDay(weekdayTime, message: message, interval: NSCalendarUnit.WeekOfYear, userInfo: userInfo)
            }
            return notifications
            
        } else {
            return [notificationForOneDay(time, message: message, interval: NSCalendarUnit.Day, userInfo: userInfo)]
        }
    }
    
    
    static func notificationForOneDay(time: NSDate, message: String, interval: NSCalendarUnit, userInfo: String) -> UILocalNotification {
        let notification = UILocalNotification()
        notification.fireDate = time
        notification.alertBody = message
        notification.alertAction = "Happy wake up"
        // TODO needs attribution to https://www.freesound.org/people/FoolBoyMedia/sounds/246390/
        // more https://www.freesound.org/people/Corsica_S/sounds/321389/
        // https://www.freesound.org/people/mareproduction/sounds/324156/
        notification.soundName = "246390__foolboymedia__chiming-out.wav"
        notification.repeatInterval = interval
        notification.userInfo = [WakeUp.notificationUserInfoKey: userInfo]
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
