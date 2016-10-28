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
    var selectedCapability : Capability?
    var selectedRemoControllerID : String = "";
    
    // Status variables
    var last_observation_date: NSDate?;
    var current_value_string: NSString?;
    var rulesList : Array<DeviceCapabilityRule> = [];

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
            selectedCapability = deviceTabBar.selectedCapability;
            selectedRemoControllerID = deviceTabBar.selectedRemoControllerID;
            //            let deviceCapabilityId = selectedCapability!.devicecapabilities[0].device_capability_id;
            
            //set the current value
            if let curr_value = selectedCapability?.devicecapabilities[0].current_value_string{
                self.current_value_string = curr_value;
            }
            
            self.capabilityTitle.deviceCapability = self.selectedCapability;
            
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
            
        }
    }
}

extension DeviceCapabilityViewController {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3 + self.rulesList.count;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 2) {
            return self.rulesList.count;
        }
        if (section == 4) {
            return 1;
        }
        if (section == 3) {
            var rows = 0;
            let rule = self.rulesList[section - 3];
            
            if let _ = rule.date_of_change {
                rows += 1;
            }
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
                if let dateConversion = self.last_observation_date {
                    textLabel.text = DateExtensions.dateDiff(dateConversion);
                }
                else {
                    textLabel.text = "unknown";
                }
            }
        }
        else if (indexPath.section == 1) {
            cell = tableView.dequeueReusableCellWithIdentifier("currentValueCell", forIndexPath: indexPath) as UITableViewCell;
            
            // configure cell
            if let textLabel = (cell.viewWithTag(1) as? UILabel) {
                if (self.current_value_string != nil) {
                    textLabel.text = String(current_value_string!)
                }
                else {
                    textLabel.text = "";
                }
            }
        }
        
        // thresholdCell
        else if (indexPath.section == 2) {
            cell = tableView.dequeueReusableCellWithIdentifier("thresholdCell", forIndexPath: indexPath) as UITableViewCell;
            
            // configure cell
            if let thresholdCell = (cell.viewWithTag(1) as? ThresholdVisualView) {
                thresholdCell.rule = self.rulesList[indexPath.row];
                thresholdCell.value = self.selectedCapability?.devicecapabilities[0].current_value;
            }
        }
        
        // A rule cell
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("ruleCell", forIndexPath: indexPath) as UITableViewCell;
            // defaults
            cell.accessoryType = UITableViewCellAccessoryType.None;
            
            
            let rule = self.rulesList[indexPath.section - 3];
            
            var offset = 0;
            
            if (rule.date_of_change != nil && indexPath.row == offset) {
                offset += 1;
                cell.textLabel?.text = "Changed " + DateExtensions.dateDiff(rule.date_of_change!) + "";
                cell.detailTextLabel?.text = String(rule.date_of_change!);
                cell.imageView?.image = UIImage(named: "calendar");
                
                // Action takes user to the "history" page
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            }
            
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
            
//            let headerView = UIView(frame: CGRect(x: Int(self.tableView.layoutMargins.left), y: 0, width: Int(width), height: SEPARATOR_HEIGHT));
//            headerView.backgroundColor = UIColor.darkGrayColor();
//          
            let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.tableView.frame.width, height: CGFloat(SEPARATOR_HEIGHT)));
            let headerView = LineView(frame: frame, lineWidth: 1.0, leftMargin: self.tableView.layoutMargins.left, rightMargin: self.tableView.layoutMargins.right);
            return headerView;
        }
        return nil;
    }
    
}
class XXXXDeviceCapabilityViewController : UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
//    @IBOutlet var lblCapability: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblLastUpdate: UILabel!
//    @IBOutlet var lblOverallStatus: UILabel!
    @IBOutlet var lblCurrentValue: UILabel!
    @IBOutlet var imgOverallStatus: UIImageView!
//    @IBOutlet var viewCurrentStatus: UIView!
    @IBOutlet weak var capabilityTitle : CapabilityTitleView!;

    
    var selectedCapability : Capability?
    var selectedRemoControllerID : String = "";
    
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    
    var rulesList : Array<DeviceCapabilityRule> = [];//Array<Dictionary<String, AnyObject>> = [];// as Array;//Controllers;//JSONArray = []
    let textCellIdentifier = "rulescell"
    var selected_rule = JSONDictionary()
    let appvar = ApplicationVariables.applicationvariables;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true;
        tableView.delegate = self;
        tableView.dataSource = self;
        
        self.lblCurrentValue.text = "";
        
//        let attachment = NSTextAttachment()
//        let updateImage = UIImage(named: "clock-128");
//        attachment.image = updateImage;
//        attachment.bounds = CGRectMake(0, 0, 30, 30);
//        let attachmentString = NSAttributedString(attachment: attachment)
//        let myString = NSMutableAttributedString(string: "")
//        myString.appendAttributedString(attachmentString)
//        myString.appendAttributedString(NSMutableAttributedString(string: "Last Updated"))
//        lblLastUpdate.attributedText = myString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
            selectedCapability = deviceTabBar.selectedCapability;
            selectedRemoControllerID = deviceTabBar.selectedRemoControllerID;
//            let deviceCapabilityId = selectedCapability!.devicecapabilities[0].device_capability_id;
            
            //set the current value
            if let curr_value = selectedCapability?.devicecapabilities[0].current_value_string{
                lblCurrentValue!.text = String(curr_value);
            }
            
            self.capabilityTitle.deviceCapability = self.selectedCapability;

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
                    self.tableView.reloadData();
                    //put both the current state and the bar at the top (viewCurrentStatus) to the appropriate colors;
                    //                self.viewCurrentStatus.backgroundColor = color;
//                    self.capabilityTitle.deviceCapability = self.selectedCapability;
                    //                self.imgOverallStatus.image = UIImage(named: imageName)
                    
                    if let last_observation_date = deviceCapabilityRules?.last_observation_date {
//                        TO DO: make this say "last update: "
                        self.lblLastUpdate.text = "Last updated " + DateExtensions.dateDiff(last_observation_date);//String(last_observation_date);//"Last Updated: " + String(last_observation_date);
                    }
                });
            });
            
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        return;
        //appvar is needed for login token with API calls (later);
        if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
            selectedCapability = deviceTabBar.selectedCapability;
            selectedRemoControllerID = deviceTabBar.selectedRemoControllerID;
            
            //set the name of the text
//            if let capability_name = selectedCapability?.capability_name{
//                lblCapability.text = capability_name
//            }
            
            //set the current value
            if let curr_value = selectedCapability?.devicecapabilities[0].current_value_string{
                lblCurrentValue!.text = String(curr_value);
            }
        }
      
        //check to see if the long term storage contains at least one controller registered. if not ; seque to the add controller screen.
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        
        // Call to /api/accounts/rules/ to get the
        let api = APICalls()
        api.apicallout("/api/accounts/rules/" + selectedRemoControllerID + "/" + (selectedCapability?.devicecapabilities[0].device_capability_id)! + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            let landingpagedata = DeviceCapabilityRules(devicecapabilityrule: response as! Dictionary<String,AnyObject>);
            if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
                deviceTabBar.selectedRules = landingpagedata;
            }
            
            //set the rulesList object
            self.rulesList = (landingpagedata?.rules)!;
            
            //Reload this tableview
             dispatch_async(dispatch_get_main_queue(),{
                //put both the current state and the bar at the top (viewCurrentStatus) to the appropriate colors;
//                self.viewCurrentStatus.backgroundColor = color;
                self.capabilityTitle.deviceCapability = self.selectedCapability;
//                self.imgOverallStatus.image = UIImage(named: imageName)
                
                if let last_observation_date = landingpagedata?.last_observation_date{
                    //TO DO: make this say "last update: "
                    self.lblLastUpdate.text = "Last updated " + DateExtensions.dateDiff(last_observation_date);//String(last_observation_date);//"Last Updated: " + String(last_observation_date);
                }
                //self.lblLastUpdate.text = "Last Updated: " + String(landingpagedata?.last_observation_date);
                if let last_update = self.selectedCapability?.devicecapabilities[0].last_updated{
                    //TO DO: do some date manipulation to provide for a 'been in this state for xx (hrs/days)'
//                    self.lblOverallStatus.text = "Status " + DateExtensions.dateDiff(last_update);//String(last_update);//"Current State for: " + String(last_update);
                    //self.lblOverallStatus.text = "Current State for: " + String(self.selectedCapability?.devicecapabilities[0].last_updated);
                }
            
                //loading.done()
                self.tableView.reloadData();
             });
        });
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rulesList.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell

         // Configure the cell...
         let rule = DeviceCapabilityRule(rulenative: rulesList[indexPath.row]);
         
         let rule_name = rule?.rule_name;
         let rule_overall_status = Int((rule?.current_state_id)!);
         let cellview = cell.viewWithTag(1) as! UILabel;
         cellview.text = rule_name;
         
         var imageName = "green_ok";
         switch(rule_overall_status){
             case 1:
                imageName = "red_alert";
                break;
             case 5:
                imageName = "red_alert";
                break;
             case 4:
                imageName = "yellow_warning";
                break;
             case 2:
                imageName = "yellow_warning";
                break;
             default:
                break;
         }
         let cellimageview = cell.viewWithTag(2) as! UIImageView;
         cellimageview.image = UIImage(named: imageName)
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selected_rule = getJson(rulesList[indexPath.row]);
        //pass you along to the next View... if there is one....
        //performSegueWithIdentifier("remoView", sender: self)
        print(rulesList[indexPath.row]);
        
    }
    
    func getJson(data : DeviceCapabilityRule) -> JSONDictionary {
        let json : [String: AnyObject] = ["rule_name": data.rule_name, "current_state_id": data.current_state_id, "date_of_change": data.date_of_change! ]
        return json;
    }
    
}