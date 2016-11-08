//
//  DeviceCapabilityViewController.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/9/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3

// LANDING PAGE
class DeviceCapabilityViewController : UIViewController {
    
    let SEPARATOR_HEIGHT = 1;
    
    @IBOutlet weak var capabilityTitle: CapabilityTitleView!
    
    @IBOutlet weak var lblWeek: UILabel!
    
    @IBOutlet weak var lblSong: UILabel!
    
    @IBOutlet weak var lblSongData: UILabel!
    
    @IBOutlet weak var lblArtist: UILabel!
    
    @IBOutlet weak var lblArtistData: UILabel!
    
    @IBOutlet weak var imgSong: UIImageView!
    
    @IBOutlet weak var imgArtist: UIImageView!
    
    @IBOutlet weak var imgBoth: UIImageView!
    
    @IBOutlet weak var lblBoth: UILabel!
    
    @IBOutlet weak var lblBothData: UILabel!
    
    
    
    @IBAction func onClickSelectArtist(sender: AnyObject) {
        SearchType = "artist";
        performSegueWithIdentifier("searchstuff", sender: sender);
    }
    
    @IBAction func onClickSelectSong(sender: AnyObject) {
        SearchType = "song";
        performSegueWithIdentifier("searchstuff", sender: sender);
    }
    
    @IBAction func onClickSelectBoth(sender: AnyObject) {
        SearchType = "release";
        performSegueWithIdentifier("searchstuff", sender: sender);
    }
    

    private var refreshControl : UIRefreshControl?;
    
    var SearchType = "";
    var txtSong = "";
    var txtArtist = "";
    var txtRelease = "";
    
    //let appvar = ApplicationVariables.applicationvariables;
    //let league = LeagueVariables.leaguevariables;
    //let weekvar = WeekVariables.currentweekvariables;
    
    let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
    let api = APICalls();
    let JSONObject: [String : AnyObject] = [
        "login_token" : ApplicationVariables.applicationvariables.logintoken ]
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    let appvar = ApplicationVariables.applicationvariables;
    let leaguevar = LeagueVariables.leaguevariables;
    let currentweekvar = WeekVariables.currentweekvariables;
    let nextweekvar = WeekVariables.nextweekvariables;
    let lineupvar = LineUpVariables.futurelineupvariables;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.automaticallyAdjustsScrollViewInsets = false;
        self.refreshControl = UIRefreshControl();
        //self.refreshControl!.addTarget(self, action: #selector(DeviceCapabilityViewController.reload), forControlEvents: UIControlEvents.ValueChanged);
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        //reload();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        reload();
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? selectorViewController {
            destination.SearchType = self.SearchType;
            return
        }
    }
    
    func reload() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshControl!.beginRefreshing();
        });
        
        //get the image off the remoSelected
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:fa4674f7-7bc2-4847-ba61-44dc47f29bce");
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider);
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration;
        
        _ = AWSS3TransferManager.registerS3TransferManagerWithConfiguration(configuration, forKey: "xxx");
        
        self.loadWeeklyPlaySheet();
    }
    
    func loadWeeklyPlaySheet() {
        
        // get lineup
        self.api.apicallout("/api/view/getLineUp/" + self.nextweekvar.weekID + "/" + self.leaguevar.userxleagueID + "/" + self.appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (lineupresponse) -> () in
            let success =  (lineupresponse as! NSDictionary)["success"] as! Bool;
            if(success){
                self.lineupvar.lineupID = (lineupresponse as! NSDictionary)["_id"] as! String;
                self.lineupvar.songID = (lineupresponse as! NSDictionary)["songID"] as! String;
                self.lineupvar.artistID = (lineupresponse as! NSDictionary)["artistID"] as! String;
                self.lineupvar.releaseID = (lineupresponse as! NSDictionary)["releaseID"] as! String;
                self.lineupvar.weekID = (lineupresponse as! NSDictionary)["weekID"] as! String;
                self.lineupvar.song = (lineupresponse as! NSDictionary)["song"] as! String;
                self.lineupvar.artist = (lineupresponse as! NSDictionary)["artist"] as! String;
                self.lineupvar.discogArtistID = (lineupresponse as! NSDictionary)["discogArtistID"] as! NSNumber;
                self.lineupvar.release = (lineupresponse as! NSDictionary)["release"] as! String;
                self.lineupvar.discogReleaseID = (lineupresponse as! NSDictionary)["discogReleaseID"] as! NSNumber;
                
                
                // load Image(s)
                let artistKeyName = self.appvar.userid + "_search_artist_" + self.nextweekvar.weekID + ".jpg";
                let releaseKeyName = self.appvar.userid + "_search_release_" + self.nextweekvar.weekID + ".jpg";
                self.loadImage(artistKeyName, uiImageName: "artist");
                self.loadImage(releaseKeyName, uiImageName: "release");
                self.provisionScreen();
            }
        });
    }
    
    func provisionScreen(){
        dispatch_async(dispatch_get_main_queue()) {
            self.lblSong.text = self.lineupvar.song;
            self.lblSongData.text = self.lineupvar.songID;
            self.lblArtist.text = self.lineupvar.artist;
            self.lblArtistData.text = String(self.lineupvar.discogArtistID);
            self.lblBoth.text = self.lineupvar.release;
            self.lblBothData.text = String(self.lineupvar.discogReleaseID);
            
            //TODO: make the week label better...
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            formatter.timeStyle = .NoStyle
            
            let dateString = formatter.stringFromDate(self.nextweekvar.weekEnd);
            
            self.lblWeek.text = "Week ending " + dateString;
        }
    }

    
    func loadImage(bucket_photo:String, uiImageName:String){
        let transferManager = AWSS3TransferManager.S3TransferManagerForKey("xxx");
        let downloadingFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("download")
        let downloadingFilePath = downloadingFileURL.path!
        
        let getImageRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        getImageRequest.bucket = "insanerobot-cfd";
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
                    let img = UIImage(contentsOfFile: downloadingFilePath);
                    if(uiImageName == "artist"){
                        self.imgArtist.image = img;
                    }
                    if(uiImageName == "release"){
                        self.imgBoth.image = img;
                    }
                });
            }
            return nil
        }
    }
    
    func displayAlert(userMessage:String, fn:()->Void){
        let myAlert = UIAlertController(title:"Alert",message: userMessage,preferredStyle: UIAlertControllerStyle.Alert);
        let okAction = UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in fn()});
        myAlert.addAction(okAction);
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(myAlert, animated: true, completion: nil);
        };
    }
    
    func doNothing(){
        
    }
}
