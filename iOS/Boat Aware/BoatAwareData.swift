//
//  BoatAwareData.swift
//  ChristmasFanDuel
//
//  Created by Dave Butz on 1/6/16.
//  Copyright © 2016 Dave Butz. All rights reserved.
//

import Foundation

typealias JSONArray = Array<AnyObject>
typealias JSONDictionary = Dictionary<String, AnyObject>

class User{
    
    //MARK: Properties
    var UserID: String
    var UserName: String
    var Password: String
    var FirstName: String
    var LastName: String
    
    //MARK: Initialization
    init?(UserID: String, UserName: String, Password: String, FirstName: String, LastName: String){
        self.FirstName = FirstName
        self.LastName = LastName
        self.UserID = UserID
        self.Password = Password
        self.UserName = UserName
    }
}

class Login{
    var user_id: String
    var login_token: String
    var validuntil: NSDate
    
    init?(user_id: String, login_token: String, validuntil: NSDate){
        self.login_token = login_token
        self.user_id = user_id
        self.validuntil = validuntil
    }
}

class AWSContent{
    var key: String
    var contenttype: String
    var lastmodified: NSDate?
    
    func description() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle;
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle;
        return dateFormatter.stringFromDate(self.lastmodified!);
    }
    init?(json: JSONDictionary){
        self.key = json["Key"] as! String
        self.contenttype = json["ContentType"] as! String
        let dateformatter = NSDateFormatter();
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        if let last_modified = json["LastModified"] as? String{
            self.lastmodified = dateformatter.dateFromString(last_modified)!;
        }
    }
}

class AWSContents{
    var contents = Array<AWSContent>();
    init?(json: JSONDictionary){
        for content in json["bucketcontents"] as! Array<JSONDictionary>{
            self.contents.append(AWSContent(json: content)!);
        }
    }
}

