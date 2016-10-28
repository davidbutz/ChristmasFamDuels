//
//  SetUpWifiViewController.swift
//  ChristmasFanDuel
//
//  Created by Dave Butz on 1/2/16.
//  Copyright © 2016 Dave Butz. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class SetUpWifiViewController: UIViewController {

    //outlets
    @IBOutlet weak var lblConnected: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet var lblInstructions: UILabel!
    @IBOutlet var imgWifi: UIImageView!
    
    //vars
    var backgroundTaskTimer = NSTimer();
    var backgroundTask = UIBackgroundTaskIdentifier();
    var currentSSID = NSString();
    var networkNamePrefix = "BOATAWARE";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Here i am going to register some notifications.
        // We will use the notifications to communicate back to user when the ThriveXXXXXX network has been 'joined'
        
        //let types:UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge;
        let wifialert:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil);
        
        UIApplication.sharedApplication().registerUserNotificationSettings(wifialert);
        self.scheduleBackgroundTask();
        lblConnected.hidden = true;
        btnContinue.hidden = true;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        self.backgroundTaskTimer.invalidate();
        endBackgroundTask();
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    @IBAction func btnContinue(sender: AnyObject) {
        print("Button Continue Pressed");
        dispatch_async(dispatch_get_main_queue(),{
            //self.performSegueWithIdentifier("SetupSeq2", sender: self);
            //ApplicationFunctions.switchViewRegister(self, viewtoswitch: "testWifiSetUp")
        });
        //ApplicationFunctions.switchViewRegister(self,viewtoswitch: "SetUpController")
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
                if (currentSSID.length > networkPrefix.length) {
                    if(currentSSID.length > networkPrefix.length && currentSSID.substringToIndex(networkPrefix.length)==networkPrefix){
                        returnval = true;
                    }
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
                
                //swap out the instructions for congratulations
                lblConnected.hidden = false;
                btnContinue.hidden = false;
                lblInstructions.hidden = true;
                imgWifi.hidden = true;
                
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
