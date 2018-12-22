//
//  SpotImagePager.h
//  SPOT
//
//  Created by Truong Anh Tuan on 10/6/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "KIImagePager.h"
@class SPOT;

@protocol SpotImagePagerDelegate <NSObject>

- (void) didSelectImageAtIndex:(NSUInteger)index sender:(id)sender;

@end

@interface SpotImagePager : KIImagePager <KIImagePagerDataSource, KIImagePagerDelegate>

@property (nonatomic) SPOT *spot;
@property (weak, nonatomic) id <SpotImagePagerDelegate> imageDelegate;

@end
