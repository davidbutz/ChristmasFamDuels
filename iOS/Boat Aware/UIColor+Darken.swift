//
//  UIColor+Darken.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/9/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

extension UIColor {

    var darkerColor : UIColor {
        var h : CGFloat = 0
        var s : CGFloat = 0
        var b : CGFloat = 0
        var a : CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
        return UIColor(hue: h, saturation: s, brightness: b * 0.75, alpha: a)
        }
        return self;
        
    }

    func fromWeb(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    static func boatAwareGreen() -> UIColor {
        return UIColor(red: 51.0/255.0, green: 153.0/255.0, blue: 0.0, alpha: 1.0);
    }
    static func boatAwareBlue() -> UIColor {
        return UIColor(red: 0.0/255.0, green: 51.0/255.0, blue: 102.0, alpha: 1.0);
    }
    static func boatAwareOrange() -> UIColor {
        return UIColor(red: 255.0/255.0, green: 128.0/255.0, blue: 0.0, alpha: 1.0);
    }
    static func boatAwareRed() -> UIColor {
        return UIColor(red: 204.0/255.0, green: 0.0/255.0, blue: 0.0, alpha: 1.0);
    }
    
    static func boatAwareWarning() -> UIColor {
        return UIColor(red: 255.0/255.0, green: 153.0/255.0, blue: 0.0, alpha: 1.0);
    }
    static func boatAwareCritical() -> UIColor {
        return UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0, alpha: 1.0);
    }
    static func boatAwareNormal() -> UIColor {
        return UIColor(red: 0.0/255.0, green: 153.0/255.0, blue: 0.0, alpha: 1.0);
    }
}