//
//  confirmTableViewController.swift
//  Christmas Fam Duels
//
//  Created by Dave Butz on 11/10/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class confirmTableViewController: UITableViewController {

    let confirmationvar = ConfirmationVariables.confirmationvariables;
    let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
    let api = APICalls();
    let JSONObject: [String : AnyObject] = [
        "login_token" : ApplicationVariables.applicationvariables.logintoken ]
    let leaguevar = LeagueVariables.leaguevariables;
    let currentweekvar = WeekVariables.currentweekvariables;
    let appvar = ApplicationVariables.applicationvariables;
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (confirmationvar.confirmations?.contents.count)!;
    }

    func buttonClicked(sender:UIButton) {
        
        _ = sender.tag
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
        if indexPath != nil {
            LoadingOverlay.shared.showOverlay(self.view);
            LoadingOverlay.shared.setCaption("Getting Lineup Data...");
            print(indexPath?.row);
            let confirmationClicked = confirmationvar.confirmations?.contents[(indexPath?.row)!];
            print("hey you are confirming" + (confirmationClicked?.referenceUser)! + " " + (confirmationClicked?._id)!);
            
            var url = "/api/scoring/confirmed/" + (confirmationClicked?._id)!;
            url += "/" + self.appvar.userid + "/" + self.appvar.logintoken;
            self.api.apicallout(url, iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (confirmedresponse) -> () in
                let success = (confirmedresponse as! NSDictionary)["success"] as! Bool;
                if(success){
                    //using this time to load lots of stuff up.
                    print("success");
                    self.api.apicallout("/api/view/getNeededConfirmations/" + self.leaguevar.leagueID  + "/" + self.appvar.userid + "/" + self.currentweekvar.weekID + "/" + self.appvar.logintoken, iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (confirmationresponse) -> () in
                        let success = (confirmationresponse as! NSDictionary)["success"] as! Bool;
                        if(success){
                            //using this time to load lots of stuff up.
                            print("success");
                            let myvar = Confirmations(json: confirmationresponse as! Dictionary<String,AnyObject>);
                            self.confirmationvar.confirmations = myvar;
                            //reload
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                LoadingOverlay.shared.hideOverlayView();
                                self.tableView.reloadData();
                            })
                        }
                        else{
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                LoadingOverlay.shared.hideOverlayView();
                                //self.tableView.reloadData();
                            });
                        }
                    });
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        LoadingOverlay.shared.hideOverlayView();
                        //self.tableView.reloadData();
                    });
                }
            });
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let contentObject = confirmationvar.confirmations?.contents[indexPath.row];
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd' 'HH:mm"
        let dateString = dateFormatter.stringFromDate((contentObject?.datecreated)!);
        let cellview = cell.viewWithTag(1) as! UILabel;
        cellview.text = (contentObject?.referenceUser)! + " heard " + (contentObject?.referenceType)! + " on " + dateString;
        let cellbutton = cell.viewWithTag(2) as! UIButton;
        cellbutton.addTarget(self, action: #selector(confirmTableViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
