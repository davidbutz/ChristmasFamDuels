//
//  joinLeagueViewController.swift
//  Christmas Fam Duels
//
//  Created by Dave Butz on 11/3/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class joinLeagueViewController: UIViewController {

    @IBOutlet weak var txtLeagueName: UITextField!
    
    let api = APICalls();
    let JSONObject: [String : AnyObject] = [
        "login_token" : ApplicationVariables.applicationvariables.logintoken ]
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    let appvar = ApplicationVariables.applicationvariables;
    
    @IBAction func onClickJoinLeague(sender: AnyObject) {
        let leagueName = txtLeagueName.text;
        onClickXYZ(leagueName!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!);
    }
    
    func onClickXYZ(leagueName:String){
        
        api.apicallout("/api/setup/league/findinvitation/" + appvar.userid + "/" + leagueName + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            
            let success = (response as! NSDictionary)["success"] as! Bool;
            if(success){
                // not only did it find it... but it added them... take them to viewLaunch..
                dispatch_async(dispatch_get_main_queue()) {
                    let inviteFriends = self.storyboard?.instantiateViewControllerWithIdentifier("viewLoadingApp");
                    self.presentViewController(inviteFriends!, animated: true, completion: nil);
                }
            }
            else{
                // display a nice message...
                self.displayAlert("Could not find an Invitation to that league.", fn: {self.doNothing()});
                return;
            }
        });

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
