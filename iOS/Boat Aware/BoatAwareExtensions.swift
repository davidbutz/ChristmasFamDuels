//
//  BoatAwareExtensions.swift
//  Boat Aware
//
//  Created by Dave Butz on 5/31/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import Foundation
import UIKit

class DateExtensions {
    static func currentTime() -> String {
        let dateFormatter = NSDateFormatter();
        dateFormatter.timeStyle = .ShortStyle;
        dateFormatter.locale = NSLocale.currentLocale();
        return dateFormatter.stringFromDate(NSDate());
    }
    
    static func dateDiff(datefrom:NSDate) -> String {
        let f:NSDateFormatter = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone();
        f.dateFormat = "yyyy-M-dd'T'HH:mm:ss.SSSZZZ";
        
        let now = f.stringFromDate(NSDate());
        let startDate = datefrom;
        let endDate = f.dateFromString(now);
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        //      NSCalendarUnit.NSWeekOfMonthCalendarUnit
        //        let calendarUnits = NSCalendarUnit.NSDayCalendarUnit | NSCalendarUnit.NSHourCalendarUnit
        let dateComponents = calendar.components([.WeekOfMonth, .Day, .Hour, .Minute, .Second], fromDate: startDate, toDate: endDate!,options: []);
        
        let weeks = abs(dateComponents.weekOfMonth)
        let days = abs(dateComponents.day)
        let hours = abs(dateComponents.hour)
        let min = abs(dateComponents.minute)
        let sec = abs(dateComponents.second)
        
        var timeAgo = ""
        
        if (sec > 0){
            if (sec > 1) {
                timeAgo = "\(sec) seconds ago"
            } else {
                timeAgo = "\(sec) second ago"
            }
        }
        
        if (min > 0){
            if (min > 1) {
                timeAgo = "\(min) minutes ago"
            } else {
                timeAgo = "\(min) minute ago"
            }
        }
        
        if(hours > 0){
            if (hours > 1) {
                timeAgo = "\(hours) hours ago"
            } else {
                timeAgo = "\(hours) hour ago"
            }
        }
        
        if (days > 0) {
            if (days > 1) {
                timeAgo = "\(days) days ago"
            } else {
                timeAgo = "\(days) day ago"
            }
        }
        
        if(weeks > 0){
            if (weeks > 1) {
                timeAgo = "\(weeks) weeks ago"
            } else {
                timeAgo = "\(weeks) week ago"
            }
        }
        
//        print("timeAgo is===> \(timeAgo)")
        return timeAgo;
    }
}

