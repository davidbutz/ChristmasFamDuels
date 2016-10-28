//
//  RemoChangeWifiViewController.swift
//  Boat Aware
//
//  Created by Dave Butz on 4/28/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class RemoChangeWifiViewController: UIViewController {

    //vars
    var window: UIWindow?
    var backgroundTaskTimer = NSTimer();
    var backgroundTask = UIBackgroundTaskIdentifier();
    var currentSSID = NSString();
    var networkNamePrefix = "BOATAWARE";
    
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let wifialert:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil);
        
        UIApplication.sharedApplication().registerUserNotificationSettings(wifialert);
        self.scheduleBackgroundTask();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCancel_OnClick(sender: AnyObject) {
        self.backgroundTaskTimer.invalidate();
        endBackgroundTask();
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewControllerWithIdentifier("viewLaunch") as UIViewController
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = initialViewControlleripad
        self.window?.makeKeyAndVisible()
    }
    @IBOutlet weak var btnCancel_onClick: UIBarButtonItem!
    func checkSparkDeviceWifiConnection(networkPrefix:NSString) -> Bool {
        var returnval = false;
        let interfaces:CFArray! = CNCopySupportedInterfaces()
        for i in 0..<CFArrayGetCount(interfaces){
            let interfaceName: UnsafePointer<Void>
                =  CFArrayGetValueAtIndex(interfaces, i)
            let rec = unsafeBitCast(interfaceName, AnyObject.self)
            let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)")
            if unsafeInterfaceData != nil {
                let interfaceData = unsafeInterfaceData! as Dictionary!
                currentSSID = interfaceData["SSID"] as! String
                if(currentSSID.length > networkPrefix.length && currentSSID.substringToIndex(networkPrefix.length)==networkPrefix){
                    returnval = true;
                }
            } else {
                currentSSID = ""
            }
        }
        return returnval
    }
    
    func checkDeviceConnectionForNotification(){
        NSLog("Background time remaining = %.1f seconds", UIApplication.sharedApplication().backgroundTimeRemaining);
        let state = UIApplication.sharedApplication().applicationState;
        if(state == UIApplicationState.Background || state == UIApplicationState.Inactive){
            if(checkSparkDeviceWifiConnection(networkNamePrefix) || checkSparkDeviceWifiConnection("THRIVE")){
                
                let localNotification = UILocalNotification();
                localNotification.alertAction = "Connected";
                let notifText = String(format: "Your phone has connected to %@. Tap to continue Setup.","BoatAware Network");
                localNotification.alertBody = notifText;
                localNotification.alertAction = "open"; // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                localNotification.soundName = UILocalNotificationDefaultSoundName; // play default sound
                let firewhen = NSDate.init(timeIntervalSinceNow: 0);
                localNotification.fireDate = firewhen;
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification);
                self.backgroundTaskTimer.invalidate();
                
                let seconds = 5.0;
                let delay = seconds * Double(NSEC_PER_SEC);
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay));
                
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    //Send them to the next step.
                    self.performSegueWithIdentifier("chosewifi", sender: self);
                });
                //Send them to the next step.
                //performSegueWithIdentifier("chosewifi", sender: self);
            }
        }
    }

    func scheduleBackgroundTask(){
        self.backgroundTaskTimer.invalidate();
        self.backgroundTaskTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(SetUpWifiViewController.checkDeviceConnectionForNotification), userInfo: nil, repeats: true);
        
        self.backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask);
        });
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "chosewifi") {
            //let vc = segue.destinationViewController as! selectwifiViewController
            //vc.boolChangingWifi = true;
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
