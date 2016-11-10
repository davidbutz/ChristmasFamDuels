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
    private var refreshControl : UIRefreshControl?;

    override func viewDidLoad() {
        super.viewDidLoad();
        self.automaticallyAdjustsScrollViewInsets = false;
        self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);

        self.refreshControl = UIRefreshControl();
        self.refreshControl!.addTarget(self, action: #selector(ThresholdViewController.reload), forControlEvents: UIControlEvents.ValueChanged);
        self.tableView?.addSubview(self.refreshControl!);
        self.tableView?.alwaysBounceVertical = true;

        if (self.tabBarController as? DeviceCapabilityTabBarController) != nil {
        }
        
        reload();
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    func reload() {
        if (self.tabBarController as? DeviceCapabilityTabBarController) != nil {
            //self.capabilityTitle.deviceCapability = deviceTabBar.selectedCapability;
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshControl!.beginRefreshing();
        });

        //let JSONObject: [String : AnyObject] = [
        //    "login_token" : appvar.logintoken ]
        /*
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
            */
    }
}

extension ThresholdViewController {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "header for section";
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell;
        cell = tableView.dequeueReusableCellWithIdentifier("ruleCell", forIndexPath: indexPath) as UITableViewCell;
        return cell;
    }
}
