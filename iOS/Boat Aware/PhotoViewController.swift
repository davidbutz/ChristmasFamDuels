//
//  PhotoViewController.swift
//  Boat Aware
//
//  Created by Adam Douglass on 6/17/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import AWSS3

class PhotoViewController : UIViewController {
    
    var photo : UIImage?; //= UIImage(contentsOfFile: downloadingFilePath);
    var selectedItem: AWSContent?;
    
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView!;
    @IBOutlet weak var progressIndicator : UIProgressView!;
    @IBOutlet weak var scrollView : UIScrollView!;
    @IBOutlet weak var imageView : UIImageView!;
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    private var oldTint : UIColor?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if let navBar = self.navigationController?.navigationBar {
            self.oldTint = navBar.barTintColor;
            navBar.barTintColor = UIColor.blackColor();
        }
        
        if (photo != nil) {
            self.imageView.image = self.photo;
            self.imageView.layoutIfNeeded();
        }
        if (selectedItem != nil) {
            // Load the selected item from AWS
            self.loadingIndicator.startAnimating();
            self.title = self.selectedItem!.description();
            
            downloadFromS3();
            
        }
        // Double-tap to zoom in/out
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PhotoViewController.doubleTap));
        doubleTap.numberOfTapsRequired = 2;
        self.scrollView.addGestureRecognizer(doubleTap);
    }
    
    func doubleTap(gestureRecognizer: UIGestureRecognizer) {
        if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true);
        }
        else {
            zoomRectForScale(self.scrollView.maximumZoomScale, center: gestureRecognizer.locationInView(gestureRecognizer.view));
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) {
        var zoomRect = CGRect();
        
        zoomRect.size.height = self.imageView.frame.size.height / scale;
        zoomRect.size.width  = self.imageView.frame.size.width  / scale;
        
        let zoomCenter = self.imageView.convertPoint(center, fromView: self.scrollView);
        zoomRect.origin.x    = zoomCenter.x - ((zoomRect.size.width / 2.0));
        zoomRect.origin.y    = zoomCenter.y - ((zoomRect.size.height / 2.0));

        self.scrollView.zoomToRect(zoomRect, animated: true);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        
        // Return the nav bar to it's normal color;
        if let navBar = self.navigationController?.navigationBar {
            navBar.barTintColor = oldTint;
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        
        scrollView.zoomScale = minScale
    }
    
    private func updateConstraintsForSize(size: CGSize) {
        
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All;
    }
    
}

extension PhotoViewController {
    func downloadFromS3() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:fa4674f7-7bc2-4847-ba61-44dc47f29bce");
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider);
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration;
        
        let contentKey = selectedItem?.key;
        let contentType = selectedItem?.contenttype;

        var pathComponentText = "download";
        if contentType == "Video"{
            pathComponentText = "download.mp4";
        }

        let downloadingFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(pathComponentText)
        let downloadingFilePath = downloadingFileURL.path!
        
        let appdel = UIApplication.sharedApplication().delegate as! AppDelegate;
        let commnetwork = appdel.my_remo_selected!["commnetwork"] as! String;
        let bucketname = "thriveboatawarebucket" + commnetwork.stringByReplacingOccurrencesOfString("THRIVE-", withString: "");


        let getImageRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        getImageRequest.bucket = bucketname;
        getImageRequest.key = contentKey;
        getImageRequest.downloadingFileURL = downloadingFileURL;
        
        // Progress Indicator
        getImageRequest.downloadProgress = {
            (bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.progressIndicator.hidden = false;
                self.progressIndicator.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite + 1);
                });
        };
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager();
        let task = transferManager.download(getImageRequest)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                let error = task.error?.description;
                print("Error during S3 Download: \(error)");
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.loadingIndicator.stopAnimating();
                    self.progressIndicator.hidden = true;
                    self.imageView.image = UIImage(contentsOfFile: downloadingFilePath);
                    self.imageView.layoutIfNeeded();
                    self.view.layoutIfNeeded()
                    self.updateMinZoomScaleForSize(self.view.bounds.size)
                })
            }
            return nil;
        }
    }
}

extension PhotoViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
}