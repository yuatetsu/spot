//
//  ImageUtility.h
//  SPOT
//
//  Created by nguyen hai dang on 9/11/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtility : NSObject

+(UIImage *)resizeToSmallerImage:(UIImage *)image withNewSize:(CGSize) newSize isCut:(BOOL)isCut;

//+ (UIImage *)squareImageFrom: (UIImage *)image withLength: (float)length;

+ (UIImage *)centerModeImageFrom: (UIImage *)image withFrameWidth: (float)frameWidth andFrameHeight: (float)frameHeight;

@end
