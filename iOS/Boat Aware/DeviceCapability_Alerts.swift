//
//  DeviceCapability_Alerts.swift
//  Boat Aware
//
//  Created by Dave Butz on 6/9/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class DeviceCapability_Alerts: UITableViewController {

    @IBOutlet var tblView: UITableView!
    
    var statechangeevents = Array<StateChangeEvent>();
    let textCellIdentifier = "alertcell"
    override func viewDidLoad() {
        super.viewDidLoad()

//        tblView.delegate = self;
//        tblView.dataSource = self;
        

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
//    override func viewDidAppear(animated: Bool) {
//        dispatch_async(dispatch_get_main_queue(),{
//            self.tblView.reloadData();
//        });
//    }

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
        return statechangeevents.count ?? 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        let contentObject = statechangeevents[indexPath.row];
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm"
        let dateString = dateFormatter.stringFromDate(contentObject.dateofchange!);
        let rulename = contentObject.rulename;
        
        var imageName = "green_ok";
//        var color = UIColor(red: 85/255, green: 137/255, blue: 84/255, alpha: 1);
        var labelcolor = "ok";
        let crrstateid = contentObject.current_state_id;
        
        switch(String(crrstateid)){
        case "1":
            imageName = "red_alert";
//            color = UIColor.redColor();
            labelcolor = "Critical Low";
            break;
        case "5":
            imageName = "red_alert";
//            color = UIColor.redColor();
            labelcolor = "Critical High";
            break;
        case "4":
            imageName = "yellow_warning";
//            color = UIColor.yellowColor();
            labelcolor = "Warning High";
            break;
        case "2":
            imageName = "yellow_warning";
//            color = UIColor.yellowColor();
            labelcolor = "Warning Low";
            break;
        default:
            break;
        }
        
        
        let cellview = cell.viewWithTag(1) as! UILabel;
        cellview.text = rulename;
        
        
        let cellview2 = cell.viewWithTag(2) as! UILabel;
        cellview2.text = "Reached  " + labelcolor + " on " + dateString;
        
        let cellimageview = cell.viewWithTag(3) as! UIImageView;
        cellimageview.image = UIImage(named: imageName)
        
        return cell

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
