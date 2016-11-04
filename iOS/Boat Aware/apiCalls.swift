//
//  apiCalls.swift
//  ChristmasFanDuel
//
//  Created by Dave Butz on 12/21/15.
//  Copyright © 2015 Dave Butz. All rights reserved.
//

import Foundation
import UIKit

class LeagueVariable {
    var leagueName:String;
    var leagueID:String;
    var leagueOwnerID:String;
    var roleID:NSNumber;
    init(leagueName:String,leagueID:String,leagueOwnerID:String, roleID:NSNumber){
        self.leagueID = leagueID;
        self.leagueName = leagueName;
        self.leagueOwnerID = leagueOwnerID;
        self.roleID = roleID;
    }
}

struct LeagueVariables{
    static var leaguevariables = LeagueVariable(leagueName:"fake",leagueID: "fake",leagueOwnerID: "fake", roleID: 0);
}

class ApplicationVariable {
    var username:String;
    var logintoken:String;
    var account_id:String;
    var userid:String;
    var fname:String;
    var lname:String;
    var account_name:String;
    var password:String;
    var resettoken:String;
    var loggedin:Bool;
    var cellphone:String;
    
    init(username:String, logintoken:String, account_id: String, userid: String, fname: String, lname: String, account_name: String, password: String, resettoken: String, loggedin: Bool, cellphone: String) {
        self.username = username;
        self.logintoken = logintoken;
        self.account_id = account_id;
        self.userid = userid;
        self.fname = fname;
        self.lname = lname;
        self.account_name = account_name;
        self.password = password;
        self.resettoken = resettoken;
        self.loggedin = loggedin;
        self.cellphone = cellphone;
    }
}

struct ApplicationVariables {
    //static var yourVariable = "someString";
    static var applicationvariables = ApplicationVariable(username:"test",logintoken:"fake",account_id: "fake",userid: "fake", fname: "fake", lname: "fake", account_name: "fake", password: "fake", resettoken: "fake", loggedin: false, cellphone: "fake");
}

struct ApplicationFunctions {
    static func globaldisplayAlert(viewcontroller: UIViewController, userMessage:String, fn:()->Void){
        let myAlert = UIAlertController(title:"Alert",message: userMessage,preferredStyle: UIAlertControllerStyle.Alert);
        let okAction = UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in fn()});
        myAlert.addAction(okAction);
        viewcontroller.presentViewController(myAlert, animated: true, completion: nil);
    }
    
    static func switchView(viewcontroller: UIViewController, viewtoswitch:String){
        let settingview = viewcontroller.storyboard?.instantiateViewControllerWithIdentifier(viewtoswitch);
        viewcontroller.navigationController?.presentViewController(settingview!, animated: true, completion: nil);
    }
    
    static func switchViewRegister(viewcontroller: UIViewController, viewtoswitch:String){
        let settingview = viewcontroller.storyboard?.instantiateViewControllerWithIdentifier(viewtoswitch);
        viewcontroller.presentViewController(settingview!, animated: true, completion: nil)
        //viewcontroller.navigationController?.presentViewController(settingview!, animated: true, completion: nil);
    }
}

class APIResponse {
    var error : NSError?
    var success : Bool
    var data : JSONDictionary?
    
    init(error: NSError) {
        self.error = error;
        self.success = false;
    }
    
    init(success: Bool) {
        self.success = success;
    }

    init(success: Bool, data: JSONDictionary) {
        self.success = success;
        self.data = data;
    }

}

class APICalls {
    
    //apicallout is a generic call to an api.
    func apicallout( endpoint: String ,iptype: String, method: String , JSONObject: [String : AnyObject], callback: (AnyObject) -> Void) {
        
        //get the ip address/url of the api environment.
        let defaults = NSUserDefaults.standardUserDefaults();
        let ipaddress = defaults.stringForKey(iptype);
        
        
        //example: endpoint = "/api/authenticate"
        let postEndPoint: String = ipaddress! + endpoint;
        let request :  NSMutableURLRequest = NSMutableURLRequest();
        request.URL = NSURL(string:postEndPoint);
        request.HTTPMethod = method;
        request.timeoutInterval = 120;
        request.addValue("application/json", forHTTPHeaderField: "Content-Type");
        request.addValue("application/json", forHTTPHeaderField: "Accept");
            if(request.HTTPMethod != "GET"){
            do{
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(JSONObject, options: NSJSONWritingOptions(rawValue:0));
            }
            catch let error as NSError{
                print("apicallout Error \(error)")
            }
        }
        let conf: NSURLSessionConfiguration = NSURLSession.sharedSession().configuration;
        let session = NSURLSession(configuration: conf);
        print("API Request to \(request.URL)");
        session.dataTaskWithRequest(request) {
            (data: NSData?,  resp: NSURLResponse?, error: NSError?) in
            if (error != nil) {
                print(error?.description);
                callback(error!);
                return; // do not parse result!
            }
                if (nil == data) {
                print("NO RESPONSE FROM API CALL");
                return;
            }
            let resp = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let data: NSData = resp!.dataUsingEncoding(NSUTF8StringEncoding)!;
            do{
                let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions());
                //print(jsonObject);
                callback(jsonObject as! Dictionary<String, AnyObject>);
            }
            catch let error as NSError{
                print("TEST Error \(error)")
                //TODO: display something meaningful to the end user.
                callback(NSDictionary(dictionary: ["success": false, "error": error]));
            }
            }.resume()
    }

    ///
    /// Logout of the API
    func logout(token: String, handler:(APIResponse)->Void) {
        
    }
    
    func login(email: String, password: String, handler:(APIResponse)->Void) {
        let JSONObject: [String : AnyObject] = [
            "username" : email ,
            "password" : password ,
            ]
        let defaults = NSUserDefaults.standardUserDefaults();
        
        let ipaddress = defaults.stringForKey("localIPAddress");
        let postEndPoint: String = ipaddress! + "/api/authenticate";
        
        let request :  NSMutableURLRequest = NSMutableURLRequest();
        request.URL = NSURL(string:postEndPoint);
        request.HTTPMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type");
        request.addValue("application/json", forHTTPHeaderField: "Accept");
        do{
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(JSONObject, options: NSJSONWritingOptions(rawValue:0));
        }
        catch let error as NSError{
            return handler(APIResponse(error: error));
        }
        
        let conf: NSURLSessionConfiguration = NSURLSession.sharedSession().configuration;
        let session = NSURLSession(configuration: conf);
        session.dataTaskWithRequest(request) {
            (data: NSData?,  resp: NSURLResponse?, error: NSError?) in
            let resp = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let data: NSData = resp!.dataUsingEncoding(NSUTF8StringEncoding)!;
            do{
                let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions());
                let status = (jsonObject as! NSDictionary)["status"] as! String;
                //let message = (jsonObject as! NSDictionary)["message"] as! String;
                let authenticationtoken = (jsonObject as! NSDictionary)["token"] as! String;
                let firstname = (jsonObject as! NSDictionary)["fname"] as! String;
                let lastname = (jsonObject as! NSDictionary)["lname"] as! String;
                let account_id = (jsonObject as! NSDictionary)["account_id"] as! String;
                let account_name = (jsonObject as! NSDictionary)["account_name"] as! String;
                let userid = (jsonObject as! NSDictionary)["userid"] as! String;
                let cellphone = (jsonObject as! NSDictionary)["cellphone"] as! String;
                let username = email;
                if(status=="success"){
                    let appvar = ApplicationVariables.applicationvariables;
                    appvar.username = username;
                    appvar.logintoken = authenticationtoken;
                    appvar.userid = userid;
                    appvar.account_id = account_id;
                    appvar.fname = firstname;
                    appvar.lname = lastname;
                    appvar.account_name = account_name;
                    appvar.password = password;
                    appvar.cellphone = cellphone;
                    
                    NSUserDefaults.standardUserDefaults().setObject(authenticationtoken, forKey: "authenticationtoken");
                    NSUserDefaults.standardUserDefaults().setObject(email, forKey: "userEmail");
                    NSUserDefaults.standardUserDefaults().setObject(password, forKey: "userPassword");
                    
                    handler(APIResponse(success: true, data: jsonObject as! JSONDictionary));
                }
                else {
                    handler(APIResponse(success: false, data: jsonObject as! JSONDictionary));
                }
            }
            catch let error as NSError{
                handler(APIResponse(error: error));
            }
            }.resume()
    }
    
    func register(email: String, password: String, fname: String, lname: String, cell: String, handler:(APIResponse)->Void) {

        let JSONObject: [String : AnyObject] = [
            "account_name": email,
            "username" : email,
            "password" : password,
            "fname" : fname,
            "lname" : lname,
            "cellphone" : cell
        ];
        
        let defaults = NSUserDefaults.standardUserDefaults();
        
        let stringOne = defaults.stringForKey("localIPAddress");
        if let stringOne = defaults.stringForKey("localIPAddress") {
            print(stringOne) // Some String Value
        }
        let postEndPoint: String = stringOne! + "/api/register";
        let request :  NSMutableURLRequest = NSMutableURLRequest();
        request.URL = NSURL(string:postEndPoint);
        request.HTTPMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type");
        request.addValue("application/json", forHTTPHeaderField: "Accept");
        do{
            
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(JSONObject, options: NSJSONWritingOptions(rawValue:0));
        }
        catch let error as NSError{
            return handler(APIResponse(error: error));
        }
        
        let conf: NSURLSessionConfiguration = NSURLSession.sharedSession().configuration;
        let session = NSURLSession(configuration: conf);
        session.dataTaskWithRequest(request) {
            (data: NSData?,  resp: NSURLResponse?, error: NSError?) in
            let resp = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let data: NSData = resp!.dataUsingEncoding(NSUTF8StringEncoding)!;
            do{
                let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions());
                let status = (jsonObject as! NSDictionary)["status"] as! String;
                
                if(status=="success"){
                    handler(APIResponse(success: true, data: jsonObject as! JSONDictionary));
                }
                else {
                    handler(APIResponse(success: false, data: jsonObject as! JSONDictionary));
                }
            }
            catch let error as NSError{
                return handler(APIResponse(error: error));
            }
            }.resume()
    }
}