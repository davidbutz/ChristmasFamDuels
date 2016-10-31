//
//  WifiSelectTableViewController.swift
//  Boat Aware
//
//  Created by Dave Butz on 6/28/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class WifiSelectTableViewController: UITableViewController {

    @IBOutlet var wifiTableView: UITableView!
    var window: UIWindow?
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    var wifissid : String = "";
    var wifiList : JSONArray = []
    var wifisecurity : String = "";
    var boolChangingWifi : Bool = false;
    var backgroundTaskTimer = NSTimer();
    var backgroundTask = UIBackgroundTaskIdentifier();
    let appvar = ApplicationVariables.applicationvariables;
    var connectionAttempts : Int = 0;
    let textCellIdentifier = "wificell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWifiList(true);
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.scheduleBackgroundTask();
    }
    
    func scheduleBackgroundTask(){
        self.backgroundTaskTimer.invalidate();
        self.backgroundTaskTimer = NSTimer.scheduledTimerWithTimeInterval(20.0, target: self, selector: #selector(WifiSelectTableViewController.reloadWifiList), userInfo: nil, repeats: true);
        
        self.backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask);
        });
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func reloadWifiList(){
        getWifiList(false);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return wifiList.count ?? 0
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    func getWifiList(firstload: Bool){
        if firstload{
            LoadingOverlay.shared.showOverlay(self.view);
            LoadingOverlay.shared.setCaption("Fetching list of available WiFi...");
        }
        // get wifi data...
        let JSONObject: [String : AnyObject] = [
            "userid" : appvar.userid
        ]
        let api = APICalls();
        api.apicallout("/api/setupwifi/scanwifi" , iptype: "thriveIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            
            //handle the response. i should get status : fail/success and message: various
            let success = (response as! NSDictionary)["success"] as! Bool;
            if(success){
                var networks = (response as! NSDictionary)["networks"] as! Array<Dictionary<String, AnyObject>>;
                let otherNetwork =  [
                    "ssid": "Other...",
                    "channel": "1",
                    "signal_level": "100",
                    "security": "Unknown"
                ]
                networks.append(otherNetwork);
                self.wifiList = networks;
                dispatch_async(dispatch_get_main_queue(),{
                    if firstload{
                        LoadingOverlay.shared.hideOverlayView();
                    }
                    self.wifiTableView.reloadData();
                    //self.tableView.becomeFirstResponder();
                    //self.tableView.panGestureRecognizer.delaysTouchesBegan = false;
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(),{
                    if firstload{
                        LoadingOverlay.shared.hideOverlayView();
                    }
                });
            }
        });
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        // Configure the cell...
        var wifi = wifiList[indexPath.row] as! JSONDictionary
        let wifiname = wifi["ssid"] as! String;
        //label...
        let cellLabel = cell.viewWithTag(1) as! UILabel;
        cellLabel.text = wifiname;
        let cellSecurityImageView = cell.viewWithTag(3) as! UIImageView;
        //security...
        if let _ = wifi["security"] {
            cellSecurityImageView.image = UIImage(named: "lock")
        }
        else{
            cellSecurityImageView.image = UIImage(named: "unlock")
        }
        //wifi icon...
        let cellWifiImageView = cell.viewWithTag(2) as! UIImageView;
        if(wifiname=="Other..."){
            // Want to remove icon for "Other..."
            cellWifiImageView.image = UIImage(named: "ic_add_black");
        }
        else{
            if let wifiStrength = wifi["signal_level"]{
                let wifiSignalStrengthString = wifiStrength as! String;
                let wifiSignalStrength = Int(wifiSignalStrengthString);
                if wifiSignalStrength > 80 {
                    cellWifiImageView.image = UIImage(named: "wifi_high");
                }
                else{
                    if wifiSignalStrength > 50 {
                        cellWifiImageView.image = UIImage(named: "wifi_med");
                    }
                    else{
                        cellWifiImageView.image = UIImage(named: "wifi_low");
                    }
                }
            }
        }
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "seqProvideWiFiCredentials") {
            let vc = segue.destinationViewController as! WifiSelectUserInputViewController
            vc.boolChangingWifi = self.boolChangingWifi;
            vc.wifissid = self.wifissid;
            vc.wifisecurity = self.wifisecurity;
        }
        
    }
    // MARK:  UITableViewDelegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var wifi = wifiList[indexPath.row] as! JSONDictionary;
        let row = indexPath.row
        wifissid = wifi["ssid"] as! String;
        if let _ = wifi["security"] {
            self.wifisecurity = wifi["security"] as! String;
            dispatch_async(dispatch_get_main_queue(),{
                self.wifisecurity = wifi["security"] as! String;
            });
        }
        else {
            self.wifisecurity = "";
            dispatch_async(dispatch_get_main_queue(),{
                self.wifisecurity = "";
            });
        }
        self.backgroundTaskTimer.invalidate();
        self.endBackgroundTask();
        self.performSegueWithIdentifier("seqProvideWiFiCredentials", sender: self);
        print(wifiList[row]);
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
