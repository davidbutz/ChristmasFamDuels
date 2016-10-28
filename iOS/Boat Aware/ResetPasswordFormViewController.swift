//
//  resetPassword.swift
//  Boat Aware
//
//  Created by Dave Butz on 6/13/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class ResetPasswordFormViewController: FormViewController {


    @IBOutlet var txtPassword1: UITextField!
    
    @IBOutlet var txtPassword2: UITextField!
    
    @IBOutlet var btnReset: UIButton!
    
    var token = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtPassword1.delegate = self;
        self.txtPassword2.delegate = self;
        
        txtPassword1.resignFirstResponder();
        txtPassword2.resignFirstResponder();
        definesPresentationContext = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.txtPassword1) {
            self.txtPassword1.becomeFirstResponder()
        }
        else if (textField == self.txtPassword1) {
            btnResetOnClick(textField)
        }
        else {
            self.view.endEditing(true);
        }
        return false;
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
    
    @IBAction func btnResetOnClick(sender: AnyObject) {
        

        let userPassword = txtPassword1.text;
        let userPasswordRepeat = txtPassword2.text;
        
        let required : [String: UITextField] = [
            "Password": txtPassword1,
            "Password (2)": txtPassword2
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

        let appvar = ApplicationVariables.applicationvariables;
        //check to see if the long term storage contains at least one controller registered. if not ; seque to the add controller screen.
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken,
            "token": appvar.resettoken,
            "password": userPassword!]
        let api = APICalls();
        api.apicallout("/api/accounts/changepassword" , iptype: "localIPAddress", method: "POST", JSONObject: JSONObject, callback: { (response) -> () in
            
            var alertMessage = "";
            let responseJSON = response as! Dictionary<String,AnyObject>;
            if let status = responseJSON["status"] as? String{
                if (status=="success"){
                    alertMessage += "Password successfully reset. Please log in.";
                }
                else {
                    alertMessage += "There was an issue changing your password.";
                }
            }
            else{
                alertMessage += "There is an issue with the program";
            }
            
            //reload?
            dispatch_async(dispatch_get_main_queue()
                , { () -> Void in
                    //set appvar.resettoken to fake,
                    appvar.resettoken = "fake";
                    //the NSUserDefaults.standardUserDefaults().setObject(password, forKey: "userPassword");
                    NSUserDefaults.standardUserDefaults().setObject(userPassword, forKey: "userPassword")
                    //and potentially just log then in?
                    print("reloading login view.");
                    ApplicationFunctions.globaldisplayAlert(self, userMessage: alertMessage, fn: {
                        //ApplicationFunctions.switchView(self,viewtoswitch: "viewLogin")
                        let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("viewLaunch");
                        self.presentViewController(settingview!, animated: true, completion: nil);
                    })
            });
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
