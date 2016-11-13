//
//  emailInvitationsViewController.swift
//  Christmas Fam Duels
//
//  Created by Dave Butz on 10/30/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class emailInvitationsViewController: FormViewController {

    
    @IBOutlet weak var txtemail1: UITextField!
    
    @IBOutlet weak var txtemail2: UITextField!
    
    @IBOutlet weak var txtemail3: UITextField!
    
    @IBOutlet weak var txtemail4: UITextField!
    
    @IBOutlet weak var txtemail5: UITextField!
    
    @IBOutlet weak var onclickSendInvitations: UIButton!
    
    @IBAction func onClickSendInvites(sender: AnyObject) {
        LoadingOverlay.shared.showOverlay(self.view);
        LoadingOverlay.shared.setCaption("Sending out Invitations...");
        let api = APICalls();
        let appvar = ApplicationVariables.applicationvariables;
        let leaguevar = LeagueVariables.leaguevariables;
        
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        
        //build up the email lists.
        var email = "";
        if(!(txtemail1.text?.isEmpty)!){
            email += txtemail1.text! + ";";
        }
        if(!(txtemail2.text?.isEmpty)!){
            email += txtemail2.text! + ";";
        }
        if(!(txtemail3.text?.isEmpty)!){
            email += txtemail3.text! + ";";
        }
        if(!(txtemail4.text?.isEmpty)!){
            email += txtemail4.text! + ";";
        }
        if(!(txtemail5.text?.isEmpty)!){
            email += txtemail5.text! + ";";
        }
        ///api/setup/league/invite/:userID/:leagueID/:email/:logintoken
        api.apicallout("/api/setup/league/invite/" + appvar.userid + "/" + leaguevar.leagueID + "/" + email + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                LoadingOverlay.shared.hideOverlayView();
            };
            let JSONResponse = response as! JSONDictionary;
            if(JSONResponse["success"] as! Bool){
                /*let leagueID = JSONResponse["leagueID"] as! String;
                let leagueName = JSONResponse["leagueName"] as! String;
                let leagueOwnerID = JSONResponse["leagueOwnerID"] as! String;
                //store these deep.
                let leaguevar = LeagueVariables.leaguevariables;
                leaguevar.leagueID = leagueID;
                leaguevar.leagueName = leagueName;
                leaguevar.leagueOwnerID = leagueOwnerID;
                */
                //move them along to game play
                dispatch_async(dispatch_get_main_queue()) {
                    let inviteFriends = self.storyboard?.instantiateViewControllerWithIdentifier("viewLaunch");
                    self.presentViewController(inviteFriends!, animated: true, completion: nil);
                }
            }
        });
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == txtemail1) {
            txtemail2.becomeFirstResponder()
        } else if (textField == txtemail2) {
            txtemail3.becomeFirstResponder()
        } else if (textField == txtemail3) {
            txtemail4.becomeFirstResponder();
        } else if (textField == txtemail4) {
            txtemail5.becomeFirstResponder();
        } else if (textField == txtemail5) {
            // TODO Submit/Login
            onClickSendInvites(textField);
        }
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtemail1.resignFirstResponder();
        txtemail2.resignFirstResponder();
        txtemail3.resignFirstResponder();
        txtemail4.resignFirstResponder();
        txtemail5.resignFirstResponder();
        
        definesPresentationContext = true;
        // Do any additional setup after loading the view.
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
