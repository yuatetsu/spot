//
//  GuideBookDetailsXibViewController.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/6/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "GuideBookDetailsXibViewController.h"
#import "AppDelegate.h"
#import "GuideBook.h"
#import "GuideBookInfo.h"
#import "GuideBookInfoType.h"
#import "SPOT.h"
#import "Image.h"
#import "SpotImagePager.h"
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
#import "GuideBookNameItemView.h"
#import "GuideBookStartDateItemView.h"
#import "GuideBookInfoDayView.h"
#import "GuideBook+Addition.h"
#import "GuideBookInfoMemoItemView.h"
#import "GuideBookInfoFoursquareItemView.h"
#import "PdfViewController.h"
#import "CreateGuideBookViewController.h"
#import "DetailMemoVoiceViewController.h"
#import "Banner.h"
#import "StackPanel.h"
#import "AirdropService.h"
#import "SPOT+Image.h"

@interface GuideBookDetailsXibViewController () <SpotImagePagerDelegate, GuideBookInfoDayViewDelegate, SpotMemoItemViewDelegate, StackPanelDelegate> {
    BOOL shouldReloadViewData;
    BOOL isBannerShowing;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


//@property (strong, nonatomic) UIView *spotNameView;

@property (nonatomic) BOOL isFetchingImages;
@property (nonatomic) float contentHeight;
@property (nonatomic) float offset;
@property (nonatomic) BOOL needScrollToTop;
@property (nonatomic) BOOL isViewPresented;
@property (nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) GuideBook *nextGuideBook;
@property (nonatomic) GuideBook *previousGuideBook;

@property (weak, nonatomic) PullAndReleaseView *pullForPreviousView;
@property (weak, nonatomic) PullAndReleaseView *pullForNextView;

@property (weak, nonatomic) UIView *bannerView;

@property (weak, nonatomic) StackPanel *stackPanel;

@end

@implementation GuideBookDetailsXibViewController

AppDelegate *appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    shouldReloadViewData = YES;
    
    isBannerShowing = [[Banner shared] shouldShowAds];
    
    self.scrollView.backgroundColor = [UIColor darkGrayColor];
    
}

- (void)dealloc {
    [self.stackPanel removeFromSuperview];
    self.stackPanel = nil;
    NSLog(@"GuideBook details died.");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    if (shouldReloadViewData) {
        [self refreshUI];
        shouldReloadViewData = NO;
    }
    
    // reload ads
    if (self.bannerView) {
        [[Banner shared] showMediumBannerViewInView:self.bannerView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        if (!self.guideBook.uuid) {
            shouldReloadViewData = YES;
            [self performSegueWithIdentifier:@"PushCreateGuideBookViewControllerForEditingNoAnimation" sender:self];
        }
    }
}

- (void)updateScrollViewContentSize {
    self.contentHeight = self.stackPanel.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.contentHeight + self.offset);
}

- (void)refreshUI {
    @autoreleasepool {
        [self setupNextAndPreviousGuideBook];
        
        // remove all subview
        [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        //    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        self.offset = 0;
        self.contentHeight = 0;
        
        StackPanel *stackPanel = [[StackPanel alloc] initWithFrame:CGRectMake(0, 0, 320, self.scrollView.frame.size.height)];
        stackPanel.backgroundColor = [UIColor whiteColor];
        stackPanel.delegate = self;
        self.stackPanel = stackPanel;
        
        [self.scrollView addSubview:stackPanel];
        
        [self updateScrollViewContentSize];
        
        
        GuideBookNameItemView *nameView = [[GuideBookNameItemView alloc] initWithText:([StringHelpers isNilOrWhitespace:self.guideBook.guide_book_name] ? @"edit guidebook name" : self.guideBook.guide_book_name)];
        [self.stackPanel addView:nameView];
        
        GuideBookStartDateItemView *startDateView = [[GuideBookStartDateItemView alloc] initWithText:[self.dateFormatter stringFromDate: self.guideBook.start_date]];
        [self.stackPanel addView:startDateView];
        
        
        NSArray *guideBookInfoArray = [self.guideBook.guide_book_info allObjects];
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        NSArray *sortedGuideBookInfoArray= [guideBookInfoArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        BOOL ignoreFirstGuideBookInfo = NO;
        
        if (self.guideBook.start_spot || self.guideBook.start_spot_selected_from_foursquare) {
            if (sortedGuideBookInfoArray.count > 0) {
                GuideBookInfo *guideBookInfo = [sortedGuideBookInfoArray firstObject];
                if (guideBookInfo.info_type.intValue == GuideBookInfoTypeDay) {
                    [self addSubViewForGuideBookInfoDay:guideBookInfo];
                    ignoreFirstGuideBookInfo = YES;
                }
            }
            if (self.guideBook.start_spot) {
                [self addSubViewForGuideBookInfoSpot:self.guideBook.start_spot];
            }
            else if (self.guideBook.start_spot_selected_from_foursquare) {
                GuideBookInfoFoursquareItemView *foursquareView = [[GuideBookInfoFoursquareItemView alloc] initWithText:self.guideBook.foursquare_spot_name];
                [self.stackPanel addView:foursquareView];
            }
            
        }
        
        for (int i = 0; i < sortedGuideBookInfoArray.count; i++) {
            @autoreleasepool {
                if (i == 0 && ignoreFirstGuideBookInfo) {
                    continue;
                }
                GuideBookInfo *guideBookInfo = [sortedGuideBookInfoArray objectAtIndex:i];
                switch (guideBookInfo.info_type.intValue) {
                    case GuideBookInfoTypeDay:
                        [self addSubViewForGuideBookInfoDay:guideBookInfo];
                        break;
                    case GuideBookInfoTypeMemo:
                        [self addSubViewForGuideBookInfoMemo:guideBookInfo];
                        break;
                    case GuideBookInfoTypeSpot:
                        [self addSubViewForGuideBookInfoSpot:guideBookInfo.spot];
                        break;
                    default:
                        break;
                }
            }
        }
        
        // show ads
        if (isBannerShowing) {
            UIView *bannerView = [[UIView alloc] init];
            bannerView.backgroundColor = [UIColor whiteColor];
            bannerView.frame = CGRectMake(0, 0, 320, 250 + ADS_MARGIN_HEIGHT);
            [[Banner shared] showMediumBannerViewInView:bannerView];
            
            [self.stackPanel addView:bannerView];
            self.bannerView = bannerView;
        }
        
        if (self.contentHeight + self.offset < self.scrollView.frame.size.height) {
            
            int diff = self.scrollView.frame.size.height - self.contentHeight - self.offset + 1;
            
            UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentHeight + self.offset, 320, diff)];
            blankView.backgroundColor = [UIColor whiteColor];
            [self.scrollView addSubview:blankView];
            
            
            self.contentHeight += diff;
        }
        
        [self updateScrollViewContentSize];
        
        
        if (self.previousGuideBook) {
            PullAndReleaseView *pullView = [[PullAndReleaseView alloc] initWithText:@"Pull for previous"];
            pullView.frame = CGRectMake(0, self.contentHeight + self.offset, pullView.frame.size.width, pullView.frame.size.height);
            [self.scrollView addSubview:pullView];
            self.pullForPreviousView = pullView;
        }
        else {
            self.pullForPreviousView = nil;
        }
        
        // Add Pull for next
        if (self.nextGuideBook) {
            PullAndReleaseView *pullView = [[PullAndReleaseView alloc] initWithText:@"Pull for next"];
            pullView.frame = CGRectMake(0, -pullView.frame.size.height + self.offset, pullView.frame.size.width, pullView.frame.size.height);
            [self.scrollView addSubview:pullView];
            self.pullForNextView = pullView;
        }
        else {
            self.pullForNextView = nil;
        }

    }
    
//    self.scrollView.backgroundColor = [UIColor darkGrayColor];
//    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.contentHeight + self.offset);
}

- (void)addSubViewForGuideBookInfoSpot:(SPOT *)spot {
    @autoreleasepool {
        // Add image pager
        if (spot.image.count > 0) {
            
            SpotImagePager *imagePager = [[SpotImagePager alloc] initWithFrame:CGRectMake(0, 0, 320, 130)];
            imagePager.delegate = imagePager;
            imagePager.imageDelegate = self;
            imagePager.dataSource = imagePager;
            imagePager.spot = spot;
            
            [self.stackPanel addView:imagePager];
        }
        
        // Add SPOT name
        SpotNameItemView *spotNameView = [[SpotNameItemView alloc] initWithText:spot.spot_name];
        [self.stackPanel addView:spotNameView];
        
        // Add Address
        SpotAddressItemView *addressView = [[SpotAddressItemView alloc] initWithText:spot.address];
        [self.stackPanel addView:addressView];
        
        
        // Add Memo
        SpotMemoItemView *memoView = [[SpotMemoItemView alloc] initWithText:spot.memo andHasMemo:spot.voice.count > 0];
        memoView.delegate = self;
        memoView.spot = spot;
        [self.stackPanel addView:memoView];
        
        // Add Traffic
        SpotTrafficItemView *trafficView = [[SpotTrafficItemView alloc] initWithText:[spot trafficText] andTrafficIconIndex:spot.traffic.intValue];
        [self.stackPanel addView:trafficView];
        
        
        // Add Phone
        SpotPhoneItemView *phoneView = [[SpotPhoneItemView alloc] initWithText:spot.phone];
        [self.stackPanel addView:phoneView];
        
        // Add Url
        SpotUrlItemView *urlView = [[SpotUrlItemView alloc] initWithText:spot.url];
        [self.stackPanel addView:urlView];
        
        // Add Tags
        SpotTagItemView *tagView = [[SpotTagItemView alloc] initWithText:[spot tagText] andDarkBottomLine:YES];
        [self.stackPanel addView:tagView];
    }
}

- (void)addSubViewForGuideBookInfoDay:(GuideBookInfo *)guideBookInfo {
    GuideBookInfoDayView *view = [[GuideBookInfoDayView alloc] initWithDayFromStartDay:guideBookInfo.day_from_start_day.intValue andDayCount:[self.guideBook dayCount]];
    view.delegate = self;
    [self.stackPanel addView:view];
}

- (void)addSubViewForGuideBookInfoMemo:(GuideBookInfo *)guideBookInfo {
    GuideBookInfoMemoItemView *view = [[GuideBookInfoMemoItemView alloc] initWithText:guideBookInfo.memo];
    [self.stackPanel addView:view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)setupNextAndPreviousGuideBook {
    self.nextGuideBook = nil;
    self.previousGuideBook = nil;
    if (self.guideBooks) {
        int count = (int)self.guideBooks.count;
        
        for (int i = 0; i < count; i++) {
            if (self.guideBooks[i] == self.guideBook) {
                if (i > 0) {
                    self.nextGuideBook = self.guideBooks[i - 1];
                }
                if (i < count - 1) {
                    self.previousGuideBook = self.guideBooks[i + 1];
                }
                break;
            }
        }
        
    }
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
    else if ([[segue identifier] isEqualToString:@"PushPdfViewController"])
    {
        // Get reference to the destination view controller
        PdfViewController *pdfViewController = [segue destinationViewController];
        [pdfViewController setGuideBook:self.guideBook];
    }
    else if ([segue.identifier isEqualToString:@"PushCreateGuideBookViewControllerForEditing"]){
        CreateGuideBookViewController *createGuideBookViewController = segue.destinationViewController;
        createGuideBookViewController.guideBook = self.guideBook;
    }
    else if ([segue.identifier isEqualToString:@"PushCreateGuideBookViewControllerForEditingNoAnimation"]){
        CreateGuideBookViewController *createGuideBookViewController = segue.destinationViewController;
        createGuideBookViewController.guideBook = self.guideBook;
    }
    else if ([segue.identifier isEqualToString:@"PushCreateGuideBookViewController"]){
        
    }
    else if ([segue.identifier isEqualToString:@"GuidebookSpotVoicememoDetail"]){
        DetailMemoVoiceViewController * detailMemoVoiceViewController = segue.destinationViewController;
        SPOT *spot = sender;
        detailMemoVoiceViewController.spot = spot;
    }
}


- (IBAction)onBackButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAddButtonClicked:(id)sender {
    
    self.guideBook = [GuideBook MR_createEntity];
    shouldReloadViewData = YES;
    [self performSegueWithIdentifier:@"PushCreateGuideBookViewControllerForEditing" sender:self];
}

- (IBAction)onEditButtonClicked:(id)sender {
    shouldReloadViewData = YES;
    [self performSegueWithIdentifier:@"PushCreateGuideBookViewControllerForEditing" sender:self];
}

- (IBAction)onPdfButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"PushPdfViewController" sender:self];
}

- (IBAction)onAirdropButtonClicked:(id)sender {
    [self sendAirdropWithGuideBook:self.guideBook];
}


- (void)sendAirdropWithGuideBookTest:(GuideBook *)guideBook {
    AirdropService *service = [AirdropService new];
    
    NSString *filePath = [service sendGuideBook:guideBook];
    
    [service importObjectFromFile:filePath];
}

- (void)sendAirdropWithGuideBook:(GuideBook *)guideBook {
    AirdropService *service = [AirdropService new];
    
    NSString *filePath = [service sendGuideBook:guideBook];
    
    
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

#pragma mark - SpotImagePagerDelegate

- (void)didSelectImageAtIndex:(NSUInteger)index sender:(id)sender {
    
    [self performSegueWithIdentifier:@"ShowLargeImagePagerViewController" sender:sender];
}

#pragma mark - GuideBookInfoDayViewDelegate

- (void)dayButtonClicked:(int)day sender:(id)sender {
    for (UIView *view in self.stackPanel.subviews) {
        if ([view isKindOfClass:[GuideBookInfoDayView class]]) {
            GuideBookInfoDayView *dayView = (GuideBookInfoDayView *)view;
            if (dayView.dayFromStartDay == day) {
                CGRect frame = dayView.frame;
//                frame.origin.y -= frame.size.height/2;
                if (frame.origin.y > self.contentHeight - self.scrollView.frame.size.height + self.offset) {
                    frame.origin.y = self.contentHeight - self.scrollView.frame.size.height + self.offset;
                }
                [self.scrollView setContentOffset:frame.origin animated:YES];
                break;
            }
            
        }
        
    }
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    @autoreleasepool {
        if (self.scrollView.contentOffset.y < -60) {
            NSLog(@"Drag down");
            
            if (self.guideBooks) {
                
                if (self.nextGuideBook != nil) {
                    UIView *currentView = self.scrollView;
                    UIView *theWindow = [currentView superview];
                    CATransition *animation = [CATransition animation];
                    [animation setDuration:0.4];
                    [animation setType:kCATransitionPush];
                    [animation setSubtype:kCATransitionFromBottom];
                    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                    
                    [[theWindow layer] addAnimation:animation forKey:@"SwitchToView1"];
                    
                    self.needScrollToTop = YES;
                    self.guideBook = self.nextGuideBook;
                    [self refreshUI];
                    
                }
            }
        }
        else if ((scrollView.contentOffset.y) - (self.contentHeight - scrollView.frame.size.height)  > 80) {
            NSLog(@"Drag up");
            
            if (self.guideBooks) {
                
                if (self.previousGuideBook != nil) {
                    UIView *currentView = self.scrollView;
                    UIView *theWindow = [currentView superview];
                    CATransition *animation = [CATransition animation];
                    [animation setDuration:0.4];
                    [animation setType:kCATransitionPush];
                    [animation setSubtype:kCATransitionFromTop];
                    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                    
                    [[theWindow layer] addAnimation:animation forKey:@"SwitchToView1"];
                    
                    self.needScrollToTop = YES;
                    self.guideBook = self.previousGuideBook;
                    [self refreshUI];
                }
            }
        }
    }    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  
    if (self.needScrollToTop) {
        [scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
        self.needScrollToTop = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   
    if (scrollView.contentOffset.y + self.offset < 0) {
        if (self.nextGuideBook != nil && self.pullForNextView) {
            self.pullForNextView.label.text = self.scrollView.contentOffset.y < -60 ? @"Release for next" : @"Pull for next";
            
        }
    }
    else if ((scrollView.contentOffset.y) - (self.contentHeight - scrollView.frame.size.height) > 0) {
        if (self.previousGuideBook != nil && self.pullForPreviousView) {
            
            self.pullForPreviousView.label.text = (scrollView.contentOffset.y) - (self.contentHeight - scrollView.frame.size.height) > 80 ? @"Release for previous" : @"Pull for previous";
            
            
        }
        
    }
}

#pragma mark - SpotMemoItemViewDelegate

- (void)didClickVoiceButton:(id)sender {
    SpotMemoItemView *view = (SpotMemoItemView *)sender;
    [self performSegueWithIdentifier:@"GuidebookSpotVoicememoDetail" sender:view.spot];
}


#pragma mark - StackPanelDelegate

- (void)didAddView:(UIView *)view {
    //    [self updateScrollViewContentSize];
}

@end
