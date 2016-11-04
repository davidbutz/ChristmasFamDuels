//
//  createLeagueViewController.swift
//  Christmas Fam Duels
//
//  Created by Dave Butz on 10/28/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class createLeagueViewController: FormViewController {
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    
    @IBOutlet weak var txtLeagueName: UITextField!
    
    @IBAction func onClickCreate(sender: AnyObject) {
        let leaguename = txtLeagueName.text;
        if(leaguename!.isEmpty){
            displayAlert("League Name is required.", fn: {self.doNothing()});
            return;
        }
        
        LoadingOverlay.shared.showOverlay(self.view);
        LoadingOverlay.shared.setCaption("Creating League...");
        let api = APICalls();
        let appvar = ApplicationVariables.applicationvariables;
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        api.apicallout("/api/setup/league/create/" + appvar.userid + "/" + leaguename! + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                LoadingOverlay.shared.hideOverlayView();
            };
            let JSONResponse = response as! JSONDictionary;
            if(JSONResponse["success"] as! Bool){
                let leagueID = JSONResponse["leagueID"] as! String;
                let leagueName = JSONResponse["leagueName"] as! String;
                let leagueOwnerID = JSONResponse["leagueOwnerID"] as! String;
                //store these deep.
                let leaguevar = LeagueVariables.leaguevariables;
                leaguevar.leagueID = leagueID;
                leaguevar.leagueName = leagueName;
                leaguevar.leagueOwnerID = leagueOwnerID;
                leaguevar.roleID = 1;
                //move them along to invitations...
                dispatch_async(dispatch_get_main_queue()) {
                    let inviteFriends = self.storyboard?.instantiateViewControllerWithIdentifier("Invite Friends");
                    self.presentViewController(inviteFriends!, animated: true, completion: nil);
                }
            }
        });
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtLeagueName.resignFirstResponder();
        // Do any additional setup after loading the view.
        definesPresentationContext = true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == txtLeagueName) {
            onClickCreate(textField);
        }
        return true
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
