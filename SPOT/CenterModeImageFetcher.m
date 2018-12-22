//
//  DetailsImageFetcher.m
//  SPOT
//
//  Created by Truong Anh Tuan on 9/30/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "CenterModeImageFetcher.h"
#import "AppDelegate.h"
#import "ImageUtility.h"

@interface CenterModeImageFetcher() {
    float width;
    float height;
}

@end

@implementation CenterModeImageFetcher
AppDelegate *appDelegate;

- (id)initWithFrameWidth: (float)frameWidth andFrameHeight: (float)frameHeight {
    self = [super init];
    width = frameWidth;
    height = frameHeight;
    return self;
}

- (UIImage *)load:(NSString *)fileName {
    @autoreleasepool {
        NSString *documentsDirectory = [appDelegate applicationDocumentsDirectoryForImage];
        NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        UIImage *image = [UIImage imageWithContentsOfFile:savedImagePath];
        if (image) {
            UIImage *centeredImage = [ImageUtility centerModeImageFrom:image withFrameWidth:width andFrameHeight:height];
            return centeredImage;
        }
        
        return nil;
    }
}

@end
