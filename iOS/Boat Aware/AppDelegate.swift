//
//  AppDelegate.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/8/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    var my_remo_selected:JSONDictionary?;

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let defaults = NSUserDefaults.standardUserDefaults();
        //defaults.setValue("https://api.boataware.com", forKey: "localIPAddress");
        defaults.setValue("http://192.168.0.122:1337", forKey: "localIPAddress");
        defaults.setValue("http://192.168.42.1:1337", forKey: "thriveIPAddress");
        //defaults.setValue("http://api.thriveengineering.com", forKey: "localIPAddress");
        defaults.synchronize();
        
        
        // TODO store login token in NSUserDefaults
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewControllerWithIdentifier("viewLoadingApp") as UIViewController
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = initialViewControlleripad
        self.window?.makeKeyAndVisible()

        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        
        // Override point for customization after application launch.
        return true
        
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        print("Launched with URL: \(url.absoluteString)");
        // Handle reset password link.
        // user is coming to app from the reset password link email.
        // validate token and then send them to the reset password UIViewController.
        let userDict = self.urlPathToDictionary(url.absoluteString);
        let appvar = ApplicationVariables.applicationvariables;
        if let token = userDict!["token"] {
            appvar.resettoken = token;
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewControllerWithIdentifier("resetPassword") as UIViewController
            //initialViewControlleripad.token
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
        }
        //Do something with the information in userDict
        print(userDict);
        return true
    }
    
    
    func urlPathToDictionary(path:String) -> [String:String]? {
        //Get the string everything after the :// of the URL.
        let stringNoPrefix = path.componentsSeparatedByString("://").last
        //Get all the parts of the url
        if var parts = stringNoPrefix?.componentsSeparatedByString("/") {
            //Make sure the last object isn't empty
            if parts.last == "" {
                parts.removeLast()
            }
            if parts.count % 2 != 0 { //Make sure that the array has an even number
                return nil
            }
            var dict = [String:String]()
            var key:String = ""
            //Add all our parts to the dictionary
            for (index, part) in parts.enumerate() {
                if index % 2 != 0 {
                    key = part
                } else {
                    dict[key] = part
                }
            }
            return dict
        }
        return nil
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData){
        //send this device token to server
        print("DEVICE TOKEN!");
        print("\(deviceToken)");
        //manipulating token. AWS doesnt use the leading < or trailing > nor spaces in it's use of the token.
        //plus passing these along the API would be an issue..
        let deviceTokenString = String(deviceToken);
        var saveableDeviceToken = deviceTokenString.stringByReplacingOccurrencesOfString("<", withString: "");
        saveableDeviceToken = saveableDeviceToken.stringByReplacingOccurrencesOfString(">", withString: "");
        saveableDeviceToken = saveableDeviceToken.stringByReplacingOccurrencesOfString(" ", withString: "");
        //save the token on the iOS device for later retrieval...
        NSUserDefaults.standardUserDefaults().setObject(saveableDeviceToken, forKey: "deviceToken");
        NSUserDefaults.standardUserDefaults().synchronize();
        if let savedDeviceToken = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken") {
            print(savedDeviceToken);
        }
    }
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

