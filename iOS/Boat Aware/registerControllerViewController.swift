//
//  registerControllerViewController.swift
//  ChristmasFanDuel
//
//  Created by Dave Butz on 1/10/16.
//  Copyright © 2016 Dave Butz. All rights reserved.
//

import UIKit

class registerControllerViewController: UIViewController {

    
    @IBOutlet weak var txtControllerName: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnRegisterClick(sender: AnyObject) {
        //I should be connected to the Thrive Network. (192.168.41.1)
        //A known IP address.
        //I need to POST a response to /api/register/controller
        //TODO: handle blank controllername
        let appvar = ApplicationVariables.applicationvariables;
        let controller_name = txtControllerName.text;
        let JSONObject: [String : AnyObject] = [
            "userid" : appvar.userid ,
            "account_id" : appvar.account_id,
            "fname" : appvar.fname,
            "lname" : appvar.lname,
            "password" : appvar.password,
            "account_name" : appvar.account_name,
            "username" : appvar.username,
            "cellphone" :  appvar.cellphone,
            "controller_name" : controller_name!
        ]
        let api = APICalls();
        api.apicallout("/api/register/controller" , iptype: "thriveIPAddress", method: "POST", JSONObject: JSONObject, callback: { (response) -> () in
            
            //handle the response. i should get status : fail/success and message: various
            let status = (response as! NSDictionary)["status"] as! String;
            let message = (response as! NSDictionary)["message"] as! String;
            print(message);
            if(status=="success"){
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("SetupSeq3New", sender: self);
                });
            }
            else{
                print(message);
            }
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
