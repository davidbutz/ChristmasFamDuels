//
//  selectorViewController.swift
//  Christmas Fam Duels
//
//  Created by Dave Butz on 11/5/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3

class selectorViewController: FormViewController {

    @IBOutlet weak var txtInput1: UITextField!

    @IBOutlet weak var txtInput2: UITextField!
    
    @IBOutlet weak var imgResults: UIImageView!
    
    @IBOutlet weak var lblResults: UILabel!
    
    @IBOutlet weak var lblResultsLbl: UILabel!
    
    @IBOutlet weak var btnJustUse: UIButton!
    
    @IBOutlet weak var lblDiscogsID: UILabel!
    
    
    @IBOutlet weak var btnSet: UIButton!
    
    @IBAction func onClickResultsWrong(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in

            //get rid of the image
            self.imgResults.hidden = true;
            //delete image from AWS....
            if(self.SearchType == "artist"){
                //set the text to what is literally typed in...
                self.lblResults.text = self.txtInput2.text!;
            }
            if(self.SearchType == "song"){
                //set the text to what is literally typed in...
                self.lblResults.text = self.txtInput2.text!;
            }
            if(self.SearchType == "release"){
                //set the text to what is literally typed in...
                self.lblResults.text = self.txtInput1.text! + " - " + self.txtInput2.text!;
            }
        });
    }
    
    @IBAction func onClickSet(sender: AnyObject) {
        let appvar = ApplicationVariables.applicationvariables;
        let weekvar = WeekVariables.nextweekvariables;
        let leaguevar = LeagueVariables.leaguevariables;
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        let api = APICalls();
        var apiURL = "";
        if(SearchType == "artist"){
            apiURL = "/api/setlineup/add/artist/" + lblResults.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/" + self.lblDiscogsID.text! + "/";
            apiURL += appvar.logintoken;
        }
        if(SearchType == "song"){
            apiURL = "/api/setlineup/add/song/" + lblResults.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/";
            apiURL += appvar.logintoken;
        }
        if(SearchType == "release"){
            apiURL = "/api/setlineup/add/release/" + lblResults.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/" + self.lblDiscogsID.text! + "/";
            apiURL += appvar.logintoken;
        }
        api.apicallout(apiURL , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            let JSONResponse = response as! JSONDictionary;
            var IDReturned = "";
            if(JSONResponse["success"] as! Bool){
                var apiURL = "";
                if(self.SearchType == "artist"){
                    IDReturned = JSONResponse["artistID"] as! String;
                    apiURL = "/api/setlineup/artist/" + appvar.logintoken + "/" + leaguevar.leagueID + "/";
                    apiURL += leaguevar.userxleagueID + "/" + IDReturned + "/" + weekvar.weekID;
                }
                if(self.SearchType == "song"){
                    IDReturned = JSONResponse["songID"] as! String;
                    apiURL = "/api/setlineup/song/" + appvar.logintoken + "/" + leaguevar.leagueID + "/";
                    apiURL += leaguevar.userxleagueID + "/" + IDReturned + "/" + weekvar.weekID;
                }
                if(self.SearchType == "release"){
                    IDReturned = JSONResponse["releaseID"] as! String;
                    apiURL = "/api/setlineup/release/" + appvar.logintoken + "/" + leaguevar.leagueID + "/";
                    apiURL += leaguevar.userxleagueID + "/" + IDReturned + "/" + weekvar.weekID;
                }
                api.apicallout(apiURL , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (setresponse) -> () in
                    let JSONResponse = setresponse as! JSONDictionary;
                    if(JSONResponse["success"] as! Bool){
                        dispatch_async(dispatch_get_main_queue()) {
                            self.navigationController?.popViewControllerAnimated(true);
                        }
                        //send them to Set Lineup
                        /*dispatch_async(dispatch_get_main_queue()) {
                            self.performSegueWithIdentifier("backtoSetLineup", sender: nil);
                        }*/
                        /*dispatch_async(dispatch_get_main_queue()) {
                            let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("Set Lineup");
                            self.presentViewController(settingview!, animated: true, completion: nil)
                        }*/
                    }
                    else{
                        self.displayAlert("Couldn't save the data", fn: {self.doNothing()});
                        return;
                    }
                });
            }
            else{
                self.displayAlert("Couldn't save the data", fn: {self.doNothing()});
                return;
            }
        });
    }
    
    var SearchType = "";
    var foundResults = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtInput1.delegate = self;
        self.txtInput2.delegate = self;
        txtInput1.resignFirstResponder();
        txtInput2.resignFirstResponder();
        btnSet.hidden = true;
        lblResultsLbl.hidden = true;
        btnJustUse.hidden = true;
        // Do any additional setup after loading the view.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.txtInput1) {
            self.txtInput2.becomeFirstResponder()
        }
        else if (textField == self.txtInput2) {
            doSearch();
        }
        else {
            self.view.endEditing(true);
        }
        return false;
    }

    func doSearch(){
        let appvar = ApplicationVariables.applicationvariables;
        let weekvar = WeekVariables.nextweekvariables;
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        let api = APICalls();
        var apiURL = "";
        var imageKeyName = "";
        if(SearchType == "artist"){
            apiURL = "/api/setlineup/search/artist/" + txtInput2.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/";
            apiURL += appvar.logintoken + "/" + appvar.userid + "/" + weekvar.weekID;
            imageKeyName = appvar.userid + "_search_artist_" + weekvar.weekID + ".jpg";
        }
        if(SearchType == "song"){
            apiURL = "/api/setlineup/search/song/" + txtInput2.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/";
            apiURL += appvar.logintoken + "/" + appvar.userid + "/" + weekvar.weekID;
            imageKeyName = appvar.userid + "_search_song_" + weekvar.weekID + ".jpg";
        }
        if(SearchType == "release"){
            apiURL = "/api/setlineup/search/release/" + txtInput2.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/";
            apiURL += txtInput1.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "/" + appvar.logintoken + "/" + appvar.userid + "/" + weekvar.weekID;
            imageKeyName = appvar.userid + "_search_release_" + weekvar.weekID + ".jpg";
        }
        api.apicallout(apiURL , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            var resultText = "";
            var discogID = 0;
            let JSONResponse = response as! JSONDictionary;
            if(JSONResponse["success"] as! Bool){
                if(self.SearchType == "artist"){
                    if let jsonResultText = JSONResponse["artist"] as! String?{
                        resultText = jsonResultText;
                        discogID = Int((JSONResponse["discogArtistID"] as! NSNumber?)!)
                    }
                    else{
                        resultText = self.txtInput2.text!;
                    }
                }
                if(self.SearchType == "song"){
                    if let jsonResultText = JSONResponse["song"] as! String?{
                        resultText = jsonResultText;
                    }
                    else{
                        resultText = self.txtInput2.text!;
                    }                }
                if(self.SearchType == "release"){
                    if let jsonResultText = JSONResponse["track"] as! String?{
                        let artist = JSONResponse["artist"] as! String?
                        resultText = artist! + "-" + jsonResultText;
                        discogID = Int((JSONResponse["releaseID"] as! NSNumber?)!)
                    }
                    else{
                        resultText = self.txtInput1.text! + " - " + self.txtInput2.text!;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.lblResults.text = resultText;
                    self.lblDiscogsID.text = String(discogID);
                    self.btnSet.hidden = false;
                    self.lblResultsLbl.hidden = false;
                    self.btnJustUse.hidden = false;
                });
                
                self.loadImage(imageKeyName);
            }
            else {
                if(self.SearchType == "artist"){
                    resultText = self.txtInput2.text!;
                }
                if(self.SearchType == "song"){
                    resultText = self.txtInput2.text!;              }
                if(self.SearchType == "release"){
                    resultText = self.txtInput1.text! + " - " + self.txtInput2.text!;
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.lblResults.text = resultText;
                    self.lblDiscogsID.text = "0";
                    self.btnSet.hidden = false;
                });
            }

        });
    }
    
    override func viewWillAppear(animated: Bool) {
        if(SearchType == "artist"){
            txtInput1.hidden = true;
            txtInput2.placeholder = "Type artist name";
        }
        if(SearchType == "song"){
            txtInput1.hidden = true;
            txtInput2.placeholder = "Type song name";
        }
        if(SearchType == "release"){
            txtInput1.hidden = false;
            txtInput1.placeholder = "Type artist name";
            txtInput2.placeholder = "Type song name";
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImage(bucket_photo:String){
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
                    self.imgResults.image = img;
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
