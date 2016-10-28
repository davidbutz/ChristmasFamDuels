//
//  forgotPassword.swift
//  Boat Aware
//
//  Created by Dave Butz on 6/13/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class ForgotPasswordFormViewController: FormViewController {

    @IBOutlet weak var btnSendReset: UIButton!
   @IBOutlet weak var txtEmail: UITextField!

    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        //self.txtEmail.delegate = self;

        txtEmail.resignFirstResponder();
        
        definesPresentationContext = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        if (textField == txtEmail) {
//            self.txtEmail.becomeFirstResponder()
//        }
//        else {
//            self.view.endEditing(true);
//        }
//        return true;
//    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == txtEmail) {
            self.txtEmail.becomeFirstResponder()
        }
//        else if (textField == txtpassword) {
//            // TODO Submit/Login
//            btnLoginClick(textField);
//        }
        return true
    }
    

    
    @IBAction func onPushbtnReset(sender: AnyObject) {
        //validate something was entered
        let userEmail = txtEmail.text;
        if(userEmail!.isEmpty){
            displayAlert("Email address is required.", fn: {self.doNothing()});
            return;
        }
        else {
            let appvar = ApplicationVariables.applicationvariables;
            //check to see if the long term storage contains at least one controller registered. if not ; seque to the add controller screen.
            let JSONObject: [String : AnyObject] = [
                "login_token" : appvar.logintoken ]
            let api = APICalls();
            api.apicallout("/api/accounts/resetpassword/" + userEmail! , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
                
                var alertMessage = "";
                let responseJSON = response as! Dictionary<String,AnyObject>;
                if let status = responseJSON["status"] as? String{
                    if (status=="success"){
                        alertMessage += "Password reset has been sent. This may take 10 minutes to reach your mail server.";
                    }
                    else {
                        alertMessage += "There was an issue changing your password. Confirm you have entered a valid email and try again.";
                    }
                }
                else{
                    alertMessage += "There is an issue with the program";
                }
                self.self.displayAlert(alertMessage, fn: {self.doNothing()});
                dispatch_async(dispatch_get_main_queue()
                    , { () -> Void in
                        //self.displayAlert(alertMessage, fn: {self.doNothing()});
                        let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("viewLaunch");
                        self.presentViewController(settingview!, animated: true, completion: nil);
                });
            });
        }
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
