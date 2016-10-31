//
//  ThresholdViewController.swift
//  Boat Aware
//
//  Created by Adam Douglass on 6/29/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class ThresholdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var capabilityTitle : CapabilityTitleView!;
    
    private let appvar = ApplicationVariables.applicationvariables;
    private var selectedCapability : Capability?
    private var selectedRemoControllerID : String = "";
    private var rulesList : Array<DeviceCapabilityRule> = [];
    private var refreshControl : UIRefreshControl?;

    override func viewDidLoad() {
        super.viewDidLoad();
        self.automaticallyAdjustsScrollViewInsets = false;
        self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);

        self.refreshControl = UIRefreshControl();
        self.refreshControl!.addTarget(self, action: #selector(ThresholdViewController.reload), forControlEvents: UIControlEvents.ValueChanged);
        self.tableView?.addSubview(self.refreshControl!);
        self.tableView?.alwaysBounceVertical = true;

        if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
            self.selectedCapability = deviceTabBar.selectedCapability;
            self.selectedRemoControllerID = deviceTabBar.selectedRemoControllerID;
        }
        
        reload();
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    func reload() {
        if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
            self.capabilityTitle.deviceCapability = deviceTabBar.selectedCapability;
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshControl!.beginRefreshing();
        });

        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        
        let api = APICalls()
        api.apicallout("/api/accounts/rules/" + self.selectedRemoControllerID + "/" + (selectedCapability?.devicecapabilities[0].device_capability_id)! + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            
            let deviceCapabilityRules = DeviceCapabilityRules(devicecapabilityrule: response as! Dictionary<String,AnyObject>);
            if let rules = deviceCapabilityRules?.rules {
                self.rulesList = rules;
            }
            
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData();
                self.refreshControl!.endRefreshing();
                let timeString = DateExtensions.currentTime();
                self.refreshControl!.attributedTitle = NSMutableAttributedString(string: "Updated at \(timeString)");
            });
        });
    }
}

extension ThresholdViewController {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.rulesList[section].rule_name;
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.rulesList.count;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let ruleRange = self.rulesList[section].rule_range;
        return ruleRange.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell;
            cell = tableView.dequeueReusableCellWithIdentifier("ruleCell", forIndexPath: indexPath) as UITableViewCell;
        let ruleRange = self.rulesList[indexPath.section].rule_range;
        let ruleItem = ruleRange[indexPath.row];

        switch (ruleItem.state_id) {
        case 1:
            cell.textLabel?.text = "CRITICAL";
            cell.imageView?.tintColor = UIColor.boatAwareCritical();
            break;
        case 2:
            cell.textLabel?.text = "WARNING";
            cell.imageView?.tintColor = UIColor.boatAwareWarning();
            break;
        case 3:
            cell.textLabel?.text = "NORMAL";
            cell.imageView?.tintColor = UIColor.boatAwareNormal();
            break;
        case 4:
            cell.textLabel?.text = "WARNING";
            cell.imageView?.tintColor = UIColor.boatAwareWarning();
            break;
        case 5:
            cell.textLabel?.text = "CRITICAL";
            cell.imageView?.tintColor = UIColor.boatAwareCritical();
            break;
        default:
            cell.textLabel?.text = "UNKNOWN";
            break;
        }
        cell.detailTextLabel?.text = "\(ruleItem.gte) to \(ruleItem.lt)";

        return cell;
    }
}
