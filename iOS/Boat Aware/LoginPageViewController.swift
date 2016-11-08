//
//  LoginPageViewController.swift
//  ChristmasFanDuel
//
//  Created by Dave Butz on 12/1/15.
//  Copyright © 2015 Dave Butz. All rights reserved.
//

import UIKit

class LoginPageViewController: FormViewController {

    @IBOutlet weak var txtemail: UITextField!
    @IBOutlet weak var txtpassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtemail.resignFirstResponder();
        txtpassword.resignFirstResponder();
                
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let savedEmail = defaults.stringForKey("userEmail") {
            print(savedEmail) // Some String Value
            txtemail.text = savedEmail;
        }
        if let savedPassword = defaults.stringForKey("userPassword") {
            print(savedPassword) // Some String Value
            txtpassword.text = savedPassword;
        }
        
        definesPresentationContext = true;
        // Do any additional setup after loading the view.
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == txtemail) {
            txtpassword.becomeFirstResponder()
        } else if (textField == txtpassword) {
            // TODO Submit/Login
            btnLoginClick(textField);
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnLoginClick(sender: AnyObject) {
        let userEmail = txtemail.text;
        let userPassword = txtpassword.text;
        if(userEmail!.isEmpty || userPassword!.isEmpty){
            displayAlert("All fields are required.", fn: {self.doNothing()});
            return;
        }
        
        LoadingOverlay.shared.showOverlay(self.view);
        LoadingOverlay.shared.setCaption("Logging In...");

        let api = APICalls();
        api.login(userEmail!, password: userPassword!) { (response: APIResponse) in
            if (response.success) {
                // Login successful
                let appvar = ApplicationVariables.applicationvariables;
                let JSONObject: [String : AnyObject] = [
                    "login_token" : appvar.logintoken ]

                api.apicallout("/api/setup/getleagues/" + appvar.userid + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (leagueresponse) -> () in

                    dispatch_async(dispatch_get_main_queue()) {
                        LoadingOverlay.shared.hideOverlayView();
                    };
                    var leaguecount = 0;
                    let success = (leagueresponse as! NSDictionary)["success"] as! Bool;
                    if let responseleaguecount = (leagueresponse as! NSDictionary)["leagueCount"] as! NSNumber?{
                        leaguecount = Int(responseleaguecount);
                    }
                    if(success){
                        if(leaguecount == 1){
                            let leagueArray = (leagueresponse as! NSDictionary)["leagueCount"] as! JSONArray;
                            let leagueInformation = leagueArray[0] as! JSONDictionary;
                            let userxleagueID = leagueInformation["userxleagueID"] as! String;
                            let leagueName = leagueInformation["leagueName"] as! String;
                            let leagueID = leagueInformation["leagueID"] as! String;
                            let leagueOwnerID = leagueInformation["leagueOwnerID"] as! String;
                            let roleID = leagueInformation["roleID"] as! NSNumber;
                            
                            let leaguevar = LeagueVariables.leaguevariables;
                            leaguevar.leagueID = leagueID;
                            leaguevar.leagueName = leagueName;
                            leaguevar.leagueOwnerID = leagueOwnerID;
                            leaguevar.roleID = roleID;
                            leaguevar.userxleagueID = userxleagueID;
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                //self.displayAlert("Successfully authenticated", fn: {self.switchView("viewLaunch")});
                                let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("viewLaunch");
                                self.presentViewController(settingview!, animated: true, completion: nil)
                            }
                        }
                        else{
                            print("they belong to more than one league, which i dont handle");
                        }
                    }
                    else{
                        //There is something wrong,
                        if(leaguecount == 0){
                            //take them to add a league page.
                            dispatch_async(dispatch_get_main_queue()) {
                                //self.displayAlert("Successfully authenticated", fn: {self.switchView("viewLaunch")});
                                let setupRemo = self.storyboard?.instantiateViewControllerWithIdentifier("createLeague");
                                self.presentViewController(setupRemo!, animated: true, completion: nil)
                            }
                        }
                        else{
                            print("The login was ok, but there was more than one league and the success was false");
                        }
                    }

                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue()) {
                    LoadingOverlay.shared.hideOverlayView();
                };
                let myAlert = UIAlertController(title:"Login Failed",message: "No account was found with that username and password combination",preferredStyle: UIAlertControllerStyle.Alert);
                let okAction = UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in ()});
                myAlert.addAction(okAction);
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(myAlert, animated: true, completion: nil);
                };
                if let message = response.data!["message"] {
                    print("Login Failure: \(message)");
                }
            }
        }
    }
    
  
    func navToSettings(sender: UIBarButtonItem!) {
        let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("viewSettings");
        self.presentViewController(settingview!, animated: true, completion: nil);
    }
    
    func switchView(viewtoswitch:String){
        let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("viewNavigation");
        self.navigationController?.presentViewController(settingview!, animated: true, completion: nil);
    }
    
    func displayAlert(userMessage:String, fn:()->Void){
        let myAlert = UIAlertController(title:"Alert",message: userMessage,preferredStyle: UIAlertControllerStyle.Alert);
        let okAction = UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in fn()});
        myAlert.addAction(okAction);
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(myAlert, animated: true, completion: nil);
        };
    }
    
    func doNothing(){
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
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
