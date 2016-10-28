//
//  DeviceCapabilityCell.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/8/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import QuartzCore

class DeviceCapabilityCell : UICollectionViewCell {
    
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var statusCell: StatusView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var iconBorderImageView: UIImageView!
    @IBOutlet private weak var statusImageView: UIImageView!
    
    let cornerRadius = CGFloat(10.0)
    
    private func overlayStrokeImageWithTint(imageNamed: String, color: UIColor) {
        self.iconBorderImageView.hidden = false;
        self.iconBorderImageView.image = UIImage(named: imageNamed + "-stroke");
        self.iconBorderImageView.tintColor = nil;
        self.iconBorderImageView.tintColor = color;
    }
    
    var deviceCapability: Capability? {
        didSet {
            if let deviceCapability = deviceCapability {
                self.iconBorderImageView.hidden = true;
                statusImageView.hidden = false;
                switch (deviceCapability.devicecapabilities[0].current_state_id) {
                    case 1:
                        statusImageView.image = UIImage(named: "critical")
                        self.overlayStrokeImageWithTint(deviceCapability.capability_name, color: UIColor.redColor());
                        break;
                    case 2:
                        //error_filled_yellow
                        statusImageView.image = UIImage(named: "error_filled_yellow")
                        self.overlayStrokeImageWithTint(deviceCapability.capability_name, color: UIColor.orangeColor());
                        break;
                    
                    case 5:
                        statusImageView.image = UIImage(named: "critical")
                        self.overlayStrokeImageWithTint(deviceCapability.capability_name, color: UIColor.redColor());
                        break;
                    case 4:
                        statusImageView.image = UIImage(named: "error_filled_yellow")
                        self.overlayStrokeImageWithTint(deviceCapability.capability_name, color: UIColor.orangeColor());
                        break;
                    default:
                        statusImageView.hidden = true;
                }
                
                captionLabel.text = deviceCapability.capability_name;
                statusCell.deviceCapability = deviceCapability.devicecapabilities[0]
                if (deviceCapability.image != nil) {
                    statusCell.hidden = true
                    iconImageView.hidden = true;
                }
                else {
                    if let icon = UIImage(named: deviceCapability.capability_name) {
                        iconImageView.image = icon;
                        iconImageView.hidden = false;
                    }
                    statusCell.hidden = true
                }
            }
        }
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
    }
}
