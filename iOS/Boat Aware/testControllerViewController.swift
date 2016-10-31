//
//  testControllerViewController.swift
//  ThriveIOSPrototype
//
//  Created by Dave Butz on 1/11/16.
//  Copyright © 2016 Dave Butz. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class testControllerViewController: UIViewController {

    @IBOutlet weak var imgWifi: UIImageView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblInstructions: UILabel!
    var backgroundTaskTimer = NSTimer();
    var backgroundTask = UIBackgroundTaskIdentifier();
    var currentSSID = NSString();
    
    var networkNamePrefix = "BOATAWARE";
    var boolChangingWifi : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wifialert:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil);
        
        UIApplication.sharedApplication().registerUserNotificationSettings(wifialert);
        self.scheduleBackgroundTask();
        
        btnContinue.hidden = true;
        // Do any additional setup after loading the view.
        lblInstructions.text = "Please wait while we test the connectivity...";
        let loading = LoadingView(frame: self.view.frame)
        loading.setCaption("Testing Connectivity. This may take a few seconds...")
        
        let JSONObject: [String : AnyObject] = [
            "apicall" : "finishingconnectivity"
        ]
        let api = APICalls();
        api.apicallout("/api/setupwifi/initialsynctoproductionsender" , iptype: "thriveIPAddress", method: "POST", JSONObject: JSONObject, callback: { (response) -> () in
            
            //handle the response. i should get status : fail/success and message: various
            let success = (response as! NSDictionary)["success"] as! Bool;
            if(success){
                dispatch_async(dispatch_get_main_queue(),{
                    self.scheduleBackgroundTask();
                    self.lblInstructions.text = "Succesfully tested connectivity. Change your WiFi back.";
                });
            }
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
    
    @IBAction func btnStartMonitoringOnClick(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(),{
            let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
            appdel.my_remo_selected = nil;
            ApplicationFunctions.switchViewRegister(self, viewtoswitch: "viewLoadingApp")
        });
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
                self.imgWifi.hidden = true;
                self.lblInstructions.text = "Everything is ready to go!";
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
