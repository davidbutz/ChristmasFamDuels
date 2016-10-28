//
//  HistoryViewController.swift
//  Boat Aware
//
//  Created by Adam Douglass on 6/28/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class HistoryViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var capabilityTitle : CapabilityTitleView!;
    
    private let appvar = ApplicationVariables.applicationvariables;
    
    private var refreshControl : UIRefreshControl?;
    private var selectedCapability : Capability?
    private var selectedRemoControllerID : String = "";
    
    private var rules : Array<DeviceCapabilityRule>?;
    private var history : Array<StateChangeEvent>?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.automaticallyAdjustsScrollViewInsets = false;
        self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        
        self.refreshControl = UIRefreshControl();
        self.refreshControl!.addTarget(self, action: #selector(HistoryViewController.reload), forControlEvents: UIControlEvents.ValueChanged);
        self.tableView.addSubview(self.refreshControl!);
        
        reload();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    func reload() {
        if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
            self.capabilityTitle.deviceCapability = deviceTabBar.selectedCapability;
            self.selectedCapability = deviceTabBar.selectedCapability;
            self.selectedRemoControllerID = deviceTabBar.selectedRemoControllerID;
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshControl!.beginRefreshing();
        });

        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        
        let api = APICalls()
        //http://localhost:1337/api/capability/history/bdb8416d-ddad-4321-a639-e7eb1dbe8f60/57435332ba9e572104e74fad/57435333ba9e572104e74fb3/?limit=5
        api.apicallout("/api/capability/history/" + appvar.logintoken + "/" + self.selectedRemoControllerID + "/" + (selectedCapability?.devicecapabilities[0].device_capability_id)!, iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            
            let stateChangeEvents = StateChangeEvents(json: response as! JSONDictionary);
            if let events = stateChangeEvents?.statechanges {
                self.history = events;
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


extension HistoryViewController {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.history?.count ?? 0;
    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        // Last Updated
//        if (indexPath.section == 0) {
//            return 30.0;
//        }
//        // Current Value
//        if (indexPath.section == 1) {
//            return 85.0;
//        }
//        return 50.0;
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath) as UITableViewCell;
        let historyItem = self.history![indexPath.row];
        
        var fromState : String?
        var toState : String?

        switch (historyItem.prev_state_id ?? 0) {
        case 1:
            fromState = "CRITICAL";
            break;
        case 2:
            fromState = "WARNING";
            break;
        case 3:
            fromState = "NORMAL";
            break;
        case 4:
            fromState = "WARNING";
            break;
        case 5:
            fromState = "CRITICAL";
            break;
        default:
            toState = "UNKNOWN";
            break;
        }
        
        switch (historyItem.current_state_id) {
        case 1:
            toState = "CRITICAL";
            cell.imageView?.tintColor = UIColor.boatAwareCritical();
            break;
        case 2:
            toState = "WARNING";
            cell.imageView?.tintColor = UIColor.boatAwareWarning();
            break;
        case 3:
            toState = "NORMAL";
            cell.imageView?.tintColor = UIColor.boatAwareNormal();
            break;
        case 4:
            toState = "WARNING";
            cell.imageView?.tintColor = UIColor.boatAwareWarning();
            break;
        case 5:
            toState = "CRITICAL";
            cell.imageView?.tintColor = UIColor.boatAwareCritical();
            break;
        default:
            toState = "UNKNOWN";
            break;
        }
        
        cell.detailTextLabel?.text = "From \(fromState!) to \(toState!)";
        
        if let dateOfChange = historyItem.dateofchange {
            let dateFormatter = NSDateFormatter();
            dateFormatter.timeStyle = .ShortStyle;
            dateFormatter.dateStyle = .MediumStyle;
            dateFormatter.locale = NSLocale.currentLocale();
            cell.textLabel!.text = dateFormatter.stringFromDate(dateOfChange);
        }

        
        return cell;
    }
//    
//    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return false;
//    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        // switch to History?
//    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if (section == 3) {
//            return CGFloat(SEPARATOR_HEIGHT);
//        }
//        return 0.0;
//    }
    
    
}
