//
//  RegisterPageViewController.swift
//  ChristmasFanDuel
//
//  Created by Dave Butz on 12/1/15.
//  Copyright © 2015 Dave Butz. All rights reserved.
//

import UIKit

class RegisterPageViewController: FormViewController
{
    
    @IBOutlet weak var txtemail: UITextField!
    @IBOutlet weak var txtfirstname: UITextField!
    @IBOutlet weak var txtlastname: UITextField!
    @IBOutlet weak var txtpassword: UITextField!
    @IBOutlet weak var txtpasswordrepeat: UITextField!

    @IBOutlet weak var txtcell: UITextField!
    
    var registered = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.txtemail.delegate = self;
        self.txtpassword.delegate = self;
        self.txtcell.delegate = self;
        self.txtlastname.delegate = self;
        self.txtfirstname.delegate = self;
        self.txtpasswordrepeat.delegate = self;
        
        txtpassword.resignFirstResponder();
        txtcell.resignFirstResponder();
        txtpasswordrepeat.resignFirstResponder();
        txtlastname.resignFirstResponder();
        txtfirstname.resignFirstResponder();

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.txtemail) {
            self.txtfirstname.becomeFirstResponder()
        }
        else if (textField == self.txtfirstname) {
            self.txtlastname.becomeFirstResponder()
        }
        else if (textField == self.txtlastname) {
//            self.txtaccount.becomeFirstResponder()
            self.txtpassword.becomeFirstResponder()
        }
        else if (textField == self.txtcell) {
            self.txtpassword.becomeFirstResponder()
        }
        else if (textField == self.txtpassword) {
            self.txtpasswordrepeat.becomeFirstResponder()
        }
        else if (textField == self.txtpasswordrepeat) {
            btnRegisterOnClick(textField)
        }
        else {
            self.view.endEditing(true);
        }
        return false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnRegisterOnClick(sender: AnyObject) {
        let userEmail = txtemail.text;
        let userFirstName = txtfirstname.text;
        let userLastName = txtlastname.text;
        let userPassword = txtpassword.text;
        let userPasswordRepeat = txtpasswordrepeat.text;
        var userCell = txtcell.text;
        
        //Cleanse the cell so that it works with the AWS SMS Text options (format must be: +4102186131)
        userCell = userCell!.stringByReplacingOccurrencesOfString("(",withString: "");
        userCell = userCell!.stringByReplacingOccurrencesOfString(")",withString: "");
        userCell = userCell!.stringByReplacingOccurrencesOfString(" ", withString: "");
        userCell = userCell!.stringByReplacingOccurrencesOfString("-", withString: "");
        userCell = "+" + userCell!;
        
        let required : [String: UITextField] = [
            "Email Address": txtemail,
            "First Name": txtfirstname,
            "Last Name": txtlastname,
            "Password": txtpassword,
            "Password (2)": txtpasswordrepeat
        ];
        
        for (name, field) in required {
            if (field.text!.isEmpty) {
                displayAlert("\(name) is required", title: "Required Field", handler: {
                    () in
                    field.becomeFirstResponder();
                })
                return;
   
            }
        }
        

        var lowerCaseLetter = false;
        var upperCaseLetter = false;
        if(userPassword?.characters.count >= 7){
            for c in (userPassword?.characters)!
            {
                if(!lowerCaseLetter)
                {
                    let str = String(c)
                    if str.lowercaseString == str {
                        lowerCaseLetter = true;
                    }
                }
                if(!upperCaseLetter)
                {
                    let str = String(c)
                    if str.uppercaseString == str {
                        upperCaseLetter = true;
                    }
                }
            }
                    
            if(lowerCaseLetter && upperCaseLetter)
            {
                //do what u want
            }
            else {
                displayAlert("Passwords must contain 1 upper case and 1 lower case character", title: "Password Complexity");
                return;
            }
        }
        else{
            displayAlert("Passwords must be at least 7 characters long", title: "Password Complexity");
            return;
        }

        if(userPassword != userPasswordRepeat){
            displayAlert("Passwords do not match", title: "Password Verification");
            return;
        }
        
        LoadingOverlay.shared.showOverlay(self.view);
        LoadingOverlay.shared.setCaption("Creating Account...");

        let api = APICalls();
        api.register(userEmail!, password: userPassword!, fname: userFirstName!, lname: userLastName!, cell: userCell!) { (response:APIResponse) in
            // Register Handler
            if (response.success) {
            
                // Registration successful
                LoadingOverlay.shared.setCaption("Logging In...");
                api.login(userEmail!, password: userPassword!) { (loginResponse: APIResponse) in
                    if (loginResponse.success) {
                        
                        // Login successful
                        
                        // Now handle the situation where the invitationtoken is present and lets add this user to the league.
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        if(appDelegate.invitationToken != ""){
                            //
                            let appvar = ApplicationVariables.applicationvariables;
                            let JSONObject: [String : AnyObject] = [
                                "login_token" : appvar.logintoken ]

                            api.apicallout("/api/setup/acceptinvite/" + appvar.userid + "/" + appDelegate.invitationToken + "/" + userEmail! , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in

                                let JSONResponse = response as! JSONDictionary;
                                if(JSONResponse["success"] as! Bool){
                                    api.apicallout("/api/accounts/getleagues/" + appvar.userid + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (leagueresponse) -> () in
                                        
                                        dispatch_async(dispatch_get_main_queue()) {
                                            LoadingOverlay.shared.hideOverlayView();
                                        };
                                        var leaguecount = 0;
                                        let success = (leagueresponse as! NSDictionary)["success"] as! Bool;
                                        if let responseleaguecount = (leagueresponse as! NSDictionary)["leagueCount"] as! NSNumber?{
                                            leaguecount = Int(responseleaguecount);
                                        }
                                        if(success){
                                            if(leaguecount == 0){
                                                let leagueArray = (leagueresponse as! NSDictionary)["leagueCount"] as! JSONArray;
                                                let leagueInformation = leagueArray[0] as! JSONDictionary;
                                                let leagueName = leagueInformation["leagueName"] as! String;
                                                let leagueID = leagueInformation["leagueID"] as! String;
                                                let leagueOwnerID = leagueInformation["leagueOwnerID"] as! String;
                                                let roleID = leagueInformation["roleID"] as! NSNumber;
                                                
                                                let leaguevar = LeagueVariables.leaguevariables;
                                                leaguevar.leagueID = leagueID;
                                                leaguevar.leagueName = leagueName;
                                                leaguevar.leagueOwnerID = leagueOwnerID;
                                                leaguevar.roleID = roleID;
                                                
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
                                else{
                                    dispatch_async(dispatch_get_main_queue()) {
                                        //self.displayAlert("Successfully authenticated", fn: {self.switchView("viewLaunch")});
                                        let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("createLeague");
                                        self.presentViewController(settingview!, animated: true, completion: nil)
                                    }
                                }
                            });

                        }
                        else{
                            dispatch_async(dispatch_get_main_queue()) {
                                //self.displayAlert("Successfully authenticated", fn: {self.switchView("viewLaunch")});
                                let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("createLeague");
                                self.presentViewController(settingview!, animated: true, completion: nil)
                            }
                        }
                    } else {
                        let myAlert = UIAlertController(title:"Login Failed",message: "No account was found with that username and password combination",preferredStyle: UIAlertControllerStyle.Alert);
                        let okAction = UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in ()});
                        myAlert.addAction(okAction);
                        dispatch_async(dispatch_get_main_queue()) {
                            self.presentViewController(myAlert, animated: true, completion: nil);
                        };
                        if let message = loginResponse.data!["message"] {
                            print("Login Failure: \(message)");
                        }
                    }                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    LoadingOverlay.shared.hideOverlayView();
                };
                
                var alertMessage = "Error during registration";
                if let err = response.error {
                    alertMessage = err.description;
                }
                if let message = response.data!["message"] {
                    alertMessage = message as! String;
                }

                let myAlert = UIAlertController(title:"Registration Failed",message: alertMessage,preferredStyle: UIAlertControllerStyle.Alert);
                let okAction = UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in ()});
                myAlert.addAction(okAction);
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(myAlert, animated: true, completion: nil);
                };
            }

        }
    }


    func displayAlert(userMessage:String, title: String = "Alert", handler:(() -> Void)? = nil){
        let myAlert = UIAlertController(title:title,message: userMessage,preferredStyle: UIAlertControllerStyle.Alert);
        let okAction = UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction!) in
            handler?();
        });
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated: true, completion: nil);
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
