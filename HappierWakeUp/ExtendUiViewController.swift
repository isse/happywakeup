//
//  NotificationAlertController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 11/04/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showNotificationAlertViewController() {
        let alertController = UIAlertController(title: "Please enable notifications", message: "This doesn't really work without notifications. Please enable them first under settings.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
            
        }
        alertController.addAction(cancelAction)
        let destroyAction = UIAlertAction(title: "Go to Settings", style: .Default) { (action) in
            if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(settingsURL)
            }
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true) {

        }
    }
}