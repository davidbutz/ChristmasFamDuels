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
    
    
    @IBOutlet weak var lblArtistLable: UILabel!
    
    @IBOutlet weak var lblReleaseLable: UILabel!
    
    @IBOutlet weak var lblScore: UILabel!
    
    @IBOutlet weak var lblWeekLable: UILabel!
    
    
    @IBOutlet weak var imgArtist: UIImageView!
    
    
    @IBOutlet weak var imgRelease: UIImageView!
    
    @IBOutlet weak var lblSong: UILabel!
    
    @IBAction func onClickSong(sender: AnyObject) {
        self.api.apicallout("/api/view/thresholdOK/" + self.lineupvar.lineupID + "/" + self.appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (okresponse) -> () in
            let success =  (okresponse as! NSDictionary)["success"] as! Bool;
            if(success){
                let cleanedname = self.appvar.fname + " " + self.appvar.lname;
                self.api.apicallout("/api/scoring/points/heardsong/" + cleanedname.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/" + self.leaguevar.leagueID + "/" + self.lineupvar.song.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/" + self.lineupvar.songID + "/" + self.lineupvar.lineupID + "/" + self.appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (okresponse) -> () in
                    let success =  (okresponse as! NSDictionary)["success"] as! Bool;
                    if(success){
                        self.displayAlert("Awaiting Confirmation.", fn: {self.doNothing()});
                        return;
                    }
                    else{
                        self.displayAlert("Problem with Scoring.", fn: {self.doNothing()});
                        return;
                    }
                });
            }
            else{
                self.displayAlert("Need to wait 3 minutes between scoring.", fn: {self.doNothing()});
                return;
            }
        });
    }
    
    @IBAction func onClickArtist(sender: AnyObject) {
        self.api.apicallout("/api/view/thresholdOK/" + self.lineupvar.lineupID + "/" + self.appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (okresponse) -> () in
            let success =  (okresponse as! NSDictionary)["success"] as! Bool;
            if(success){
                let cleanedname = self.appvar.fname + " " + self.appvar.lname;
                self.api.apicallout("/api/scoring/points/heardartist/" + cleanedname.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/" + self.leaguevar.leagueID + "/" + self.lineupvar.artist.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/" + self.lineupvar.artistID + "/" + self.lineupvar.lineupID + "/" + self.appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (okresponse) -> () in
                    let success =  (okresponse as! NSDictionary)["success"] as! Bool;
                    if(success){
                        self.displayAlert("Awaiting Confirmation.", fn: {self.doNothing()});
                        return;
                    }
                    else{
                        self.displayAlert("Problem with Scoring.", fn: {self.doNothing()});
                        return;
                    }
                });
            }
            else{
                self.displayAlert("Need to wait 3 minutes between scoring.", fn: {self.doNothing()});
                return;
            }
        });

    }
    
    
    @IBAction func onClickRelease(sender: AnyObject) {
        self.api.apicallout("/api/view/thresholdOK/" + self.lineupvar.lineupID + "/" + self.appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (okresponse) -> () in
            let success =  (okresponse as! NSDictionary)["success"] as! Bool;
            if(success){
                let cleanedname = self.appvar.fname + " " + self.appvar.lname;
                self.api.apicallout("/api/scoring/points/heardrelease/" + cleanedname.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/" + self.leaguevar.leagueID + "/" + self.lineupvar.release.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/" + self.lineupvar.releaseID + "/" + self.lineupvar.lineupID + "/" + self.appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (okresponse) -> () in
                    let success =  (okresponse as! NSDictionary)["success"] as! Bool;
                    if(success){
                        self.displayAlert("Awaiting Confirmation.", fn: {self.doNothing()});
                        return;
                    }
                    else{
                        self.displayAlert("Problem with Scoring.", fn: {self.doNothing()});
                        return;
                    }
                });
            }
            else{
                self.displayAlert("Need to wait 3 minutes between scoring.", fn: {self.doNothing()});
                return;
            }
        });

    }
    
    
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
    let lineupvar = LineUpVariables.lineupvariables;
    var refreshControl : UIRefreshControl?;
    var pointsearned = 0;
    
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
            api.apicallout("/api/registerNotifications/iOS/" + savedDeviceToken + "/" + leaguevar.leagueID + "/" + appvar.logintoken, iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
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
        api.apicallout("/api/setlineup/week/getcurrent/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (weekresponse) -> () in
            self.currentweekvar.weekID = (weekresponse as! NSDictionary)["_id"] as! String;
            self.currentweekvar.weekStart = NSDate(dateStringhms: (weekresponse as! NSDictionary)["weekStart"] as! String);
            self.currentweekvar.weekEnd = NSDate(dateStringhms: (weekresponse as! NSDictionary)["weekEnd"] as! String);
            
            // loadWeeklyPlaySheet
            self.loadWeeklyPlaySheet();
        });
        
        api.apicallout("/api/setlineup/week/getnext/" + appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (nextweekresponse) -> () in
            self.nextweekvar.weekID = (nextweekresponse as! NSDictionary)["_id"] as! String;
            self.nextweekvar.weekStart = NSDate(dateStringhms: (nextweekresponse as! NSDictionary)["weekStart"] as! String);
            self.nextweekvar.weekEnd = NSDate(dateStringhms: (nextweekresponse as! NSDictionary)["weekEnd"] as! String);
        });
    
        
        // Do any additional setup after loading the view.
        // reload(true);
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
        loadWeeklyPlaySheet();
    }
    
    func loadWeeklyPlaySheet() {
        
        // get lineup
        self.api.apicallout("/api/view/getLineUp/" + self.currentweekvar.weekID + "/" + self.leaguevar.userxleagueID + "/" + self.appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (lineupresponse) -> () in
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
            
                // get Points
                self.api.apicallout("/api/view/summarizepoints/" + self.lineupvar.lineupID + "/" + self.appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: self.JSONObject, callback: { (pointresponse) -> () in
                    let success =  (pointresponse as! NSDictionary)["success"] as! Bool;
                    if(success){
                        dispatch_async(dispatch_get_main_queue()) {
                            self.pointsearned = (pointresponse as! NSDictionary)["points"] as! Int;
                        };
                    }
                    self.provisionScreen();
                });
                // load Image(s)
                let artistKeyName = self.appvar.userid + "_search_artist_" + self.currentweekvar.weekID + ".jpg";
                let releaseKeyName = self.appvar.userid + "_search_release_" + self.currentweekvar.weekID + ".jpg";
                self.loadImage(artistKeyName, uiImageName: "artist");
                self.loadImage(releaseKeyName, uiImageName: "release");
            }
            else{
                //send them to "Set Lineup"
                dispatch_async(dispatch_get_main_queue()) {
                    let inviteFriends = self.storyboard?.instantiateViewControllerWithIdentifier("Set Lineup");
                    self.presentViewController(inviteFriends!, animated: true, completion: nil);
                }
            }
        });
    }

    func provisionScreen(){
        dispatch_async(dispatch_get_main_queue()) {
            self.lblSong.text = self.lineupvar.song;
            self.lblArtistLable.text = self.lineupvar.artist;
            self.lblReleaseLable.text = self.lineupvar.release;
            //TODO: make the week label better...
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            formatter.timeStyle = .NoStyle
            
            let dateString = formatter.stringFromDate(self.currentweekvar.weekEnd);
            
            self.lblWeekLable.text = "Week ending " + dateString;
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
                        self.imgRelease.image = img;
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
