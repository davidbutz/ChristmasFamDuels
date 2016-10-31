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

class DeviceCapabilityRuleRanges{
    var state_id: NSNumber;
    var gte: NSNumber;
    var lt: NSNumber;
    
    init?(rulerange: JSONDictionary){
        self.state_id = rulerange["state_id"] as! NSNumber;
        self.gte = rulerange["gte"] as! NSNumber;
        self.lt = rulerange["lt"] as! NSNumber;
    }
    
}

class DeviceCapabilityRule{
    var rule_name: String;
    var current_state_id: NSNumber;
    var date_of_change: NSDate?;
    var rule_range =  Array<DeviceCapabilityRuleRanges>();
    init?(rule: JSONDictionary ){
        let dateformatter = NSDateFormatter();
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        dateformatter.timeZone = NSTimeZone(name: "UTC");
        self.current_state_id = rule["current_state_id"] as! NSNumber;
        if let date_of_change = rule["dateofchange"] as? String{
           self.date_of_change = dateformatter.dateFromString(date_of_change)!;
        }
        self.rule_name = rule["name"] as! String;
        for ranges in rule["ranges"] as! Array<JSONDictionary>{
            self.rule_range.append(DeviceCapabilityRuleRanges(rulerange: ranges )!);
        }
    }
    init?(rulenative: DeviceCapabilityRule){
        self.current_state_id = rulenative.current_state_id;
        self.date_of_change = rulenative.date_of_change;
        self.rule_name = rulenative.rule_name;
        self.rule_range = rulenative.rule_range;
    }
}

class DeviceCapabilityRules{
    var last_observation_date: NSDate?;
    var rules =  Array<DeviceCapabilityRule>();
    init?(devicecapabilityrule: JSONDictionary ){
        if let serializedDate = devicecapabilityrule["observationdate"] as? String{
            let dateformatter = NSDateFormatter();
            dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            dateformatter.timeZone = NSTimeZone(name: "UTC");
            self.last_observation_date = dateformatter.dateFromString(serializedDate);
        }
        for rules in devicecapabilityrule["rules"] as! Array<JSONDictionary>{
            self.rules.append(DeviceCapabilityRule(rule: rules )!);
        }
    }
    
}


class DeviceCapabilityNew{
    var device_capability_id: String;
    var device_id: String;
    var capability_identification_id: String;
    var current_state_id: NSNumber;
    var current_value: NSNumber;
    var current_value_string: NSString;
    var last_updated: NSDate?;
    var image: UIImage?
    
    init?(devicecapability: JSONDictionary){
        self.device_capability_id = devicecapability["_id"] as! String;
        self.device_id = devicecapability["device_id"] as! String;
        self.capability_identification_id = devicecapability["capability_identification_id"] as! String;
        self.current_state_id = devicecapability["current_state_id"] as! NSNumber;
        self.current_value = (devicecapability["current_value"] as! NSString).doubleValue;
        self.current_value_string = devicecapability["current_value"] as! NSString;
        if (devicecapability["last_updated"] as? NSString) != nil{
            let serializedDate = devicecapability["last_updated"] as! String;
            let dateformatter = NSDateFormatter();
            dateformatter.timeZone = NSTimeZone(name: "UTC");
            dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            self.last_updated = dateformatter.dateFromString(serializedDate)!;
        }
    }
}

class Capability{
    var capability_id: String;
    var capability_name: String;
    var device_type_id: NSNumber;
    var input: String;
    var settings: JSONDictionary;
    var devicecapabilities =  Array<DeviceCapabilityNew>();
    var image: UIImage?
    
    init(name: String) {
        self.capability_id = name;
        self.capability_name = name;
        self.input = name;
        self.device_type_id = -1;
        self.settings = JSONDictionary();
    }
    
    init?(capability: JSONDictionary ){
        self.capability_id = capability["_id"] as! String;
        self.capability_name = capability["capability_name"] as! String;
        self.device_type_id = capability["device_type_id"] as! NSNumber;
        self.input = capability["input"] as! String;
        self.settings = capability["settings"] as! JSONDictionary;
        for device_capabilities in capability["devicecapabilities"] as! Array<JSONDictionary>{
            self.devicecapabilities.append(DeviceCapabilityNew(devicecapability: device_capabilities )!);
        }
    }
    
    func heightForComment(font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: capability_name).boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }
}

class Device{
    var device_id: String
    var controller_id: String
    var device_type_id: NSNumber
    //var datecreated: NSDate
    var capabilities = Array<Capability>()
    
    init?(json: JSONDictionary){
        self.device_id = json["_id"] as! String;
        self.controller_id = json["controller_id"] as! String;
        self.device_type_id = json["device_type_id"] as! NSNumber;
        //self.datecreated = devices["datecreated"] as! NSDate;
        let xyz = json["capabilities"] as! Array<JSONDictionary>;
        for device_capability in xyz{
            self.capabilities.append(Capability(capability: device_capability)!);
        }
    }
}

class ControllerCapabilitiesResponse {
    var devices : Array<Device>;
    
    init(json: JSONDictionary) {
        self.devices = Array<Device>();
        for _deviceJson in json["devices"] as! Array<JSONDictionary> {
            if let device = Device(json: _deviceJson) {
                self.devices.append(device);
            }
        }
    }
}


class ControllersPopulated {
    var controllerspopulated: Array<Controller>
    init?(controllerspopulated: Array<Controller> ){
        self.controllerspopulated = controllerspopulated
    }
}

class Controller : NSObject{
    var _id: String
    var controller_name:String
    var controller_id:String
    var account_id: String
    var commport: NSNumber
    var commipaddress: String
    var commnetwork: String
    var commnetworkpassword: String
    var overall_status_id: NSNumber
    var photo: String
    var image: UIImage?
    
    init?(controller: JSONDictionary){
        self._id = controller["_id"] as! String
        self.controller_name = controller["controller_name"] as! String
        self.controller_id = controller["controller_id"] as! String
        self.account_id = controller["account_id"] as! String
        self.commport = controller["commport"] as! NSNumber
        self.commipaddress = controller["commipaddress"] as! String
        self.commnetwork = controller["commnetwork"] as! String
        self.commnetworkpassword = controller["commnetworkpassword"] as! String
        self.overall_status_id = controller["overall_status_id"] as! NSNumber
        self.photo = controller["photo"] as! String
    }
}

class Controllers{
    var controllers: JSONDictionary
    init?(controllers: JSONDictionary){
        self.controllers = controllers
    }

}



