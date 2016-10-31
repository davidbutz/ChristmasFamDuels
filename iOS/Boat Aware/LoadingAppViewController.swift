//
//  LoadingAppViewController.swift
//  Boat Aware
//
//  Created by Dave Butz on 6/23/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class LoadingAppViewController: UIViewController {

    var window: UIWindow?
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults();
        let appvar = ApplicationVariables.applicationvariables;
        if let savedAuthenticationToken = defaults.stringForKey("authenticationtoken") {
            if(savedAuthenticationToken != ""){
                //i have a saved AuthToken. Check if it is still valid...
                let JSONObject: [String : AnyObject] = [
                    "login_token" : savedAuthenticationToken ]
                
                let api = APICalls()
                api.apicallout("/api/accounts/loginTokenValid/" + savedAuthenticationToken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
                    
                    let success = (response as! NSDictionary)["success"] as! Bool;
                    if(success){
                        //yes it is valid and good.
                        //need to populate the appvar information with data from the call.....
                        let appvar = ApplicationVariables.applicationvariables;
                        appvar.username = (response as! NSDictionary)["username"] as! String;
                        appvar.logintoken = (response as! NSDictionary)["authenticationtoken"] as! String;
                        appvar.userid = (response as! NSDictionary)["userid"] as! String;
                        appvar.account_id = (response as! NSDictionary)["account_id"] as! String;
                        appvar.fname = (response as! NSDictionary)["firstname"] as! String;
                        appvar.lname = (response as! NSDictionary)["lastname"] as! String;
                        appvar.account_name = (response as! NSDictionary)["account_name"] as! String;
                        appvar.password = (response as! NSDictionary)["password"] as! String;
                        appvar.cellphone = (response as! NSDictionary)["cellphone"] as! String;
                        let JSONObject: [String : AnyObject] = [
                            "login_token" : appvar.logintoken ]
                        
                        api.apicallout("/api/setup/getleagues/" + appvar.userid  + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
                            /*
                            
                            let usercontrollers = Controllers(controllers: response as! Dictionary<String,AnyObject>);
                            for(_,controllerarray) in (usercontrollers?.controllers)!{
                                let arry = controllerarray as! Array<Dictionary<String, AnyObject>> as Array;
                                if(arry.count==0){
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.handleViewAppearance("setupRemo");
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
                                    */
                            dispatch_async(dispatch_get_main_queue()) {
                                self.handleViewAppearance("viewLaunch");
                            }
                        });
                    
                    }
                    else{
                        //the token is not valid, or has expired. They need to login again.
                        dispatch_async(dispatch_get_main_queue()) {
                            self.handleViewAppearance("viewLogin");
                        }
                    }
                });
            }
            else{
                //check for login here..
                if(appvar.logintoken == "fake"){
                    handleViewAppearance("viewLogin");
                }
            }
        }
        else{
            //check for login here..
            if(appvar.logintoken == "fake"){
                handleViewAppearance("viewLogin");
            }
        }
    }
    
    func handleViewAppearance(viewToAppear: String){
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewControllerWithIdentifier(viewToAppear) as UIViewController
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = initialViewControlleripad
        self.window?.makeKeyAndVisible()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
