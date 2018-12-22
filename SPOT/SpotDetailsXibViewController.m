//
//  SpotDetailsViewController.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/3/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SpotDetailsXibViewController.h"
#import "AppDelegate.h"
#import "KIImagePager.h"
#import "SPOT.h"
#import "Image.h"
#import "SPOT+Traffic.h"
#import "SPOT+Tag.h"
#import "LargeImagePagerViewController.h"
#import "SpotNameItemView.h"
#import "SpotAddressItemView.h"
#import "SpotMemoItemView.h"
#import "SpotTrafficItemView.h"
#import "SpotPhoneItemView.h"
#import "SpotUrlItemView.h"
#import "SpotTagItemView.h"
#import "PullAndReleaseView.h"
#import "SpotImagePager.h"
#import "SPOTMapViewController.h"
#import "PdfViewController.h"
#import "DetailMemoVoiceViewController.h"
#import "Banner.h"
#import "StackPanel.h"
#import "AirdropService.h"
#import "SPOT+Image.h"
#import "HtmlGenerateHelper.h"

@interface SpotDetailsXibViewController () <SpotImagePagerDelegate, SpotMemoItemViewDelegate, StackPanelDelegate>
{
    BOOL shouldReloadViewData;
    BOOL isBannerShowing;
    
}

//@property (weak, nonatomic) KIImagePager *imagePager;
//
//@property (weak, nonatomic) UIView *spotNameView;
//@property (weak, nonatomic) UIView *addressView;
//@property (weak, nonatomic) UIView *memoView;
//@property (weak, nonatomic) UIView *trafficView;
//@property (weak, nonatomic) UIView *phoneView;
//@property (weak, nonatomic) UIView *urlView;
//@property (weak, nonatomic) UIView *tagView;
@property (weak, nonatomic) PullAndReleaseView *pullForPreviousView;
@property (weak, nonatomic) PullAndReleaseView *pullForNextView;

@property (weak, nonatomic) StackPanel *stackPanel;

@property (nonatomic) SPOT *nextSpot;
@property (nonatomic) SPOT *previousSpot;

@property (nonatomic) BOOL isFetchingImages;
@property (nonatomic) float contentHeight;
@property (nonatomic) float offset;
@property (nonatomic) BOOL needScrollToTop;

@property (nonatomic) UIView *bannerView;

@end

@implementation SpotDetailsXibViewController

AppDelegate *appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    shouldReloadViewData = YES;
    isBannerShowing = NO;
    
    isBannerShowing = [[Banner shared] shouldShowAds];
    
    self.scrollView.backgroundColor = [UIColor darkGrayColor];
}

- (void)dealloc {
    NSLog(@"SPOT details died.");
    self.spot = nil;
    self.spots = nil;
    self.pullForNextView = nil;
    self.pullForPreviousView = nil;
    self.bannerView = nil;
    self.stackPanel = nil;
}

- (void)updateScrollViewContentSize {
    self.contentHeight = self.stackPanel.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.contentHeight + self.offset);
}

- (void)refreshUI {
    @autoreleasepool {
        [self setupNextAndPreviousSpot];
        
        // remove all subview
        [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        
        // Uncheck under topbar and under bottom bar
        self.offset = 0;
        
        self.contentHeight = 0;
        
        StackPanel *stackPanel = [[StackPanel alloc] initWithFrame:CGRectMake(0, 0, 320, self.scrollView.frame.size.height)];
        stackPanel.backgroundColor = [UIColor whiteColor];
        stackPanel.delegate = self;
        self.stackPanel = stackPanel;
        
        [self.scrollView addSubview:stackPanel];
        
        [self updateScrollViewContentSize];
        
        if (self.spot.image.count > 0) {
            
            SpotImagePager *imagePager = [[SpotImagePager alloc] initWithFrame:CGRectMake(0, 0, 320, 225)];
            imagePager.delegate = imagePager;
            imagePager.imageDelegate = self;
            imagePager.dataSource = imagePager;
            imagePager.spot = self.spot;
            
            [self.stackPanel addView:imagePager];
            
            imagePager = nil;
        }
        else {
            UIView *view = [[UIView alloc] init];
            view.frame = CGRectMake(0, 0, 320, statusBarHeight);
            [self.stackPanel addView:view];
        }
        
        
        // Add SPOT name
        SpotNameItemView *spotNameView = [[SpotNameItemView alloc] initWithText:self.spot.spot_name];
        [self.stackPanel addView:spotNameView];
        spotNameView = nil;
        
        // Add Address
        SpotAddressItemView *addressView = [[SpotAddressItemView alloc] initWithText:self.spot.address];
        [self.stackPanel addView:addressView];
        addressView = nil;
        
        // Add Memo
        SpotMemoItemView *memoView = [[SpotMemoItemView alloc] initWithText:self.spot.memo andHasMemo:self.spot.voice.count > 0];
        memoView.delegate = self;
        memoView.spot = self.spot;
        [self.stackPanel addView:memoView];
        memoView = nil;
        
        // Add Traffic
        SpotTrafficItemView *trafficView = [[SpotTrafficItemView alloc] initWithText:[self.spot trafficText] andTrafficIconIndex:self.spot.traffic.intValue];
        [self.stackPanel addView:trafficView];
        trafficView = nil;
        
        // Add Phone
        SpotPhoneItemView *phoneView = [[SpotPhoneItemView alloc] initWithText:self.spot.phone];
        [self.stackPanel addView:phoneView];
        phoneView = nil;
        
        // Add Url
        SpotUrlItemView *urlView = [[SpotUrlItemView alloc] initWithText:self.spot.url];
        [self.stackPanel addView:urlView];
        
        // Add Tags
        SpotTagItemView *tagView = [[SpotTagItemView alloc] initWithText:[self.spot tagText] andDarkBottomLine:NO];
        [self.stackPanel addView:tagView];
        tagView = nil;
        
        // show ads
        if (isBannerShowing) {
            UIView *bannerView = [[UIView alloc] init];
            bannerView.frame = CGRectMake(0, 0, 320, 250 + ADS_MARGIN_HEIGHT);
            [[Banner shared] showMediumBannerViewInView:bannerView];
            [self.stackPanel addView:bannerView];
            self.bannerView = bannerView;
        }
        
        [self updateScrollViewContentSize];
        
        // Add Pull for previous
        
        if (self.previousSpot) {
            PullAndReleaseView *pullView = [[PullAndReleaseView alloc] initWithText:@"Pull for previous"];
            pullView.frame = CGRectMake(0, self.contentHeight + self.offset, pullView.frame.size.width, pullView.frame.size.height);
            [self.scrollView addSubview:pullView];
            self.pullForPreviousView = pullView;
            pullView = nil;
        }
        else {
            self.pullForPreviousView = nil;
        }
        
        // Add Pull for next
        if (self.nextSpot) {
            PullAndReleaseView *pullView = [[PullAndReleaseView alloc] initWithText:@"Pull for next"];
            pullView.frame = CGRectMake(0, -pullView.frame.size.height + self.offset, pullView.frame.size.width, pullView.frame.size.height);
            [self.scrollView addSubview:pullView];
            self.pullForNextView = pullView;
            pullView = nil;
        }
        else {
            self.pullForNextView = nil;
        }
    }
}

- (void)moveDownUIView:(UIView *)view withDistance:(float)distance {
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + distance, view.frame.size.width, view.frame.size.height);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        if (!self.spot.uuid) {
            shouldReloadViewData = YES;
            [self performSegueWithIdentifier:@"PushCreateSPOTViewControllerToEditNoAnimation" sender:self];
        }
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.toolbar.hidden = NO;
    
    // change status bar
    appDelegate.statusBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    
    if (self.spot.uuid && shouldReloadViewData) {
        [self refreshUI];
        
        shouldReloadViewData = NO;
    }
    
    // reload ads
    if (self.bannerView) {
        [[Banner shared] showMediumBannerViewInView:self.bannerView];
    }
}


- (void)viewWillDisappear:(BOOL)animated   {
    [super viewWillDisappear:animated];
    
    // change status bar
    appDelegate.statusBar.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
 
}

- (NSArray *) getImageFileNameArrayFromSpot : (SPOT *)spot
{
    NSArray *sortedArray = [spot sortedImages];
    
    NSMutableArray *imageFileNameArray = [[NSMutableArray alloc] init];
    for (Image *image in sortedArray)
    {
        
        NSString *savedImagePath = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent: image.image_file_name];
        [imageFileNameArray addObject:savedImagePath];
    }
    return imageFileNameArray;
}

- (IBAction)onBackButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAddButtonClicked:(id)sender {
    self.spot = [SPOT MR_createEntity];
    shouldReloadViewData = YES;
    [self performSegueWithIdentifier:@"PushCreateSPOTViewControllerToEdit" sender:self];
}

- (IBAction)onEditButtonClicked:(id)sender {
    shouldReloadViewData = YES;
    [self performSegueWithIdentifier:@"PushCreateSPOTViewControllerToEdit" sender:self];
}

- (IBAction)onPdfButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"PushPdfViewController" sender:self];
}

- (IBAction)onAirdropButtonClicked:(id)sender {
    [self sendAirdropWithSpot:self.spot];
}

- (void)sendAirdropWithSpotTest:(SPOT *)spot {
    AirdropService *service = [AirdropService new];
    
    NSString *filePath = [service sendSpot:spot];
    
    [service importObjectFromFile:filePath];
}

- (void)sendAirdropWithSpot:(SPOT *)spot {
    AirdropService *service = [AirdropService new];
    NSString *filePath = [service sendSpot:spot];
    
    // Build a collection of activity items to share, in this case a url
    NSArray *activityItems = @[[NSURL fileURLWithPath:filePath]];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    // Exclude all activities except AirDrop.
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,UIActivityTypeMessage, UIActivityTypeMail,UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    activityController.excludedActivityTypes = excludedActivities;
    
    [self presentViewController:activityController animated:YES completion:^{
        
    }];
 
}

- (IBAction)onMapButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"PushSPOTMapViewController" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowLargeImagePagerViewController"])
    {
        SpotImagePager *imagePager = (SpotImagePager *)sender;
        // Get reference to the destination view controller
        LargeImagePagerViewController *largeImagePagerViewController = [segue destinationViewController];
        
        [largeImagePagerViewController setImageFileNameArray:[self getImageFileNameArrayFromSpot:imagePager.spot]];
        [largeImagePagerViewController setCurrentPageIndex:[imagePager currentPage]];
        
    }
    else if ([[segue identifier] isEqualToString:@"PushSPOTMapViewController"])
    {
        // Get reference to the destination view controller
        SPOTMapViewController *spotMapViewController = [segue destinationViewController];
        [spotMapViewController setSpot:self.spot];
    }
    else if ([[segue identifier] isEqualToString:@"PushPdfViewController"])
    {
        // Get reference to the destination view controller
        PdfViewController *pdfViewController = [segue destinationViewController];
        [pdfViewController setSpot:self.spot];
    }
    else if ([[segue identifier] isEqualToString:@"PushCreateSPOTViewControllerToEditNoAnimation"])
    {
        // Get reference to the destination view controller
        CreateSPOTViewController *createSPOTViewController = [segue destinationViewController];
        
        [createSPOTViewController setSpot:self.spot];
    }
    else if ([[segue identifier] isEqualToString:@"PushCreateSPOTViewControllerToEdit"])
    {
        // Get reference to the destination view controller
        CreateSPOTViewController *createSPOTViewController = [segue destinationViewController];
        
        [createSPOTViewController setSpot:self.spot];
    }
    else if ([[segue identifier] isEqualToString:@"ShowMemoVoiceDetailController"]){
        
        DetailMemoVoiceViewController *detailMemoVoiceViewController = [segue destinationViewController];
        
        [detailMemoVoiceViewController setSpot:self.spot];
    }
}

- (void)setupNextAndPreviousSpot {
    self.nextSpot = nil;
    self.previousSpot = nil;
    if (self.spots) {
        int count = (int)self.spots.count;
        
        for (int i = 0; i < count; i++) {
            if (self.spots[i] == self.spot) {
                if (i > 0) {
                    self.nextSpot = self.spots[i - 1];
                }
                if (i < count - 1) {
                    self.previousSpot = self.spots[i + 1];
                }
                break;
            }
        }
        
    }
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    @autoreleasepool {
        if (self.scrollView.contentOffset.y < -80) {
            NSLog(@"Drag down");
            
            if (self.spots) {
                
                if (self.nextSpot != nil) {
                    UIView *currentView = self.scrollView;
                    UIView *theWindow = [currentView superview];
                    CATransition *animation = [CATransition animation];
                    [animation setDuration:0.4];
                    [animation setType:kCATransitionPush];
                    [animation setSubtype:kCATransitionFromBottom];
                    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                    
                    [[theWindow layer] addAnimation:animation forKey:@"SwitchToView1"];
                    
                    self.needScrollToTop = YES;
                    self.spot = self.nextSpot;
                    [self refreshUI];
                    
                    
                }
            }
        }
        else if ((scrollView.contentOffset.y + self.offset) - (self.contentHeight - scrollView.frame.size.height)  > 60) {
            NSLog(@"Drag up");
            
            if (self.spots) {
                
                if (self.previousSpot != nil) {
                    UIView *currentView = self.scrollView;
                    UIView *theWindow = [currentView superview];
                    CATransition *animation = [CATransition animation];
                    [animation setDuration:0.4];
                    [animation setType:kCATransitionPush];
                    [animation setSubtype:kCATransitionFromTop];
                    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                    
                    [[theWindow layer] addAnimation:animation forKey:@"SwitchToView1"];
                    
                    self.needScrollToTop = YES;
                    self.spot = self.previousSpot;
                    [self refreshUI];
                    
                }
            }
        }
    }
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
   
    if (self.needScrollToTop) {
        [scrollView setContentOffset:CGPointMake(0.0, self.offset) animated:NO];
        self.needScrollToTop = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {    
    if (scrollView.contentOffset.y + self.offset < 0) {
        if (self.nextSpot != nil && self.pullForNextView) {
            self.pullForNextView.label.text = self.scrollView.contentOffset.y < -80 ? @"Release for next" : @"Pull for next";
            
        }
    }
    else if ((scrollView.contentOffset.y + self.offset) - (self.contentHeight - scrollView.frame.size.height) > 0) {
        if (self.previousSpot != nil && self.pullForPreviousView) {
            
            self.pullForPreviousView.label.text = (scrollView.contentOffset.y + self.offset) - (self.contentHeight - scrollView.frame.size.height) > 60 ? @"Release for previous" : @"Pull for previous";
            
        }
        
    }
}

#pragma mark - SpotImagePagerDelegate 

- (void)didSelectImageAtIndex:(NSUInteger)index sender:(id)sender {
    
    [self performSegueWithIdentifier:@"ShowLargeImagePagerViewController" sender:sender];
}

#pragma mark - SpotMemoItemViewDelegate

- (void)didClickVoiceButton:(id)sender {
    [self performSegueWithIdentifier:@"ShowMemoVoiceDetailController" sender:self];
}

#pragma mark - StackPanelDelegate

- (void)didAddView:(UIView *)view {
//    [self updateScrollViewContentSize];
}

@end
