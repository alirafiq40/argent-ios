
//  AppDelegate.swift
//  paykloud-ios
//
//  Created by Sinan Ulkuatam on 2/9/16.
//  Copyright © 2016 Sinan Ulkuatam. All rights reserved.

import UIKit
import Stripe
import Firebase

let merchantID = "merchant.com.paykloud"

// DEV
// let firebaseUrl = Firebase(url:"https://demosandbox.firebaseio.com/api/v1")
// let apiUrl = "http://localhost:5001"

// PROD
let firebaseUrl = Firebase(url:"https://timekloud.firebaseio.com/api/v1")
let apiUrl = "http://dev.timekloud.io"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // Assign the init view controller of the app
    var viewController = AuthViewController()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Globally dark keyboard
        UITextField.appearance().keyboardAppearance = .Dark
        
        // Enable Stripe DEV
        // Stripe.setDefaultPublishableKey("pk_test_6MOTlPN5JrNS5dIN4DUeKFDA")

        // Enable STripe PROD
        Stripe.setDefaultPublishableKey("pk_live_9kfmn7pMRPKAYSpcf1Fmn266")

        // Enable push notifications
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            let settings = UIRemoteNotificationType.Alert.union(UIRemoteNotificationType.Badge).union(UIRemoteNotificationType.Sound)
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(settings)
        }

        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = viewController
        self.window!.backgroundColor = UIColor.blackColor()
        self.window!.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //viewController.pauseVideo()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //viewController.playVideo()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

