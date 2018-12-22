//
//  Banner.h
//  SPOT
//
//  Created by nguyen hai dang on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADBannerView.h"
#import "GADRequest.h"


@interface Banner : NSObject <GADBannerViewDelegate>

MU_SINGLETON_INTERFACE_PATTERN (Banner);

@property (nonatomic, strong) GADBannerView *smallBannerView;
@property (nonatomic, strong) GADBannerView *mediumBannerView;

@property (nonatomic, strong) GADRequest *smallBannerRequest;
@property (nonatomic, strong) GADRequest *mediumBannerRequest;

@property (nonatomic, assign) BOOL isErroring;

-(void)showSmallBanner;
-(void)hideSmallBanner;

-(void)showSmallBannerAboveToolbar;
-(void)hideSmallBannerAboveToolbar;

-(void)showMediumBannerViewInView:(UIView*)view;
-(void)hideMediumBanner;

-(void)creatBanner;
-(BOOL) shouldShowAds;
@end
