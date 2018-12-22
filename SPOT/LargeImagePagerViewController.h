//
//  LargeImagePagerViewController.h
//  SPOT
//
//  Created by framgia on 7/28/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImagePager.h"

@interface LargeImagePagerViewController : UIPageViewController

@property (strong, nonatomic) NSArray *imageFileNameArray;
@property NSUInteger currentPageIndex;



@end
