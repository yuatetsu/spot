//
//  ImageUtility.m
//  SPOT
//
//  Created by nguyen hai dang on 9/11/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "ImageUtility.h"

@implementation ImageUtility

+(UIImage *)resizeToSmallerImage:(UIImage *)image withNewSize:(CGSize)newSize isCut:(BOOL)isCut{
    @autoreleasepool {
        if (image == nil) {
            NSLog(@"--------------------------NoImage----------------------");
            return [UIImage new];
        }
        UIImage *originalImage = image;
        
        CGFloat newWidth;
        CGFloat newHeight;
        
        if(!isCut){
            
            if (image.size.width/newSize.width*2>=image.size.height/newSize.height*2) {
                
                newWidth = newSize.width*2;
                newHeight = image.size.height * (newSize.width*2/image.size.width);
                
            }
            else {
                
                newHeight = newSize.height*2;
                newWidth = image.size.width * (newSize.height*2/image.size.height);
            }
        }
        
        else{
            
            
            if (image.size.width/newSize.width*2>=image.size.height/newSize.height*2) {
                
                newHeight = newSize.height*2;
                newWidth = image.size.width * (newSize.height*2/image.size.height);
                
            }
            else {
                
                newWidth = newSize.width*2;
                newHeight = image.size.height * (newSize.width*2/image.size.width);
            }
        }
        
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), YES, 0.0);
        [originalImage drawInRect:CGRectMake(0,0,newWidth,newHeight)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

+ (UIImage *)centerModeImageFrom: (UIImage *)image withFrameWidth: (float)frameWidth andFrameHeight: (float)frameHeight {
    @autoreleasepool {
        if (image == nil) {
            NSLog(@"--------------------------NoImage----------------------");
            return [UIImage new];
        }
        
        float newWidth, newHeight;
        
        float originalRatio = image.size.width / image.size.height;
        float newRatio = frameWidth/frameHeight;
        
        if (originalRatio > newRatio) {
            newHeight = frameHeight;
            newWidth = image.size.width * frameHeight / image.size.height;
        }
        else {
            newWidth = frameWidth;
            newHeight = image.size.height * frameWidth /image.size.width;
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), YES, 0.0);
        [image drawInRect:CGRectMake(0,0,newWidth,newHeight)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

@end
