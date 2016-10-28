//
//  LoadingView.swift
//  ThriveIOSPrototype
//
//  Created by Dave Butz on 1/11/16.
//  Copyright © 2016 Dave Butz. All rights reserved.
//

import Foundation
import UIKit

public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var captionLabel = UILabel()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    func setCaption(caption: String) {
        captionLabel.text = caption
    }
    
    public func showOverlay(view: UIView) {
        
        overlayView.frame = CGRectMake(0, 0, 300, 300)
        overlayView.center = view.center
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(overlayView.bounds.width / 2, overlayView.bounds.height / 2)
        
        captionLabel.frame = CGRectMake(10, 200, 290, 40);
        //        captionLabel.backgroundColor = UIColor.blackColor()
        captionLabel.textColor = UIColor.whiteColor()
        captionLabel.adjustsFontSizeToFitWidth = true
        captionLabel.textAlignment = NSTextAlignment.Center
        //captionLabel!.text = "Loading..."

        overlayView.addSubview(captionLabel);
        overlayView.addSubview(activityIndicator);
        view.addSubview(overlayView)
        
        activityIndicator.startAnimating()
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        captionLabel.removeFromSuperview();
        activityIndicator.removeFromSuperview();
        overlayView.removeFromSuperview()
    }
}

class LoadingView : UIView {
    
    var captionLabel : UILabel?
    
    func setCaption(caption: String) {
        captionLabel!.text = caption
    }
    
    func done() {
        self.removeFromSuperview()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        let hudView = UIView(frame: CGRectMake(aRect.width/2.0 - (170/2.0), aRect.height/2.0 - (170/2.0), 170, 170))
        hudView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        hudView.clipsToBounds = true
        hudView.layer.cornerRadius = 10.0
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicatorView.frame = CGRectMake(65, 40, activityIndicatorView.bounds.size.width, activityIndicatorView.bounds.size.width)
        hudView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        captionLabel = UILabel(frame: CGRectMake(20, 115, 130, 22))
        //        captionLabel.backgroundColor = UIColor.blackColor()
        captionLabel!.textColor = UIColor.whiteColor()
        captionLabel!.adjustsFontSizeToFitWidth = true
        captionLabel!.textAlignment = NSTextAlignment.Center
        //captionLabel!.text = "Loading..."
        hudView.addSubview(captionLabel!)
        
        self.addSubview(hudView)
    }
    
    //    convenience override init() {
    //        self.init(frame:CGRectZero)
    //    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}
