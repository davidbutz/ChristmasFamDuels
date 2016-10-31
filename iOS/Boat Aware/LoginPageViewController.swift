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
//        
//        let attachmentImg = NSTextAttachment();
//        attachmentImg.image = UIImage(named: "arrow-right");
//        let attachmentString = NSAttributedString(attachment: attachmentImg);
//        let registerString = NSMutableAttributedString(string: "Don't have an account? Sign up");
//        registerString.appendAttributedString(attachmentString);
//        btnRegister.setAttributedTitle(registerString, forState: UIControlState.Normal);
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
                
                //let api = APICalls()
                api.apicallout("/api/accounts/registeredcontrollers/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in

                    dispatch_async(dispatch_get_main_queue()) {
                        LoadingOverlay.shared.hideOverlayView();
                    };
                    
                    let usercontrollers = Controllers(controllers: response as! Dictionary<String,AnyObject>);
                    for(_,controllerarray) in (usercontrollers?.controllers)!{
                        let arry = controllerarray as! Array<Dictionary<String, AnyObject>> as Array;
                        if(arry.count==0){
                            dispatch_async(dispatch_get_main_queue()) {
                                //self.displayAlert("Successfully authenticated", fn: {self.switchView("viewLaunch")});
                                let setupRemo = self.storyboard?.instantiateViewControllerWithIdentifier("setupRemo");
                                self.presentViewController(setupRemo!, animated: true, completion: nil)
                            }

                            return;
                        }
                        else{
                            //TODO: get the last remo used on this machine ....
                            AppRemoList.appremoList = arry;
                            let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
                            appdel.my_remo_selected = AppRemoList.appremoList[0];
                            
                        }
                    }
                    
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.displayAlert("Successfully authenticated", fn: {self.switchView("viewLaunch")});
                        let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("viewLaunch");
                        self.presentViewController(settingview!, animated: true, completion: nil)
                    }
                    
                });
            } else {
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
    
//    override func shouldAutorotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) -> Bool {
//        return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
//    }
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
