//
//  DeviceCapability_Camera.swift
//  Boat Aware
//
//  Created by Dave Butz on 4/25/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class DeviceCapability_Camera: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var capabilityTitle: CapabilityTitleView!;
//    @IBOutlet var viewVideo: UIView!
//    @IBOutlet var viewPhotoGallery: UIView!
//    @IBOutlet var lblLastUpdated: UILabel!

    @IBOutlet var tableView: UITableView!
    let textCellIdentifier = "awscontentcell"
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    
    var awsContents = Array<AWSContent>();
    var compareContents = Array<AWSContent>();
    var remoSelected = JSONDictionary();
//    var selected_content = JSONDictionary();
    var selectedItem : AWSContent?;
    
    var selectedCapability : Capability?
    var selectedRemoControllerID : String = "";
 
    var backgroundTaskTimer = NSTimer();
    var backgroundTask = UIBackgroundTaskIdentifier();
    
    private var refreshControl : UIRefreshControl?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
            selectedCapability = deviceTabBar.selectedCapability;
            selectedRemoControllerID = deviceTabBar.selectedRemoControllerID;
            
        }
        
        self.refreshControl = UIRefreshControl();
        self.refreshControl!.addTarget(self, action: #selector(DeviceCapability_Camera.reload), forControlEvents: UIControlEvents.ValueChanged);
        self.tableView.addSubview(self.refreshControl!);
        
        self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        reload();
    }

    @IBAction func takePhoto(sender: AnyObject) {
        let appvar = ApplicationVariables.applicationvariables;
        
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        LoadingOverlay.shared.showOverlay(self.view);
        LoadingOverlay.shared.setCaption("Taking Photo. takes a few seconds to upload...");
        
        let api = APICalls()
        api.apicallout("/api/cloudsynchandler/takephoto/" + selectedRemoControllerID + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            
            //introduce the 'loading'
            
            //Reload this tableview
            dispatch_async(dispatch_get_main_queue(),{
                //loading.done()
                self.scheduleBackgroundTask();
            });
            
        });
    }
    
    @IBAction func takeVideo(sender: AnyObject) {
        print("takeVideo");
        let appvar = ApplicationVariables.applicationvariables;
        
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        
        LoadingOverlay.shared.showOverlay(self.view);
        LoadingOverlay.shared.setCaption("Taking Video. This takes some time...");

        //let loading = LoadingView(frame: self.view.frame);
        //loading.setCaption("Capturing video");
        
        let api = APICalls()
        api.apicallout("/api/cloudsynchandler/capturevideoevent/" + selectedRemoControllerID + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            
            //introduce the 'loading'
            //Sit here and wait until the results are ensured... how?
            ////Reload this tableview
            dispatch_async(dispatch_get_main_queue(),{
            //    //loading.done()
            //    self.tableView.reloadData();
                self.scheduleBackgroundTask();
            });
        });
    }
    
    func compareData(){
        let appvar = ApplicationVariables.applicationvariables;
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        let commnetwork = remoSelected["commnetwork"] as! String;
        let bucketname = "thriveboatawarebucket" + commnetwork.stringByReplacingOccurrencesOfString("THRIVE-", withString: "");
        
        let api = APICalls()
        api.apicallout("/api/accounts/getContentFromAWS/" + bucketname + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            let awsBucketContent = AWSContents(json: response as! Dictionary<String,AnyObject>);
            self.compareContents = (awsBucketContent?.contents)!;
            if (!self.compareContents.isEmpty) {
                if(self.compareContents[0].key != self.awsContents[0].key){
                    //Reload this tableview
                    dispatch_async(dispatch_get_main_queue(),{
                        //loading.done()
                        self.awsContents = self.compareContents;
                        self.endBackgroundTask();
                        LoadingOverlay.shared.hideOverlayView();
                        self.tableView.reloadData();
                    });
                }
            }
        });
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    func reload() {
        dispatch_async(dispatch_get_main_queue(),{
            self.refreshControl!.beginRefreshing();
        });

        
        let appvar = ApplicationVariables.applicationvariables;
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        
        if(remoSelected["commnetwork"]  == nil){
            let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
            remoSelected = appdel.my_remo_selected!;
        }
        
        let commnetwork = remoSelected["commnetwork"] as! String;
        let bucketname = "thriveboatawarebucket" + commnetwork.stringByReplacingOccurrencesOfString("THRIVE-", withString: "");
        
        let api = APICalls()
        api.apicallout("/api/accounts/getContentFromAWS/" + bucketname + "/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in

            //let content_dictionary = response as! Dictionary<String,AnyObject>
            //let content_array = content_dictionary["bucketcontents"] as! NSArray;
            let awsBucketContent = AWSContents(json: response as! Dictionary<String,AnyObject>);
            self.awsContents = (awsBucketContent?.contents)!;
            //Reload this tableview
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData();
                self.refreshControl!.endRefreshing();
                let timeString = DateExtensions.currentTime();
                self.refreshControl!.attributedTitle = NSMutableAttributedString(string: "Updated at \(timeString)");
            });
            
        });
    }
    
    func scheduleBackgroundTask(){
        self.backgroundTaskTimer.invalidate();
        self.backgroundTaskTimer = NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: #selector(DeviceCapability_Camera.compareData), userInfo: nil, repeats: true);
        
        self.backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask);
        });
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended.")
        self.backgroundTaskTimer.invalidate();
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return awsContents.count + 1 ?? 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            // Action Cell
            return tableView.dequeueReusableCellWithIdentifier("actionCell")!;
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        
        // Configure the cell...
        let contentObject = awsContents[indexPath.row - 1];
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle;
        dateFormatter.timeStyle = .ShortStyle;
        let dateString = dateFormatter.stringFromDate(contentObject.lastmodified!);
        
//        let cellview = cell.viewWithTag(1) as! UILabel;
        cell.textLabel?.text = dateString;
        
        var imageName = "Gallery";
        switch(contentObject.contenttype){
        case "Photo":
            imageName = "Gallery";
            break;
        case "Video":
            imageName = "video";
            break;
        default:
            break;
        }
//        let cellimageview = cell.viewWithTag(2) as! UIImageView;
//        cellimageview.image = UIImage(named: imageName)
        cell.imageView?.image = UIImage(named: imageName);
        
        return cell
    }
    
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        selected_content = getJson(awsContents[indexPath.row]);
        self.selectedItem = awsContents[indexPath.row - 1];
        
        // Show Photo?
        if (self.selectedItem!.contenttype == "Photo") {
            performSegueWithIdentifier("showPhoto", sender: self);
            return;
        }
        
        //pass you along to the next View...
        performSegueWithIdentifier("contentView", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "contentView") {
            let vc = segue.destinationViewController as! DeviceCapability_AWSContent
            vc.selectedContent = self.selectedItem;
        }
        else {
            // Photo viewer
            let vc = segue.destinationViewController as! PhotoViewController
            vc.selectedItem = self.selectedItem;
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
