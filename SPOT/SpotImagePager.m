//
//  SpotImagePager.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/6/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SpotImagePager.h"
#import "SPOT.h"
#import "KIImagePager.h"
#import "Image.h"
#import "AppDelegate.h"
#import "SPOT+Image.h"

@interface SpotImagePager() 

@property (nonatomic, copy) NSArray *spotImages;
@property (nonatomic) BOOL isFetchingImages;
@property (nonatomic) BOOL isViewPresented;

@end

@implementation SpotImagePager

AppDelegate *appDelegate;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


#pragma mark - KIImagePager Delegate
- (void) imagePager:(KIImagePager *)imagePager didScrollToIndex:(NSUInteger)index
{
//    NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

- (void) imagePager:(KIImagePager *)imagePager didSelectImageAtIndex:(NSUInteger)index
{
//    NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
//    [self performSegueWithIdentifier:@"ShowLargeImagePagerViewController" sender:self];
    
    [self.imageDelegate didSelectImageAtIndex:index sender:self];
}

#pragma mark - KIImagePager DataSource
- (NSArray *) arrayWithImages {

    if (self.spot.image.count > 0) {
        if (!self.spotImages && !self.isFetchingImages) {
            @autoreleasepool {
                
                self.isFetchingImages = YES;
                __weak SpotImagePager *weakSelf = self;
                NSArray *sortedArray = [self.spot sortedImages];
                NSMutableArray *fileNames = [NSMutableArray new];
                
                for (Image *image in sortedArray) {
                    [fileNames addObject:image.image_file_name];
                }
                
                [appDelegate.spotSlideImageCacher getImageByFileNames:fileNames completionHandler:^(BOOL success, NSArray *images) {
                    @autoreleasepool {
                        SpotImagePager *innerSelf = weakSelf;
                        innerSelf.isFetchingImages = NO;
                        if (success) {
                            innerSelf.spotImages = images;
                        }
                        else {
                            innerSelf.spotImages = nil;
                        }
                        [innerSelf reloadData];
                    }
                }];
            }
            
        }
        return self.spotImages;
    }
    return nil;
    
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleAspectFill;
}

- (NSString *) captionForImageAtIndex:(NSUInteger)index
{
    return nil;
}

- (void)dealloc {
    self.spotImages = nil;
    [self reloadData];
    self.delegate = nil;
    NSLog(@"SpotImagePager died.");
}


@end
