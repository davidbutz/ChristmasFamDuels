//
//  menuTableViewController.swift
//  Boat Aware
//
//  Created by Dave Butz on 3/3/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class menuTableViewController: UITableViewController {

    @IBOutlet var innerTableView: UITableView!

    @IBOutlet var mainTableView: UITableView!
    var window: UIWindow?
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell();
        cell.backgroundColor = UIColor.clearColor()
        if(indexPath.section<3){
            if(indexPath.section==0){
                cell = tableView.dequeueReusableCellWithIdentifier("static1", forIndexPath: indexPath)
                //cellview.text = "Christmas Fam Duels";
            }
            if(indexPath.section==1){
                cell = tableView.dequeueReusableCellWithIdentifier("static4", forIndexPath: indexPath)
            }
            if(indexPath.section==2){
                cell = tableView.dequeueReusableCellWithIdentifier("static5", forIndexPath: indexPath)
            }
        }
        
        return cell;
    }
    
    
    // MARK:  UITableViewDelegate Methods
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (indexPath.section == 0) {
            return false;
        }
        return true;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(indexPath.section==0){
            print("clicked logo");
        }
        
        if(indexPath.section==1){
            print("invite more friends");
            dispatch_async(dispatch_get_main_queue(), {
                //ApplicationFunctions.globaldisplayAlert(self, userMessage: "Controller Registered. Please set up Wifi connection", fn: {ApplicationFunctions.switchViewRegister(self,viewtoswitch: "viewChangeWifi")})
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewControllerWithIdentifier("Invite Friends") as UIViewController
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                self.window?.rootViewController = initialViewControlleripad
                self.window?.makeKeyAndVisible()
            });
            
        }
        
        
        //LeagueSetup
        if(indexPath.section==2){
            print("league setup");
            dispatch_async(dispatch_get_main_queue(), {
                //ApplicationFunctions.globaldisplayAlert(self, userMessage: "Controller Registered. Please set up Wifi connection", fn: {ApplicationFunctions.switchViewRegister(self,viewtoswitch: "viewChangeWifi")})
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewControllerWithIdentifier("LeagueSetup") as UIViewController
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                self.window?.rootViewController = initialViewControlleripad
                self.window?.makeKeyAndVisible()
            });
            
        }

        if(indexPath.section==3){
            print("clicked Log Out");
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "authenticationtoken");
            dispatch_async(dispatch_get_main_queue(), {
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewControllerWithIdentifier("viewLogin") as UIViewController
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                self.window?.rootViewController = initialViewControlleripad
                self.window?.makeKeyAndVisible()
            });
        }
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "remoView") {
            //let vc = segue.destinationViewController as! HomeViewController
            //vc.remoSelected = selected_remo
        }
    }
}
