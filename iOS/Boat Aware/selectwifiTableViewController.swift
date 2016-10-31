//
//  selectwifiTableViewController.swift
//  ThriveIOSPrototype
//
//  Created by Dave Butz on 1/11/16.
//  Copyright © 2016 Dave Butz. All rights reserved.
//

import UIKit

class selectwifiTableViewController: UITableViewController {


    @IBOutlet weak var tblView: UITableView!

    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    
    var wifiList : JSONArray = []
    let appvar = ApplicationVariables.applicationvariables;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // Do any additional setup after loading the view.
        // get wifi data...
        let JSONObject: [String : AnyObject] = [
            "userid" : appvar.userid
        ]
        let api = APICalls();
        api.apicallout("/api/setupwifi/scanwifi" , iptype: "thriveIPAddress", method: "POST", JSONObject: JSONObject, callback: { (response) -> () in
            
            //handle the response. i should get status : fail/success and message: various
            let status = (response as! NSDictionary)["status"] as! Bool;
            if(status){
                let networks = (response as! NSDictionary)["networks"] as! Array<Dictionary<String, AnyObject>>;
                self.wifiList = networks;
                self.tblView.reloadData();
            }
        });
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;//wifiList.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return wifiList.count ?? 0
    }

 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("wificell", forIndexPath: indexPath)

        // Configure the cell...
        var wifi = wifiList[indexPath.row] as! JSONDictionary
        let wifiname = wifi["ssid"] as! String;
        let security = wifi["security"] as! String;
        cell.textLabel!.text = wifiname;
        cell.detailTextLabel!.text = security;
        return cell;
    }
   
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Process an Selection
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
