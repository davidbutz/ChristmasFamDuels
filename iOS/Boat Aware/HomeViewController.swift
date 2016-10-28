    //
//  HomeViewController.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/8/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3
    
class HomeViewController: UICollectionViewController {
    
    @IBOutlet weak var warningBarButtonItem: UIBarButtonItem!
    @IBOutlet var btn_menu_hamburger: UIBarButtonItem!

    @IBOutlet var btn_settings: UIBarButtonItem!

    @IBOutlet var btnAlert: UIBarButtonItem!
    
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    
    var deviceCapabilitiesb = DeviceCapability.allDeviceCapabilities()
    var remoSelected = JSONDictionary();
//    var deviceCapabilities = Array<DeviceCapabilityNew>();
    
    var capabilities = Array<Capability>();
    var cameraCapability = Capability(name: "Camera");
    
    
//    var boat_image = UIImageView();
    
    var statechangeevents  = Array<StateChangeEvent>();
    
    let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
    let api = APICalls();

    var refreshControl : UIRefreshControl?;
    let appvar = ApplicationVariables.applicationvariables;
    //check to see if the long term storage contains at least one controller registered. if not ; seque to the add controller screen.
    let JSONObject: [String : AnyObject] = [
        "login_token" : ApplicationVariables.applicationvariables.logintoken ]

    override func viewDidLoad() {
        super.viewDidLoad()

        
        btnAlert.enabled = false;
        //btnAlert.tintColor = UIColor.clearColor();
        
//        let error = NSErrorPointer()
        
//        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//        refreshControl.tintColor = [UIColor grayColor];
//        [refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
//        [self.collectionView addSubview:refreshControl];
//        self.collectionView.alwaysBounceVertical = YES;

        self.refreshControl = UIRefreshControl();
        self.refreshControl!.tintColor = UIColor.whiteColor();
        self.refreshControl!.addTarget(self, action: #selector(HomeViewController.reload), forControlEvents: UIControlEvents.ValueChanged);
        self.collectionView?.addSubview(self.refreshControl!);
        self.collectionView?.alwaysBounceVertical = true;
        
        
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
            btn_menu_hamburger.target = self.revealViewController()
            btn_menu_hamburger.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        self.setNeedsStatusBarAppearanceUpdate()

        if let layout = collectionView?.collectionViewLayout as? HomeCollectionViewLayout {
            layout.delegate = self
        }

        //Get latest image from AWS
        

        if (remoSelected.count == 0 && appdel.my_remo_selected == nil) {
            // No remo on account
            let setupRemo = self.storyboard?.instantiateViewControllerWithIdentifier("setupRemo");
            self.presentViewController(setupRemo!, animated: true, completion: nil)
            return;
        }
        
        if(remoSelected["commnetwork"]  == nil){
            remoSelected = appdel.my_remo_selected!;
            
            //let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
            //appdel.my_remo_selected = remoSelected;
        }
        else{
            appdel.my_remo_selected = remoSelected;
        }
        
        //Set up the Alert button to be meaningful. Call the alerts list and if there is one in the non-3 state, then show the alert view controller...
        //pass the alerts along the seque.
        let controller_id = self.remoSelected["_id"] as! String;
        
        //all/true/0/10 =  get "All" devices, get the current alerts (no history), skip 0 records, return 10 records...10
        api.apicallout("/api/accounts/alerts/" + controller_id + "/all/true/0/10/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in

            let statechangeevents = StateChangeEvents(json: response as! Dictionary<String,AnyObject>);
            for statechange in statechangeevents!.statechanges{
                if statechange.current_state_id != 3 {
                    self.statechangeevents.append(statechange);
                }
            }
            //reload?
            dispatch_async(dispatch_get_main_queue()
                , { () -> Void in
                    if self.statechangeevents.count > 0{
                        //show the alert icon
                        self.self.btnAlert.enabled = true;
                        //self.self.btnAlert.tintColor = nil;
                    }
            })
        });
        
        //register the notification deviceToken with the server.
        let defaults = NSUserDefaults.standardUserDefaults();
        if let savedDeviceToken = defaults.stringForKey("deviceToken") {
            api.apicallout("/api/registerNotifications/iOS/" + savedDeviceToken + "/" + controller_id + "/" + appvar.logintoken, iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
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
        //let transferManager: AWSS3TransferManager =  AWSS3TransferManager.registerS3TransferManagerWithConfiguration(configuration, forKey: "xxx");
        
        if self.revealViewController() != nil {
            let x = self.revealViewController().rearViewController;
            x.viewDidLoad();
        }
        
        collectionView!.registerClass(capabilityCollectionViewCell.self, forCellWithReuseIdentifier: "capabilityCollectionViewCell")
        collectionView!.registerClass(CameraCollectionViewCell.self, forCellWithReuseIdentifier: "cameraCell")

//        self.collectionView?.contentOffset = CGPointMake(0, -self.refreshControl!.frame.size.height);
        reload(true);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        // TODO - check how long it's been since we refreshed and possibly reload our REMO.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let alertdestination = segue.destinationViewController as? DeviceCapability_Alerts {
            alertdestination.statechangeevents = self.statechangeevents;
            return
        }
        else
        {
            let indexPath: NSIndexPath = (self.collectionView?.indexPathsForSelectedItems()?.first)!

            if (self.capabilities[indexPath.item].device_type_id == -1) {

                if let photoDestination = segue.destinationViewController as? PhotoViewController {
                    photoDestination.photo = self.cameraCapability.image;
                    return;
                }
            }
            else {
                let deviceCapability: Capability = capabilities[indexPath.item]
                // Get the new view controller using segue.destinationViewController.
                if let destination = segue.destinationViewController as? DeviceCapabilityTabBarController {
                    // Pass the selected object to the new view controller.
                    destination.selectedRemoControllerID = self.remoSelected["_id"] as! String;
                    destination.selectedCapability = deviceCapability;
                }
            }
        }
    }
    
    func reload(isInitialLoad: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshControl!.beginRefreshing();
        });
        // Initial load, we already have a "selected" remo with a photo URL.
        if (!isInitialLoad) {
            // We need to re-fetch the list of controllers to get it's main photo
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
        } else {
            loadCapabilities();
        }
    }
    
    func loadCapabilities() {
        let transferManager = AWSS3TransferManager.S3TransferManagerForKey("xxx");

        let commnetwork = remoSelected["commnetwork"] as! String;
        let bucketname = "thriveboatawarebucket" + commnetwork.stringByReplacingOccurrencesOfString("THRIVE-", withString: "");
        let bucket_photo = remoSelected["photo"] as! String;
        self.title = remoSelected["controller_name"] as? String;
        
        
        //AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        //let downloadFilePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("download")
        let downloadingFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("download")
        let downloadingFilePath = downloadingFileURL.path!
        
        let api = APICalls();
        let controller_id = self.remoSelected["_id"] as! String;
        
        api.getControllerCapabilities(controller_id, handler: { (response) in
            // Loop through the devices
            
            self.capabilities.removeAll();
            
            for _device in response.devices {
                for _capability in _device.capabilities {
                    if (_capability.input == "Camera") {
                        self.capabilities.insert(self.cameraCapability, atIndex: 0);
                    }
                    self.capabilities.append(_capability);
                }
            }
            dispatch_async(dispatch_get_main_queue()
                , { () -> Void in
                    self.collectionView!.reloadData()
                    self.refreshControl!.endRefreshing();
            })
        });
        
        //let downloadingFileURL = NSURL(fileURLWithPath:downloadFilePath)
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

                    self.collectionView?.collectionViewLayout.invalidateLayout();
                    let img = UIImage(contentsOfFile: downloadingFilePath);
                    self.cameraCapability.image = img;
                    if let cell = self.collectionView?.cellForItemAtIndexPath(cameraPhotoIndexPath) as? CameraCollectionViewCell {
                        cell.imageView.image = img;
                        cell.imageView.setNeedsDisplay();
                        cell.layoutIfNeeded();
                        cell.activityIndicator.stopAnimating();
                    }
                })
            }

            return nil
        }
    }
    
}

extension HomeViewController {
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (self.capabilities[indexPath.item].device_type_id == -1) {
            let cameraCell = collectionView.dequeueReusableCellWithReuseIdentifier("CameraCell", forIndexPath: indexPath) as! CameraCollectionViewCell
//                cell.deviceCapability = self.capabilities[indexPath.item]
            cameraCell.deviceCapability = self.cameraCapability;
            return cameraCell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DeviceCapabilityCell", forIndexPath: indexPath) as! DeviceCapabilityCell
        cell.deviceCapability = self.capabilities[indexPath.item]
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.capabilities.count;
    }
}

extension HomeViewController : HomeCollectionViewLayoutDelegate {
    // 1. Returns the photo height
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath , withWidth width:CGFloat) -> CGFloat {
        let deviceCapability = self.capabilities[indexPath.item]
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        if let image = deviceCapability.image {
            let rect  = AVMakeRectWithAspectRatioInsideRect(image.size, boundingRect)
            return rect.size.height
        }
        let rect = CGRect(x: 0, y: 0, width: width / 3.0, height: width / 3.0)
        return rect.size.height
    }
    
    // 2. Returns the annotation size based on the text
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
//        let annotationPadding = CGFloat(4)
//        let annotationHeaderHeight = CGFloat(17)
        
//        let photo = photos[indexPath.item]
//        let font = UIFont(name: "AvenirNext-Regular", size: 10)!
//        let commentHeight = photo.heightForComment(font, width: width)
        let commentHeight = CGFloat(24)
//        _ = annotationPadding + annotationHeaderHeight + commentHeight + annotationPadding
        return commentHeight
    }
    
    func collectionView(collectionView: UICollectionView, hasPhotoAtIndexPath indexPath:NSIndexPath) -> Bool {
        return (self.capabilities[indexPath.item].device_type_id == -1)
    }
}