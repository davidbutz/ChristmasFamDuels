//
//  DeviceCapability.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/8/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class DeviceCapability {

    class func allDeviceCapabilities() -> [DeviceCapability] {
        var photos = [DeviceCapability]()
        if let URL = NSBundle.mainBundle().URLForResource("DeviceCapabilities", withExtension: "plist") {
            if let photosFromPlist = NSArray(contentsOfURL: URL) {
                for dictionary in photosFromPlist {
                    let photo = DeviceCapability(dictionary: dictionary as! NSDictionary)
                    photos.append(photo)
                }
            }
        }
        return photos
    }

    var name: String
    var value: String?
    var image: UIImage?
    var status: String?
    
    init(name: String, value: String?, image: UIImage?, status: String?) {
        self.name = name
        self.value = value
        self.image = image
        self.status = status
    }
    
    convenience init(dictionary: NSDictionary) {
        let name = dictionary["Name"] as? String
        let value = dictionary["Value"] as? String
        let photo = dictionary["Photo"] as? String
        var image : UIImage?
        if photo != nil {
            image = UIImage(named: photo!)?.decompressedImage
        }
        let status = dictionary["Status"] as? String
        self.init(name: name!, value: value, image: image, status: status)
    }

    func heightForComment(font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: name).boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }
}
