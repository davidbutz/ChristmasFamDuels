//
//  UIImage+Decompression.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/8/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

extension UIImage {
    
    var decompressedImage: UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        drawAtPoint(CGPointZero)
        let decompressedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return decompressedImage
    }

    
    func imageWithColoredBorder(borderThickness: CGFloat, borderColor: UIColor, withShadow: Bool) -> UIImage {
        var shadowThichness : CGFloat = 0.0;
        if (withShadow) {
            shadowThichness = 2.0;
        }

        
        //
        //    size_t newWidth = self.size.width + 2 * borderThickness + 2 * shadowThickness;
        //    size_t newHeight = self.size.height + 2 * borderThickness + 2 * shadowThickness;
        //    CGRect imageRect = CGRectMake(borderThickness + shadowThickness, borderThickness + shadowThickness, self.size.width, self.size.height);
        let newWidth = self.size.width + 2.0 * borderThickness + 2.0 * shadowThichness;
        let newHeight = self.size.height + 2.0 * borderThickness + 2.0 * shadowThichness;
        let imageRect = CGRectMake(borderThickness + shadowThichness, borderThickness + shadowThichness, self.size.width, self.size.height);
        
        //
        //    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        //    CGContextRef ctx = UIGraphicsGetCurrentContext();
        let ctx = UIGraphicsGetCurrentContext();
        //    CGContextSaveGState(ctx);
        CGContextSaveGState(ctx);
        //    CGContextSetShadow(ctx, CGSizeZero, 4.5f);
//        CGContextSetShadow(ctx, CGSizeZero, 4.5);
        CGContextSetShadowWithColor(ctx, CGSizeZero, 8, borderColor.CGColor);
        //    [color setFill];
//        borderColor.setFill();
        //    CGContextFillRect(ctx, CGRectMake(shadowThickness, shadowThickness, newWidth - 2 * shadowThickness, newHeight - 2 * shadowThickness));
//        CGContextFillRect(ctx, CGRectMake(shadowThichness, shadowThichness, newWidth - 2.0 * shadowThichness, newHeight - 2.0 * shadowThichness));
        //    CGContextRestoreGState(ctx);
//        CGContextDrawImage(ctx, imageRect, self.CGImage);
        self.drawInRect(imageRect);
        CGContextRestoreGState(ctx);
        //    [self drawInRect:imageRect];
        //    //CGContextDrawImage(ctx, imageRect, self.CGImage); //if use this method, image will be filp vertically
        
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
        
//        return UIGraphicsGetImageFromCurrentImageContext();
    }
    
    func drawOutlie(color:UIColor) -> UIImage
    {
        let newImageKoef:CGFloat = 1.08
        
        let outlinedImageRect = CGRect(x: 0.0, y: 0.0, width: self.size.width * newImageKoef, height: self.size.height * newImageKoef)
        
        let imageRect = CGRect(x: self.size.width * (newImageKoef - 1) * 0.5, y: self.size.height * (newImageKoef - 1) * 0.5, width: self.size.width, height: self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(outlinedImageRect.size, false, newImageKoef)
        
        self.drawInRect(outlinedImageRect)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetBlendMode(context, CGBlendMode.SourceIn)
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, outlinedImageRect)
        self.drawInRect(imageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
}