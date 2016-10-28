//
//  CancelWithBoatAwareNetworkViewController.swift
//  Boat Aware
//
//  Created by Dave Butz on 6/28/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class CancelWithBoatAwareNetworkViewController: UIViewController {

    var backgroundTaskTimer = NSTimer();
    var backgroundTask = UIBackgroundTaskIdentifier();
    var currentSSID = NSString();
    var window: UIWindow?
    @IBOutlet weak var lblInstructions: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    var networkNamePrefix = "BOATAWARE";
    var boolChangingWifi : Bool = false;
    
    @IBOutlet weak var imgwifi: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let wifialert:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil);
        
        UIApplication.sharedApplication().registerUserNotificationSettings(wifialert);
        self.scheduleBackgroundTask();
        
        btnContinue.hidden=true;
        // Do any additional setup after loading the view.
    }

    @IBAction func btnContinue_onClick(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewControllerWithIdentifier("viewLogin") as UIViewController
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
        });
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        return returnval;
    }
    func checkDeviceConnectionForNotification(){
        NSLog("Background time remaining = %.1f seconds", UIApplication.sharedApplication().backgroundTimeRemaining);
        let state = UIApplication.sharedApplication().applicationState;
        if(state == UIApplicationState.Background || state == UIApplicationState.Inactive){
            if(!checkSparkDeviceWifiConnection(networkNamePrefix)){
                let localNotification = UILocalNotification();
                localNotification.alertAction = "Connected";
                let notifText = String(format: "Your phone has disconnected from %@. Tap to continue Setup.","BoatAware Network");
                localNotification.alertBody = notifText;
                localNotification.alertAction = "open"; // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                localNotification.soundName = UILocalNotificationDefaultSoundName; // play default sound
                let firewhen = NSDate.init(timeIntervalSinceNow: 0);
                localNotification.fireDate = firewhen;
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification);
                self.backgroundTaskTimer.invalidate();
                self.btnContinue.hidden = false;
                self.imgwifi.hidden = true;
                self.lblInstructions.text = "You are now disconnected from the BoatAware network";
            }
        }
    }
    
    func scheduleBackgroundTask(){
        self.backgroundTaskTimer.invalidate();
        self.backgroundTaskTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(testControllerViewController.checkDeviceConnectionForNotification), userInfo: nil, repeats: true);
        
        self.backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask);
        });
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
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
