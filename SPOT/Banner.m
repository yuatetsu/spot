//
//  Banner.m
//  SPOT
//
//  Created by nguyen hai dang on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "Banner.h"
#import "SPOT.h"
#import "BannerShow.h"

@implementation Banner


MU_SINGLETON_IMPLEMENTATION_PATTERN(Banner)

-(id)init{
    
    if (self = [super init]) {
        
        [self creatBanner];
        
    }
    
    return self;
}

-(void)creatBanner{
   
    _isErroring = NO;
    
    [self createSmallBanner];
//    _smallBannerView.hidden = YES;
    
    
    [self createMediumBanner];
    
}

-(BOOL) shouldShowAds
{
    if (_isErroring) {
        return NO;
    }
    
    BannerShow *bannerShow = [BannerShow MR_findFirst];
    if (!bannerShow) {
        bannerShow = [BannerShow MR_createEntity];
    }
    if (bannerShow.shouldShow) {
        return YES;
    }else {
        NSUInteger numberOfSpots = [SPOT MR_countOfEntities];
        if (numberOfSpots > 4) {
            bannerShow.shouldShow = [NSNumber numberWithBool:YES];
            [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
            return YES;
        }
        else{
            return NO;
        }
    }
    
}

- (void) createSmallBanner {
    @autoreleasepool {
        GADBannerView *smallBannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
        
        smallBannerView.delegate = self;
        smallBannerView.backgroundColor = [UIColor clearColor];
        smallBannerView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-smallBannerView.frame.size.width)/2, [UIScreen mainScreen].bounds.size.height-smallBannerView.frame.size.height,smallBannerView.frame.size.width ,smallBannerView.frame.size.height);
        smallBannerView.adUnitID = AD_UNIT_SMALL;
        
        smallBannerView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        //    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_smallBannerView];
        
        GADRequest *smallBannerRequest = [GADRequest request];
        smallBannerRequest.testDevices = @[ GAD_SIMULATOR_ID ];
        [smallBannerView loadRequest:smallBannerRequest];
        
        for (UIWebView *webView in smallBannerView.subviews) {
            [self disableScrollInUIWebView:webView];
        }
        
        self.smallBannerView = smallBannerView;
        self.smallBannerRequest = smallBannerRequest;
    }
    
}

- (void) createMediumBanner {
    @autoreleasepool {
        GADBannerView *mediumBannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeMediumRectangle];
        
        mediumBannerView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width- mediumBannerView.frame.size.width)/2, 0, mediumBannerView.frame.size.width , mediumBannerView.frame.size.height);
        mediumBannerView.adUnitID = AD_UNIT_MEDIUM;
        mediumBannerView.backgroundColor = [UIColor clearColor];
        mediumBannerView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        
        GADRequest *mediumBannerRequest = [GADRequest request];
        mediumBannerRequest.testDevices = @[ GAD_SIMULATOR_ID ];
        
        [mediumBannerView loadRequest: mediumBannerRequest];
        
        for (UIWebView *webView in mediumBannerView.subviews) {
            [self disableScrollInUIWebView:webView];
        }
        self.mediumBannerView = mediumBannerView;
        self.mediumBannerRequest = mediumBannerRequest;
    }
}

- (void)disableBannerScroll {
    for (UIWebView *webView in self.mediumBannerView.subviews) {
        [self disableScrollInUIWebView:webView];
    }
    
    for (UIWebView *webView in self.smallBannerView.subviews) {
        [self disableScrollInUIWebView:webView];
    }
}

- (void)disableScrollInUIWebView:(UIWebView *)webView {
    for (id view in [[[webView subviews] firstObject] subviews]) {
        if ([view isKindOfClass:NSClassFromString(@"UIWebBrowserView")]) {
            for (UIGestureRecognizer *recognizer in [view gestureRecognizers]) {
                if ([recognizer isKindOfClass:NSClassFromString(@"UIWebTouchEventsGestureRecognizer")]) {
                    [view removeGestureRecognizer:recognizer];
                }
            }
        }
    }
    webView.scrollView.scrollEnabled = NO;
    webView.scrollView.bounces = NO;
}

-(void)showSmallBanner{
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_smallBannerView];
    [[[[UIApplication sharedApplication] delegate] window].rootViewController.view addSubview:_smallBannerView];
    //    _smallBannerView.hidden = NO;
}

-(void)hideSmallBanner{
    if ([self.smallBannerView superview] != nil) {
        [self.smallBannerView removeFromSuperview];
        //    _smallBannerView.hidden = YES;
    }
}


-(void)showSmallBannerAboveToolbar{
    _smallBannerView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-_smallBannerView.frame.size.width)/2, [UIScreen mainScreen].bounds.size.height-_smallBannerView.frame.size.height-44,_smallBannerView.frame.size.width ,_smallBannerView.frame.size.height);
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_smallBannerView];
    [[[[UIApplication sharedApplication] delegate] window].rootViewController.view addSubview:_smallBannerView];
    //    _smallBannerView.hidden = NO;
}

//-(void)showSmallBannerViewInView:(UIView*)view{
//    GADBannerView *bannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
//    bannerView.delegate = self;
//    bannerView.backgroundColor = [UIColor clearColor];
//    bannerView.bounds = CGRectMake(0, 0,320, SMALL_ADS_HEIGHT);
//    
//    bannerView.adUnitID = AD_UNIT;
//    
//    GADRequest *request = [GADRequest request];
//    request.testDevices = [NSArray arrayWithObjects:
//                                       GAD_SIMULATOR_ID, @"ad650050ff71c8edcb5977eb189f3439",
//                                       nil];
//    [bannerView loadRequest:request];
//    
//    [view addSubview:bannerView];
//}

-(void)hideSmallBannerAboveToolbar{
    if ([self.smallBannerView superview] != nil) {
        self.smallBannerView.frame =   CGRectMake(([UIScreen mainScreen].bounds.size.width-self.smallBannerView.frame.size.width)/2, [UIScreen mainScreen].bounds.size.height-self.smallBannerView.frame.size.height,self.smallBannerView.frame.size.width ,self.smallBannerView.frame.size.height);
        [self.smallBannerView removeFromSuperview];
    }
}

-(void)hideMediumBanner{
    if ([self.mediumBannerView superview] != nil) {
        [self.mediumBannerView removeFromSuperview];
    }
}

-(void)showMediumBannerViewInView:(UIView*)view{
//        view.backgroundColor = [UIColor redColor];
    UIView *backgoundBanner = [[UIView alloc] initWithFrame:CGRectMake(0, ADS_MARGIN_HEIGHT, view.bounds.size.width, self.mediumBannerView.bounds.size.height)];
    backgoundBanner.backgroundColor = [UIColor colorWithRed:48.0f/255.0f green:51.0f/255.0f blue:54.0f/255.0f alpha:1];

    [backgoundBanner addSubview:self.mediumBannerView];
  
    [view addSubview:backgoundBanner];
}

#pragma mark - Banner Delegate

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"error ads");
    _isErroring = YES;
}

- (void)adViewDidReceiveAd:(GADBannerView *)view{
    NSLog(@"adViewDidReceiveAd");
    
//    if (view == _mediumBannerView) {
//        UIView *superview = view.superview;
//        [view removeFromSuperview];
//        [self createMediumBanner];
//        [superview addSubview:self.mediumBannerView];
//    }
    
//    if (view == _smallBannerView) {
//        UIView *superview = view.superview;
//        [view removeFromSuperview];
//        _smallBannerView = nil;
//        [self createSmallBanner];
//        [superview addSubview:_smallBannerView];
//    }
//    else if (view == _mediumBannerView) {
//        UIView *superview = view.superview;
//        [view removeFromSuperview];
//        _mediumBannerView = nil;
//        [self createMediumBanner];
//        [superview addSubview:_mediumBannerView];
//    }
    _isErroring = NO;
}

@end
