//
//  DeviceCapability_AWSContent.swift
//  Boat Aware
//
//  Created by Dave Butz on 4/26/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3
import AVKit

class DeviceCapability_AWSContent: UIViewController {
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    var selectedContent : AWSContent?;
    var remoSelected = JSONDictionary();
    
    var selectedCapability : Capability?
    var selectedRemoControllerID : String = "";
    
    var playerAsset: AVAsset!
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var playerViewController: AVPlayerViewController!
    
    @IBOutlet var imgPhoto: UIImageView!
    
    @IBOutlet var btnPlay: UIButton!
    
    @IBAction func btnPlayPressed(sender: AnyObject) {
        self.playerViewController.player = self.player;
        self.presentViewController(playerViewController!, animated: true) {
            self.playerViewController!.player!.play();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPlay.hidden = true;
        //let appvar = ApplicationVariables.applicationvariables;
        if(remoSelected["commnetwork"]  == nil){
            let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
            remoSelected = appdel.my_remo_selected!;
        }
        
        let contentKey = selectedContent?.key;
        let contentType = selectedContent?.contenttype;
        
        
        //get the image off the remoSelected
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:fa4674f7-7bc2-4847-ba61-44dc47f29bce");
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider);
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration;
        
        _ = AWSS3TransferManager.registerS3TransferManagerWithConfiguration(configuration, forKey: "xxx");
        //let transferManager: AWSS3TransferManager =  AWSS3TransferManager.registerS3TransferManagerWithConfiguration(configuration, forKey: "xxx");
        let transferManager = AWSS3TransferManager.S3TransferManagerForKey("xxx");
        if(remoSelected["commnetwork"]  != nil){
            //let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
            //remoSelected = appdel.my_remo_selected!;
            let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
            appdel.my_remo_selected = remoSelected;
        }
        let commnetwork = remoSelected["commnetwork"] as! String;
        let bucketname = "thriveboatawarebucket" + commnetwork.stringByReplacingOccurrencesOfString("THRIVE-", withString: "");
        var pathComponentText = "download";
        if contentType == "Video"{
            pathComponentText = "download.mp4";
        }
        let downloadingFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(pathComponentText)
        let downloadingFilePath = downloadingFileURL.path!
        
        let getImageRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        getImageRequest.bucket = bucketname;
        getImageRequest.key = contentKey;
        getImageRequest.downloadingFileURL = downloadingFileURL;
        let task = transferManager.download(getImageRequest)
        task.continueWithBlock { (task) -> AnyObject! in
            print(task.error)
            if task.error != nil {
                let error = "";
                print(error);
            } else {
                dispatch_async(dispatch_get_main_queue()
                    , { () -> Void in
                        
                        if contentType == "Photo"{
                            self.imgPhoto.image = UIImage(contentsOfFile: downloadingFilePath);
                            self.btnPlay.hidden = true;
                        }
                        else{
                            //"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
                            //"https://s3-us-west-2.amazonaws.com/thriveboatawarebucket000f6001bf87/20160211021309.h264";
                            //let videoURL = NSURL(string: "https://s3-us-west-2.amazonaws.com/thriveboatawarebucket000f6001bf87/Sample.mp4")
                            self.imgPhoto.hidden = true;
                            let dlfp = downloadingFilePath;
                            let avAsset = AVURLAsset(URL: NSURL(fileURLWithPath: dlfp))
                            self.playerAsset = avAsset;//AVURLAsset(URL: downloadingFileURL);
                            self.playerItem = AVPlayerItem(asset: self.playerAsset);
                            self.player = AVPlayer(playerItem: self.playerItem);
                            //let playerViewController = AVPlayerViewController();
                            self.btnPlay.hidden = false;
                        }
                        print("Fetched image/video");
                })
            }
            return nil
        }
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        //let videoURL = NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        //let y = AVAsset(URL: videoURL!);
        //let x = AVPlayerItem(asset: y);
        //let me = AVPlayer(playerItem: x)
        //let player = AVPlayer(URL: videoURL!);
        //let playerViewController = AVPlayerViewController();
        self.playerViewController = AVPlayerViewController();
        //playerViewController.player = me;
        //self.presentViewController(playerViewController, animated: true) {
        //    playerViewController.player!.play();
        //}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
