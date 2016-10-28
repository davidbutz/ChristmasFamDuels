//
//  HomeCollectionViewLayout.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/8/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

protocol HomeCollectionViewLayoutDelegate {
    // 1
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath,
        withWidth:CGFloat) -> CGFloat
    // 2
    func collectionView(collectionView: UICollectionView,
        heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
    
    func collectionView(collectionView: UICollectionView,
        hasPhotoAtIndexPath indexPath: NSIndexPath) -> Bool
}


class HomeCollectionViewLayoutAttributes:UICollectionViewLayoutAttributes {
    
    // 1. Custom attribute
    var photoHeight: CGFloat = 0.0
    var hasPhoto: Bool = false
    
    // 2. Override copyWithZone to conform to NSCopying protocol
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! HomeCollectionViewLayoutAttributes
        copy.photoHeight = photoHeight
        copy.hasPhoto = hasPhoto
        return copy
    }
    
    // 3. Override isEqual
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? HomeCollectionViewLayoutAttributes {
            if( (attributes.photoHeight == photoHeight)  &&  (attributes.hasPhoto == hasPhoto) ) {
                return super.isEqual(object)
            }
        }
        return false
    }
}


class HomeCollectionViewLayout : UICollectionViewLayout {
    //1. Pinterest Layout Delegate
    var delegate:HomeCollectionViewLayoutDelegate!
    
    //2. Configurable properties
    var numberOfColumns : Int = 3
    var cellPadding: CGFloat = 0.0

    //3. Array to keep a cache of attributes.
    private var cache = [HomeCollectionViewLayoutAttributes]()
    
    //4. Content height and size
    private var contentHeight:CGFloat  = 0.0
    private var contentWidth: CGFloat {
        // TODO handle rotated device dimensions
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return HomeCollectionViewLayoutAttributes.self
    }
    
    override func invalidateLayout() {
        self.cache.removeAll();
        super.invalidateLayout();
    }
    override func prepareLayout() {
        
        numberOfColumns = Int(round(contentWidth / 120.0));
        print("NUMBER_OF_COLUMNS = \(numberOfColumns)")
        // 1. Only calculate once
        if cache.isEmpty {
            
            // 2. Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)
            
            // 3. Iterates through the list of items in the first section
            for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                
                // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
                var width = columnWidth - cellPadding*2
                let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath , withWidth:contentWidth)
                let hasPhoto = delegate.collectionView(collectionView!, hasPhotoAtIndexPath: indexPath)
                let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
                var height = cellPadding + annotationHeight + cellPadding
                if (hasPhoto) {
                    // Start a new ROW
                    column = 0
                    width = contentWidth
                    height += photoHeight
                }
                else {
                    height += (contentWidth / CGFloat(numberOfColumns))
                }
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: width, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                
                // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
                let attributes = HomeCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.hasPhoto = hasPhoto
                attributes.photoHeight = photoHeight
                attributes.frame = insetFrame
                cache.append(attributes)
                
                // 6. Updates the collection view content height
                contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                if (hasPhoto) {
                    for ycolumn in 0 ..< numberOfColumns {
                        yOffset[ycolumn] = yOffset[ycolumn] + height
                    }
                } else {
                    yOffset[column] = yOffset[column] + height
                }
                if (column >= (numberOfColumns - 1)) {
                    column = 0;
                }
                else {
                    column += 1;
                }
//                column = column >= (numberOfColumns - 1) ? 0 : ++column
            }
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes  in cache {
            if CGRectIntersectsRect(attributes.frame, rect ) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}
