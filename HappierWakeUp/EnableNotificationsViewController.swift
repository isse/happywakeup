//
//  enableNotificationsViewController.swift
//  HappierWakeUp
//
//  Created by Essi Vehmersalo on 28/03/16.
//  Copyright © 2016 Essi Vehmersalo. All rights reserved.
//

import UIKit

class EnableNotificationsViewController: UIViewController {
    
    @IBAction func goToSettings(sender: AnyObject) {
        if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(settingsURL)
            dismissViewControllerAnimated(true){}
        } //TODO else. should check this before rendering the button
    }
    
    @IBAction func cancelEnableNotifications(sender: AnyObject) {
        dismissViewControllerAnimated(true){}

    }

}