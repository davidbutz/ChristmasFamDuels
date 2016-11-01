//
//  playBallViewController.swift
//  Christmas Fam Duels
//
//  Created by Dave Butz on 10/31/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3

class playBallViewController: UIViewController {

    @IBOutlet weak var btnHamburgerMenu: UIBarButtonItem!
    
    
    let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
    let api = APICalls();
    let JSONObject: [String : AnyObject] = [
        "login_token" : ApplicationVariables.applicationvariables.logintoken ]
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    let appvar = ApplicationVariables.applicationvariables;
    var refreshControl : UIRefreshControl?;
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up the folder for the download of the image(s)...
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(
                NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("download"),
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error1 as NSError {
            //error.memory = error1
            print("Creating 'download' directory failed. Error: \(error1)")
        }
        
        if self.revealViewController() != nil {
            btnHamburgerMenu.target = self.revealViewController()
            btnHamburgerMenu.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.setNeedsStatusBarAppearanceUpdate();
        
        self.refreshControl = UIRefreshControl();
        self.refreshControl!.tintColor = UIColor.whiteColor();
        self.refreshControl!.addTarget(self, action: #selector(playBallViewController.reload), forControlEvents: UIControlEvents.ValueChanged);
        
        
        //register the notification deviceToken with the server.
        let defaults = NSUserDefaults.standardUserDefaults();
        if let savedDeviceToken = defaults.stringForKey("deviceToken") {
            api.apicallout("/api/registerNotifications/iOS/" + savedDeviceToken + "/123456/" + appvar.logintoken, iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
                    let success = (response as! NSDictionary)["success"] as! Bool;
                    if(success){
                        //right now we dont really take any action on the part of this API call.. just want to know if successful.
                        print("success");
                    }
                }
            );
        }
        
        //get the image off the remoSelected
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:fa4674f7-7bc2-4847-ba61-44dc47f29bce");
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider);
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration;
        
        _ = AWSS3TransferManager.registerS3TransferManagerWithConfiguration(configuration, forKey: "xxx");
        
        // get the week you are in!
        
        // loadWeeklyPlaySheet
        
        // Do any additional setup after loading the view.
        reload(true);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload(isInitialLoad: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshControl!.beginRefreshing();
        });
        if (!isInitialLoad) {
            // We need to re-fetch the list of controllers to get it's main photo
            /*
                api.apicallout("/api/accounts/registeredcontrollers/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
                let jsonresponse = response as! Dictionary<String,Array<JSONDictionary>>;
                let selected_remo = Controller(controller: self.appdel.my_remo_selected!);
                for(controller) in (jsonresponse["controllers"])! {
                    let c = Controller(controller: controller);
                    if (c!.controller_id == selected_remo!.controller_id) {
                        self.appdel.my_remo_selected = controller;
                        self.remoSelected = controller;
                        self.loadCapabilities();
                        return;
                    }
                }
             });
                */
        } else {
            loadWeeklyPlaySheet();
        }
    }
    
    func loadWeeklyPlaySheet() {
    }

    
    func loadImage(bucketname:String,bucket_photo:String,downloadingFileURL:String){
        let transferManager = AWSS3TransferManager.S3TransferManagerForKey("xxx");
        let downloadingFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("download")
        let downloadingFilePath = downloadingFileURL.path!
        
        let getImageRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        getImageRequest.bucket = bucketname;
        getImageRequest.key = bucket_photo;
        getImageRequest.downloadingFileURL = downloadingFileURL;
        
        let task = transferManager.download(getImageRequest)
        task.continueWithBlock { (task) -> AnyObject! in
            print(task.error)
            if task.error != nil {
                let error = "";
                print(error);
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //_ = UIImage(contentsOfFile: downloadingFilePath)
                    let cameraPhotoIndexPath = NSIndexPath(forItem: 0, inSection: 0);
                    //self.collectionView?.collectionViewLayout.invalidateLayout();
                    let img = UIImage(contentsOfFile: downloadingFilePath);
                    //self.cameraCapability.image = img;
                    //if let cell = self.collectionView?.cellForItemAtIndexPath(cameraPhotoIndexPath) as? CameraCollectionViewCell {
                    //    cell.imageView.image = img;
                    //    cell.imageView.setNeedsDisplay();
                    //    cell.layoutIfNeeded();
                    //    cell.activityIndicator.stopAnimating();
                    //}
                });
            }
            return nil
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
