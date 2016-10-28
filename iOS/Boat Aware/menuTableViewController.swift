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
    
    var remoName : String = "";
    let textCellIdentifier = "dyn1"
    var selected_remo = Dictionary<String, AnyObject>()
    var remoInAppDel : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
        if appdel.my_remo_selected != nil {
            remoInAppDel = true;
            //dispatch_async(dispatch_get_main_queue()
            //    , { () -> Void in
            //        self.mainTableView.reloadData();
            //})
            if let x = self.mainTableView{
                x.reloadData();
            }
            //self.mainTableView.reloadData();
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    /*
    Pulled together dynamic and static through couple web sites.
    Primarily: http://stackoverflow.com/questions/28942400/ios-swift-how-to-have-one-static-cell-in-a-dynamic-tableview
    */

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section==3){
            return AppRemoList.appremoList.count;
        }
        else {
            return 1;
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell();
        cell.backgroundColor = UIColor.clearColor()
        if(indexPath.section<3){
            if(indexPath.section==0){
                cell = tableView.dequeueReusableCellWithIdentifier("static1", forIndexPath: indexPath)
                let cellview = cell.viewWithTag(6) as! UILabel;
                if(remoInAppDel){
                    let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
                    let controller_name = appdel.my_remo_selected!["controller_name"] as! String;
                    cellview.text = "BoatAware - " + controller_name;
                    //cell.textLabel?.text = "BoatAware - ";// + appdel.my_remo_selected[""];
                }
                else{
                    cellview.text = "BoatAware";
                }
            }
//            if(indexPath.section==1){
//                cell = tableView.dequeueReusableCellWithIdentifier("static2", forIndexPath: indexPath)
//            }
//            if(indexPath.section==2){
//                cell = tableView.dequeueReusableCellWithIdentifier("static3", forIndexPath: indexPath)
//            }
            if(indexPath.section==1){
                cell = tableView.dequeueReusableCellWithIdentifier("static4", forIndexPath: indexPath)
            }
            if(indexPath.section==2){
                cell = tableView.dequeueReusableCellWithIdentifier("static5", forIndexPath: indexPath)
            }
        }
        else{
            cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
            // Configure the cell...
            let remo = Controller(controller: AppRemoList.appremoList[indexPath.row]);
            let remo_name =   remo?.controller_name;
            let cellview = cell.viewWithTag(4) as! UILabel;
            cellview.text = remo_name;
            
            var imageName = "green_ok";
            switch(String(remo!.overall_status_id)){
            case "1":
                imageName = "red_alert";
                break;
            case "5":
                imageName = "red_alert";
                break;
            case "4":
                imageName = "yellow_warning";
                break;
            case "2":
                imageName = "yellow_warning";
                break;
            default:
                break;
            }
            let cellimageview = cell.viewWithTag(5) as! UIImageView;
            cellimageview.image = UIImage(named: imageName)
            
        }
        
        if (!remoInAppDel && indexPath.section==3) {
            cell.hidden = true;
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
        
//        if(indexPath.section==1){
//            print("clicked add remo");
//            dispatch_async(dispatch_get_main_queue(), {
//                ApplicationFunctions.globaldisplayAlert(self, userMessage: "Please have your Remo available and powered on.", fn: {ApplicationFunctions.switchViewRegister(self,viewtoswitch: "SetUpWifi")})
//            });
//        }
//        
//        if(indexPath.section==2){
//            print("clicked settings");
//            //TO DO : I dont know what "settings" is this round. Maybe this is username?
//        }
        
        if(indexPath.section==1){
            print("clicked change wifi");
            
            // What will happen:
            // 1) Make sure connected to a REMO (selected)
            // 2) Select a wifi -
            // 3) Send that remo, through command, a note to connect
            
            dispatch_async(dispatch_get_main_queue(), {
                //ApplicationFunctions.globaldisplayAlert(self, userMessage: "Controller Registered. Please set up Wifi connection", fn: {ApplicationFunctions.switchViewRegister(self,viewtoswitch: "viewChangeWifi")})
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewControllerWithIdentifier("viewChangeWifi") as UIViewController
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                self.window?.rootViewController = initialViewControlleripad
                self.window?.makeKeyAndVisible()
            });
            
        }
        if(indexPath.section==2){
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
        
        if(indexPath.section>=3){
            selected_remo = AppRemoList.appremoList[indexPath.row];
            let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
            appdel.my_remo_selected = AppRemoList.appremoList[indexPath.row];
            //pass you along to the next View...
            performSegueWithIdentifier("remoView", sender: self)
            
            /*NSOperationQueue.mainQueue().addOperationWithBlock {
                //now take them to the login page..
                let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("remoView");
                UIApplication.sharedApplication().delegate?.window!?.rootViewController?.presentViewController(settingview!, animated: true, completion: nil)
                }
                //let settingview = self.storyboard!.instantiateViewControllerWithIdentifier("remoView");
                //self.navigationController?.presentViewController(settingview, animated: true, completion: nil);
                */
            
            print(AppRemoList.appremoList[indexPath.row]);
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "remoView") {
            //let vc = segue.destinationViewController as! HomeViewController
            //vc.remoSelected = selected_remo
        }
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
