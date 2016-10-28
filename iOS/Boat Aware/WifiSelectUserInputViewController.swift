//
//  WifiSelectUserInputViewController.swift
//  Boat Aware
//
//  Created by Dave Butz on 6/29/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class WifiSelectUserInputViewController: FormViewController {
    @IBOutlet weak var lblSSID: UILabel!

    @IBOutlet weak var btnConnect: UIButton!

    @IBOutlet weak var txtSSID: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    var wifissid : String = "";
    var wifiList : JSONArray = []
    var wifisecurity : String = "";
    var boolChangingWifi : Bool = false;
    var backgroundTaskTimer = NSTimer();
    var backgroundTask = UIBackgroundTaskIdentifier();
    let appvar = ApplicationVariables.applicationvariables;
    var connectionAttempts : Int = 0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtSSID.hidden = true;
        self.txtPassword.hidden = true;
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if(wifissid=="Other..."){
            dispatch_async(dispatch_get_main_queue(),{
                self.txtSSID.hidden = false;
                self.lblSSID.text = "Enter your Credentials";
                self.txtPassword.hidden = false;
            });
        }
        else{
            self.lblSSID.text = wifissid;
            if wifisecurity == "" {
                self.txtSSID.hidden = true;
                self.txtPassword.hidden = true;
                //REALLY NEED TO PUSH THEM TO THE NEXT PHASE>>>..
                dispatch_async(dispatch_get_main_queue(),{
                    self.txtSSID.hidden = true;
                    self.txtPassword.hidden = true;
                });
            }
            else {
                self.txtSSID.hidden = true;
                self.txtPassword.hidden = false;
                dispatch_async(dispatch_get_main_queue(),{
                    self.txtSSID.hidden = true;
                    self.txtPassword.hidden = false;
                });
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == txtSSID) {
            txtSSID.becomeFirstResponder()
        } else if (textField == txtPassword) {
            //txtPassword.becomeFirstResponder()
            btnConnect_onClick(self);
        }
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func scheduleTestWiFiBackgroundTask(){
        self.backgroundTaskTimer.invalidate();
        self.backgroundTaskTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(WifiSelectUserInputViewController.testWifi), userInfo: nil, repeats: true);
        
        self.backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask);
        });
    }
    
    func testWifi(){
        let JSONObject: [String : AnyObject] = [
            "wifiname" : wifissid,
            "wifipassword" : txtPassword.text!
        ]
        let api = APICalls();
        api.apicallout("/api/setupwifi/testwifi" , iptype: "thriveIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            
            //handle the response. i should get status : fail/success and message: various
            let success = (response as! NSDictionary)["success"] as! Bool;
            if(success){
                self.endBackgroundTask();
                LoadingOverlay.shared.hideOverlayView();
                dispatch_async(dispatch_get_main_queue(),{
                    self.backgroundTaskTimer.invalidate();
                    self.endBackgroundTask();
                    ApplicationFunctions.switchViewRegister(self, viewtoswitch: "testWifiSetUp")
                });
            }
            else{
                self.connectionAttempts += 1;
                if(self.connectionAttempts>5){
                    self.backgroundTaskTimer.invalidate();
                    self.endBackgroundTask();
                    dispatch_async(dispatch_get_main_queue(),{
                        self.backgroundTaskTimer.invalidate();
                        self.endBackgroundTask();
                        self.displayAlert("Could not reach internet. Please try again",  fn: {self.doNothing()});
                        //let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("selectWifiSetUp");
                        //self.presentViewController(settingview!, animated: true, completion: nil);
                        ApplicationFunctions.globaldisplayAlert(self, userMessage: "Could not reach internet. Please try again.", fn: {ApplicationFunctions.switchViewRegister(self,viewtoswitch: "selectWiFiTableView")})
                    });
                }
            }
        });
    }
    
    func doNothing(){
        
    }
    
    func displayAlert(userMessage:String, fn:()->Void){
        let myAlert = UIAlertController(title:"Alert",message: userMessage,preferredStyle: UIAlertControllerStyle.Alert);
        let okAction = UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in fn()});
        myAlert.addAction(okAction);
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(myAlert, animated: true, completion: nil);
        };
    }
    
    @IBAction func btnConnect_onClick(sender: AnyObject) {
        
        let password = txtPassword.text;
        if(wifisecurity != "" && password!.isEmpty){
            ApplicationFunctions.globaldisplayAlert(self, userMessage: "Password is required.", fn: {});
            return;
        }
        if(wifissid=="Other..."){
            if(txtSSID.text!.isEmpty){
                ApplicationFunctions.globaldisplayAlert(self, userMessage: "Network Name is required.", fn: {});
                return;
            }
            wifissid = txtSSID.text!;
        }
        let JSONObject: [String : AnyObject] = [
            "wifiname" : wifissid,
            "wifipassword" : txtPassword.text!
        ]
        LoadingOverlay.shared.showOverlay(self.view);
        LoadingOverlay.shared.setCaption("Setting WiFi, this takes a few seconds...");
        let api = APICalls();
        api.apicallout("/api/setupwifi/setwifi" , iptype: "thriveIPAddress", method: "POST", JSONObject: JSONObject, callback: { (response) -> () in
            
            //handle the response. i should get status : fail/success and message: various
            let success = (response as! NSDictionary)["success"] as! Bool;
            if(success){
                // keep testing the wifi connection until we get it to establish.
                // if connection fails after 4-5 attempts... have a notice back to the end-user
                dispatch_async(dispatch_get_main_queue(),{
                    self.scheduleTestWiFiBackgroundTask();
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(),{
                    //This shouldnt happen. There is some collosal error.
                    ApplicationFunctions.globaldisplayAlert(self, userMessage: "WiFi did not properly set. Try again.", fn: {ApplicationFunctions.switchViewRegister(self,viewtoswitch: "selectWiFiTableView")})
                });
            }
        });
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
