//
//  DeviceCapabilityViewController.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/9/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit


// LANDING PAGE
class DeviceCapabilityViewController : UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    let SEPARATOR_HEIGHT = 1;
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var capabilityTitle : CapabilityTitleView!;
    private var refreshControl : UIRefreshControl?;
    
    
    let appvar = ApplicationVariables.applicationvariables;

    
    // Status variables
    //var last_observation_date: NSDate?;
    //var current_value_string: NSString?;
    //var rulesList : Array<DeviceCapabilityRule> = [];

    override func viewDidLoad() {
        super.viewDidLoad();
        self.automaticallyAdjustsScrollViewInsets = false;
        self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        self.refreshControl = UIRefreshControl();
        self.refreshControl!.addTarget(self, action: #selector(DeviceCapabilityViewController.reload), forControlEvents: UIControlEvents.ValueChanged);
        self.tableView?.addSubview(self.refreshControl!);
        self.tableView?.alwaysBounceVertical = true;

    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        reload();
    }
    
    
    func reload() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshControl!.beginRefreshing();
        });

        if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
            //selectedCapability = deviceTabBar.selectedCapability;
            //selectedRemoControllerID = deviceTabBar.selectedRemoControllerID;
            //            let deviceCapabilityId = selectedCapability!.devicecapabilities[0].device_capability_id;
            
            //set the current value
            //if let curr_value = selectedCapability?.devicecapabilities[0].current_value_string{
            //    self.current_value_string = curr_value;
            //}
            
            //self.capabilityTitle.deviceCapability = self.selectedCapability;
            /*
            let JSONObject: [String : AnyObject] = [
                "login_token" : appvar.logintoken ]
            
            let api = APICalls()
            api.apicallout("/api/accounts/rules/" + selectedRemoControllerID + "/" + (selectedCapability?.devicecapabilities[0].device_capability_id)! + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
                
                let deviceCapabilityRules = DeviceCapabilityRules(devicecapabilityrule: response as! Dictionary<String,AnyObject>);
                if let rules = deviceCapabilityRules?.rules {
                    self.rulesList = rules;
                }
                
                if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
                    deviceTabBar.selectedRules = deviceCapabilityRules;
                }
                
                dispatch_async(dispatch_get_main_queue(),{
                    if let last_observation_date = deviceCapabilityRules?.last_observation_date {
                        self.last_observation_date = last_observation_date;
                    }
                    
                    self.tableView.reloadData();
                    
                    self.refreshControl!.endRefreshing();
                    let timeString = DateExtensions.currentTime();
                    self.refreshControl!.attributedTitle = NSMutableAttributedString(string: "Updated at \(timeString)");

                });
            });
            */
        }
    }
}

extension DeviceCapabilityViewController {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;// + self.rulesList.count;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 2) {
            return 0;//self.rulesList.count;
        }
        if (section == 4) {
            return 1;
        }
        if (section == 3) {
            var rows = 0;
            let rule = 0;//self.rulesList[section - 3];
            
            //if let _ = rule.date_of_change {
            //    rows += 1;
           // }
            return rows;
        }
        return 1;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Last Updated
        if (indexPath.section == 0) {
            return 30.0;
        }
        // Current Value
        if (indexPath.section == 1) {
            return 85.0;
        }
        return 50.0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell;
        if (indexPath.section == 0) {
            cell = tableView.dequeueReusableCellWithIdentifier("lastUpdateCell", forIndexPath: indexPath) as UITableViewCell;
         
            if let textLabel = (cell.viewWithTag(1) as? UILabel) {
                textLabel.text = "unknown";
                //if let dateConversion = self.last_observation_date {
                //    textLabel.text = DateExtensions.dateDiff(dateConversion);
               // }
                //else {
                //    textLabel.text = "unknown";
                //}
            }
        }
        else if (indexPath.section == 1) {
            cell = tableView.dequeueReusableCellWithIdentifier("currentValueCell", forIndexPath: indexPath) as UITableViewCell;
            
            // configure cell
            if let textLabel = (cell.viewWithTag(1) as? UILabel) {
                textLabel.text = "";
                //if (self.current_value_string != nil) {
                //    textLabel.text = String(current_value_string!)
               // }
               // else {
               //     textLabel.text = "";
               // }
            }
        }
        
        // thresholdCell
        else if (indexPath.section == 2) {
            cell = tableView.dequeueReusableCellWithIdentifier("thresholdCell", forIndexPath: indexPath) as UITableViewCell;
            /*
            // configure cell
            if let thresholdCell = (cell.viewWithTag(1) as? ThresholdVisualView) {
                thresholdCell.rule = self.rulesList[indexPath.row];
                thresholdCell.value = self.selectedCapability?.devicecapabilities[0].current_value;
            }
                */
        }
        
        // A rule cell
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("ruleCell", forIndexPath: indexPath) as UITableViewCell;
            // defaults
            cell.accessoryType = UITableViewCellAccessoryType.None;
            
            
            //let rule = self.rulesList[indexPath.section - 3];
            
            var offset = 0;
            
            //if (rule.date_of_change != nil && indexPath.row == offset) {
            //    offset += 1;
            //    cell.textLabel?.text = "Changed " + DateExtensions.dateDiff(rule.date_of_change!) + "";
            //    cell.detailTextLabel?.text = String(rule.date_of_change!);
            //    cell.imageView?.image = UIImage(named: "calendar");
                
            //    // Action takes user to the "history" page
            //    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            //}
            
        }

        
        return cell;
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (indexPath.section == 3 && indexPath.row == 0) {
            return true;
        }
        return false;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // switch to History?
        if (indexPath.section == 3 && indexPath.row == 0) {
            self.tabBarController?.selectedIndex = 3;
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 3) {
            return CGFloat(SEPARATOR_HEIGHT);
        }
        return 0.0;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 3) {
            // Header separator line
            let width = self.tableView.frame.width - self.tableView.layoutMargins.left - self.tableView.layoutMargins.right;
            
            let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.tableView.frame.width, height: CGFloat(SEPARATOR_HEIGHT)));
            let headerView = LineView(frame: frame, lineWidth: 1.0, leftMargin: self.tableView.layoutMargins.left, rightMargin: self.tableView.layoutMargins.right);
            return headerView;
        }
        return nil;
    }
    
}
