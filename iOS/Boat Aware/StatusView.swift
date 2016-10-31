//
//  StatusView.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/8/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

//@IBDesignable
class StatusView: UIView {
    
    @IBOutlet private weak var statusLabel : UILabel!
    
    var deviceCapability: DeviceCapabilityNew?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        layer.cornerRadius = frame.width / 2.0
        layer.masksToBounds = true
        
        // Based on Status, green/yellow/red
        if let thisDeviceCapability = deviceCapability {
            var color = UIColor.greenColor()
            

            switch (thisDeviceCapability.current_state_id) {
                case 1:
                    color = UIColor.redColor()
                case 2:
                    color = UIColor.yellowColor()
                case 5:
                    color = UIColor.redColor()
                case 4:
                    color = UIColor.yellowColor()
                default:
                    //green2 (b6d7a8)
                    color = UIColor(red: CGFloat(182.0/255.0), green: CGFloat(215.0/255.0), blue: CGFloat(168.0/255.0), alpha: CGFloat(1.0))
            }
                self.backgroundColor = color
                self.layer.borderColor = color.darkerColor.CGColor
                self.layer.borderWidth = 2.0;
            
            if (deviceCapability?.current_value) != nil {
                statusLabel.text = String(thisDeviceCapability.current_value_string);//String(format: "%.2f", thisDeviceCapability.current_value);
            }
        }
    }
    
//    @IBInspectable var cornerRadius: CGFloat = 0 {
//        didSet {
//            layer.cornerRadius = cornerRadius
//            layer.masksToBounds = cornerRadius > 0
//        }
//    }
    
}