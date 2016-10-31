//
//  cameraCollectionViewCell.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/8/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//w

import UIKit

class CameraCollectionViewCell: UICollectionViewCell {
    //    required init(coder aDecoder: NSCoder) {
    //        super.init(coder: aDecoder)!
    //    }
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet internal weak var imageView: UIImageView!
    @IBOutlet private weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet internal weak var activityIndicator : UIActivityIndicatorView!
    
    var deviceCapability: Capability? {
        didSet {
            if let deviceCapability = deviceCapability {
                imageView.image = deviceCapability.image
                imageView.hidden = false
                imageView.layer.borderWidth = 2.0;
                imageView.layer.borderColor = UIColor.whiteColor().CGColor;
                captionLabel.text = deviceCapability.capability_name;
                
            }
        }
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        if let attributes = layoutAttributes as? HomeCollectionViewLayoutAttributes {
            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
        }
    }
}