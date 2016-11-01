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
        LoadingOverlay.shared.showOverlay(self.view);
        LoadingOverlay.shared.setCaption("Authenticating...");
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
                        
                        api.apicallout("/api/setup/getleagues/" + appvar.userid  + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (leagueresponse) -> () in
                            
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                LoadingOverlay.shared.hideOverlayView();
                            };
                            let leaguesuccess = (leagueresponse as! NSDictionary)["success"] as! Bool;
                            let leaguecount = (leagueresponse as! NSDictionary)["leagueCount"] as! NSNumber;
                            if(leaguesuccess){
                                if(leaguecount == 1){
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
                                        self.handleViewAppearance("viewLaunch");
                                    }
                                }
                                else {
                                    print("They have more than one league and I dont handle that right now...")
                                }
                            }
                            else{
                                //They signed in, but dont have any league(s) properly set up.
                                print("They signed in, but dont have any league(s) properly set up.")
                            }
                        });
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue()) {
                            LoadingOverlay.shared.hideOverlayView();
                        };
                        //the token is not valid, or has expired. They need to login again.
                        dispatch_async(dispatch_get_main_queue()) {
                            self.handleViewAppearance("viewLogin");
                        }
                    }
                });
            }
            else{
                //check for login here..
                dispatch_async(dispatch_get_main_queue()) {
                    LoadingOverlay.shared.hideOverlayView();
                };
                if(appvar.logintoken == "fake"){
                    handleViewAppearance("viewLogin");
                }
            }
        }
        else{
            //check for login here..
            dispatch_async(dispatch_get_main_queue()) {
                LoadingOverlay.shared.hideOverlayView();
            };
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
}
