//
//  TopScreenViewController.m
//  SPOT
//
//  Created by framgia on 7/4/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "TopScreenViewController.h"
#import "AppDelegate.h"
#import "SPOT.h"
#import "Image.h"
#import "GuideBook.h"
#import "GuideBookInfo.h"
#import "Country.h"
#import "Region.h"
#import "Tag.h"
#import "CreateSPOTViewController.h"
#import "TagRegisterationViewController.h"
#import "SWTableViewCell.h"
#import "FontHelper.h"
#import "SPDropBox.h"
#import "iCloud+spotiCloudAddition.h"
#import "GuideBook.h"
#import "CreateGuideBookViewController.h"
#import "SPOT+Image.h"
#import "SpotDetailsXibViewController.h"
#import "GuideBookDetailsXibViewController.h"




@interface TopScreenViewController () <NSFetchedResultsControllerDelegate, SWTableViewCellDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    SPOT *selectedSpot;
    GuideBook *selectedGuideBook;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
// Design
@property (weak, nonatomic) IBOutlet UILabel *settingLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UILabel *calendarLabel;
@property (weak, nonatomic) IBOutlet UILabel *guidebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *calendarButton;
@property (weak, nonatomic) IBOutlet UIButton *guidebookButton;
@property (weak, nonatomic) IBOutlet UIButton *tagButton;
@property (weak, nonatomic) IBOutlet UIButton *addGuideButton;
@property (weak, nonatomic) IBOutlet UIButton *addSpotButton;
@property (weak, nonatomic) IBOutlet UIButton *spotListButton;


@property (nonatomic, strong) NSMutableDictionary *imageLoadsInProgress;
@property (nonatomic, strong) NSMutableDictionary *imageDictionary;
@property (assign, nonatomic) BOOL isAllowClick;

@end

@implementation TopScreenViewController

AppDelegate* appDelegate;
NSDateFormatter *formatterForDateLabel;
NSDateFormatter *formatterForMonthLabel;



- (void)viewDidLoad
{
    [super viewDidLoad];
    //set white status bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    // set blue nav bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Slice_icon_112"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    
    // set nav title font
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName : [UIFont fontWithName:FONT_NAME size:FONT_LARGE_SIZE]
                              
                              }];
    self.navigationController.navigationBar.translucent = NO;
    
    
    self.settingLabel.font = self.mapLabel.font = self.searchLabel.font = self.calendarLabel.font = self.guidebookLabel.font = self.tagLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_NORMAL_SIZE - 1];
    self.countryNumberLabel.font = self.spotNumberLabel.font = self.guideNumberLabel.font = self.regionNumberLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SMALL_SIZE];
    // Do any additional setup after loading the view, typically from a nib.
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"PrototypeCellForSPOTList" bundle:nil] forCellReuseIdentifier:@"SPOT List Cell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"PrototypeCellForSPOTListNoImage" bundle:nil] forCellReuseIdentifier:@"SPOT List Cell No Image"];
    appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.topScreenViewController = self;
    
    //    [MagicalRecord setupCoreDataStack];
    
    self.fetchedResultsController = [SPOT MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:nil groupBy:@"month" delegate:self];
    
    formatterForDateLabel = [[NSDateFormatter alloc] init];
    [formatterForDateLabel setDateFormat:@"dd/MM/yyyy"];
    [formatterForDateLabel setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    formatterForMonthLabel = [[NSDateFormatter alloc] init];
    [formatterForMonthLabel setDateFormat:@"MMMM yyyy"];
    [formatterForMonthLabel setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    [self.searchDisplayController.searchResultsTableView setRowHeight:60];
    [self.searchDisplayController.searchBar setHidden:YES];
    
    [FontHelper setFontFamily:FONT_NAME forView:self.view andSubViews:YES];
    
    UIView *backgroundToolbar = [[UIView alloc]initWithFrame:self.navigationController.toolbar.bounds];
    backgroundToolbar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Slice_icon_112"]];
    
    
    [self.navigationController.toolbar addSubview:backgroundToolbar];
    
    [self addSelfAsObserverNotification];
    
    self.imageLoadsInProgress = [NSMutableDictionary dictionary];
    self.imageDictionary = [NSMutableDictionary dictionary];
    
    self.searchDisplayController.delegate = self;
    
    
}


-(void)addSelfAsObserverNotification{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCompleteSync) name:@"CompleteSyncDropbox" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCompleteSync) name:@"CompleteSynciCloud" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCompleteSync) name:@"completeSyncFoursquare" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSendAirDropFinish) name:@"SaveAirDropFileFinish" object:nil];
}


-(void)handleCompleteSync {
    
    [self displayInformationApp];
}


-(void)handleSendAirDropFinish {
    
    [self displayInformationApp];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [self displayInformationApp];
    
//    [Banner shared];
    
    [[Banner shared] hideSmallBanner];
    
    NSLog(@"Clear cache");
    [appDelegate.spotSlideImageCacher clearCache];
}


-(void)displayInformationApp{
    
    int spotNumber=0;
    int guideNumber=0;
    int countryNumber=0;
    int regionNumber=0;
    
    NSArray *emptyCountryArray = [Country MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"spot.@count == 0"]];
    for (int i = 0; i < [emptyCountryArray count]; i++) {
        Country *emptyCountry = [emptyCountryArray objectAtIndex:i];
        [emptyCountry MR_deleteEntity];
    }
    NSArray *emptyRegionArray = [Region MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"spot.@count == 0"]];
    for (int i = 0; i < [emptyRegionArray count]; i++) {
        Region *emptyRegion = [emptyRegionArray objectAtIndex:i];
        [emptyRegion MR_deleteEntity];
    }
    spotNumber = (int)[SPOT MR_countOfEntities];
    guideNumber = (int)[GuideBook MR_countOfEntities];
    countryNumber = (int)[Country MR_countOfEntities];
    regionNumber = (int)[Region MR_countOfEntities];
    
    // update label
    NSMutableAttributedString* spotNumberString = [self setLineSpacing:10 forString:[NSString stringWithFormat:@"%d\nSPOT",spotNumber]];
    self.spotNumberLabel.attributedText = spotNumberString;
    self.spotNumberLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString* guideNumberString = [self setLineSpacing:10 forString:[NSString stringWithFormat:@"%d\nGUIDE",guideNumber]];
    self.guideNumberLabel.attributedText = guideNumberString;
    self.guideNumberLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString* countryNumberString = [self setLineSpacing:10 forString:[NSString stringWithFormat:@"%d\nCOUNTRY",countryNumber]];
    self.countryNumberLabel.attributedText = countryNumberString;
    self.countryNumberLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString* regionNumberString = [self setLineSpacing:10 forString:[NSString stringWithFormat:@"%d\nREGION",regionNumber]];
    self.regionNumberLabel.attributedText = regionNumberString;
    self.regionNumberLabel.textAlignment = NSTextAlignmentCenter;
    
}



-(void)viewWillAppear:(BOOL)animated
{
    self.isAllowClick = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (!self.searchDisplayController.searchBar.hidden)
    {
        [self.scrollView setContentOffset:CGPointMake(0, -self.searchDisplayController.searchBar.frame.size.height) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    [self.searchBackgoundView setHidden:YES];
    
    [self.imageLoadsInProgress removeAllObjects];
    [self.imageDictionary removeAllObjects];
    
    [self tableViewReloadData];
    [self displayInformationApp];
    
    
    
    //    [appDelegate hideActivityIndicator];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UIImage *settingImage = [UIImage imageNamed:@"Setting"];
    [self.settingButton setImage:settingImage forState:UIControlStateNormal];
    UIImage *mapImage = [UIImage imageNamed:@"map"];
    [self.mapButton setImage:mapImage forState:UIControlStateNormal];
    UIImage *guidebookImage = [UIImage imageNamed:@"guide_b"];
    [self.guidebookButton setImage:guidebookImage forState:UIControlStateNormal];
    UIImage *calendarImage = [UIImage imageNamed:@"calendar"];
    [self.calendarButton setImage:calendarImage forState:UIControlStateNormal];
    UIImage *tagImage = [UIImage imageNamed:@"tag"];
    [self.tagButton setImage:tagImage forState:UIControlStateNormal];
    UIImage *addGuideImage = [UIImage imageNamed:@"Add_guide"];
    [self.addGuideButton setImage:addGuideImage forState:UIControlStateNormal];
    UIImage *addSpotImage = [UIImage imageNamed:@"add_spot"];
    [self.addSpotButton setImage:addSpotImage forState:UIControlStateNormal];
    UIImage *spotListImage = [UIImage imageNamed:@"spot_list"];
    [self.spotListButton setImage:spotListImage forState:UIControlStateNormal];
    
    [self.navigationController setToolbarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.imageLoadsInProgress removeAllObjects];
    [self.imageDictionary removeAllObjects];
}

- (NSMutableAttributedString *)setLineSpacing:(NSInteger)lineSpacingNumber forString:(NSString *)myString
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:myString];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpacingNumber];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrString.length)];
    return attrString;
}

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [self.scrollView setScrollEnabled:YES];
//
//    [UIView animateWithDuration:0.3 animations:^() {
//        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
//        self.searchDisplayController.searchBar.frame = CGRectMake(0, -20, self.searchDisplayController.searchBar.frame.size.width, self.searchDisplayController.searchBar.frame.size.height);
//    } completion:^(BOOL finished) {
//        [self.searchDisplayController.searchBar setHidden:YES];
//        [self.searchBackgoundView setHidden:YES];
//    }];
//}

- (void) hideTabBar:(UIToolbar *) toolbar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    float fHeight = screenRect.size.height;
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width;
    }
    
    for(UIView *view in toolbar.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            view.backgroundColor = [UIColor blackColor];
        }
    }
    [UIView commitAnimations];
}



- (void) showTabBar:(UIToolbar *) toolbar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height - toolbar.frame.size.height;
    
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width - toolbar.frame.size.height;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in toolbar.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
        }
    }
    [UIView commitAnimations];
}

- (IBAction) onSettingsButtonClicked: (id) sender
{
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        NSLog(@"onSettingsButtonClicked");
        UIButton *settingButton = (UIButton *)sender;
        UIImage *buttonImage = [UIImage imageNamed:@"setting_h"];
        [settingButton setImage:buttonImage forState:UIControlStateNormal];
        [self performSelector:@selector(PushToSettingsViewController) withObject:nil afterDelay:0.01];
    }
    else {
        self.isAllowClick = YES;
    }
}
- (void) PushToSettingsViewController
{
    [self performSegueWithIdentifier:@"PushSettingsViewController" sender:self];
}

- (IBAction) onMapsButtonClicked: (id) sender
{
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        NSLog(@"onMapsButtonClicked");
        UIButton *mapButton = (UIButton *)sender;
        UIImage *buttonImage = [UIImage imageNamed:@"map_h"];
        [mapButton setImage:buttonImage forState:UIControlStateNormal];
        [self performSelector:@selector(PushToMapViewController) withObject:nil afterDelay:0.01];
        
    }
    else {
        self.isAllowClick = YES;
    }
}
- (void) PushToMapViewController
{
    [self performSegueWithIdentifier:@"PushMapViewController" sender:self];
}

- (IBAction) onSearchButtonClicked: (id) sender
{
    
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        NSLog(@"onSearchButtonClicked");
        
        UIButton *searchButton = (UIButton *)sender;
        
        
        //        NSLayoutConstraint *topSearchConstraint = self.view.constraints[0];
        
        if(self.searchDisplayController.searchBar.hidden)
        {
            
            UIImage *buttonImage = [UIImage imageNamed:@"search_h"];
            [searchButton setImage:buttonImage forState:UIControlStateNormal];
            
            [self.scrollView setScrollEnabled:NO];
            //        [self.searchBackgoundView setHidden:NO];
            self.searchDisplayController.searchBar.frame = CGRectMake(0, -20, self.searchDisplayController.searchBar.frame.size.width, self.searchDisplayController.searchBar.frame.size.height);
            
            [self.searchDisplayController.searchBar setHidden:NO];
            [self.searchDisplayController.searchBar becomeFirstResponder];
            
            __weak TopScreenViewController *weakSelf = self;
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                
                //                topSearchConstraint.constant = 0;
            }
            
            [UIView animateWithDuration:0.3 animations:^() {

                [weakSelf.scrollView setContentOffset:CGPointMake(0, -weakSelf.searchDisplayController.searchBar.frame.size.height) animated:NO];
                
                weakSelf.searchDisplayController.searchBar.frame = CGRectMake(0, 20, weakSelf.searchDisplayController.searchBar.frame.size.width, weakSelf.searchDisplayController.searchBar.frame.size.height);
                
            } completion:^(BOOL finished) {
                weakSelf.isAllowClick = YES;
                UIImage *buttonImage = [UIImage imageNamed:@"setting"];
                [searchButton setImage:buttonImage forState:UIControlStateNormal];
            } ];
            
        }
        else
        {
            
            [self.scrollView setScrollEnabled:YES];
            
            __weak TopScreenViewController *weakSelf = self;
            
            [UIView animateWithDuration:0.3 animations:^() {

                [weakSelf.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    
                    //                    topSearchConstraint.constant = -20;
                    
                    weakSelf.searchDisplayController.searchBar.frame = CGRectMake(0, -20, weakSelf.searchDisplayController.searchBar.frame.size.width, weakSelf.searchDisplayController.searchBar.frame.size.height);
                }
                else {
                    weakSelf.searchDisplayController.searchBar.frame = CGRectMake(0, -20, weakSelf.searchDisplayController.searchBar.frame.size.width, weakSelf.searchDisplayController.searchBar.frame.size.height);
                }
                
            } completion:^(BOOL finished) {
                weakSelf.isAllowClick = YES;
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    //                    topSearchConstraint.constant = 0;
                }
                [weakSelf.searchDisplayController.searchBar setHidden:YES];
                UIImage *buttonImage = [UIImage imageNamed:@"setting"];
                [searchButton setImage:buttonImage forState:UIControlStateNormal];
                //            [self.searchBackgoundView setHidden:YES];
            }];
            
        }
    }
    else {
        self.isAllowClick = YES;
    }
}

- (IBAction) onCalendarButtonClicked: (id) sender
{
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        NSLog(@"onCalendarButtonClicked");
        UIButton *calendarButton = (UIButton *)sender;
        UIImage *backgroundImage = [UIImage imageNamed:@"calendar_h"];
        [calendarButton setImage:backgroundImage forState:UIControlStateNormal];
        [self performSelector:@selector(PushToCalendarViewController) withObject:nil afterDelay:0.01];
    }
    else {
        self.isAllowClick = YES;
    }
}
- (void) PushToCalendarViewController
{
    [self performSegueWithIdentifier:@"PushCalendarViewController" sender:self];
}

- (IBAction) onGuideBookButtonClicked: (id) sender
{
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        NSLog(@"onGuideButtonClicked");
        UIButton *guideBookButton = (UIButton *)sender;
        UIImage *backgroundImage = [UIImage imageNamed:@"Guide_b_h"];
        [guideBookButton setImage:backgroundImage forState:UIControlStateNormal];
        [self performSelector:@selector(PushToGuideBookViewController) withObject:nil afterDelay:0.01];
    }
    else {
        self.isAllowClick = YES;
    }
}

- (void) PushToGuideBookViewController
{
    [self performSegueWithIdentifier:@"PushGuideBookViewController" sender:self];
}

- (IBAction) onTagsButtonClicked: (id) sender
{
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        NSLog(@"onTagsButtonClicked");
        UIButton *tagButton = (UIButton *)sender;
        UIImage *backgroundImage = [UIImage imageNamed:@"tag_h"];
        [tagButton setImage:backgroundImage forState:UIControlStateNormal];
        [self performSelector:@selector(pushToTagListController) withObject:nil afterDelay:0.01];
    }
    else {
        self.isAllowClick = YES;
    }
}
-(void)pushToTagListController{
    
    [self performSegueWithIdentifier:@"PushTagsListViewController" sender:self];
}

- (IBAction) onCameraBarButtonClicked: (id) sender
{
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        if(!self.searchDisplayController.searchBar.hidden) {
            [self.scrollView setScrollEnabled:YES];
            
            [UIView animateWithDuration:0.3 animations:^() {
                [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                self.searchDisplayController.searchBar.frame = CGRectMake(0, -20, self.searchDisplayController.searchBar.frame.size.width, self.searchDisplayController.searchBar.frame.size.height);
            } completion:^(BOOL finished) {
                [self.searchDisplayController.searchBar setHidden:YES];
            }];
        }
        
        NSLog(@"onCameraBarButtonClicked");
        UIButton *cameraButton = (UIButton *)sender;
        UIImage *backgroundImage = [UIImage imageNamed:@"camera_h"];
        [cameraButton setImage:backgroundImage forState:UIControlStateNormal];
        __weak TopScreenViewController *selfPointer = self;
        [appDelegate showActionSheetSimulationViewForSpot:nil completetion:^{
            selfPointer.isAllowClick = YES;
            UIImage *backgroundImage = [UIImage imageNamed:@"camera"];
            [cameraButton setImage:backgroundImage forState:UIControlStateNormal];
        }];
    }
    else {
        self.isAllowClick = YES;
    }
}

- (IBAction)onSpotListButtonClicked:(id)sender {
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        NSLog(@"onSpotListClicked");
        UIButton *spotListButton = (UIButton *)sender;
        UIImage *backgroundImage = [UIImage imageNamed:@"spot_list_h"];
        [spotListButton setImage:backgroundImage forState:UIControlStateNormal];
        [self performSelector:@selector(PushToSpotListViewController) withObject:nil afterDelay:0.01];
    }
    else {
        self.isAllowClick = YES;
    }
}
- (void) PushToSpotListViewController
{
    [self performSegueWithIdentifier:@"PushSpotListViewController" sender:self];
    
}

- (IBAction)onAddGuideBookButtonClicked:(id)sender {
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        NSLog(@"onCreateGuideBookClicked");
        UIButton *createGuideBookButton = (UIButton *)sender;
        UIImage *backgroundImage = [UIImage imageNamed:@"Add_guide_h"];
        [createGuideBookButton setImage:backgroundImage forState:UIControlStateNormal];
        [self performSelector:@selector(PushToCreateGuideBookViewController) withObject:nil afterDelay:0.01];
    }
    else {
        self.isAllowClick = YES;
    }
}
- (void) PushToCreateGuideBookViewController
{
    selectedGuideBook = [GuideBook MR_createEntity];
    
    [self performSegueWithIdentifier:@"PushGuideBookDetailsViewControllerNoAnimation" sender:self];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self performSegueWithIdentifier:@"PushCreateGuideBookViewController" sender:self];
    }
}

- (IBAction)onAddSpotButtonClicked:(id)sender {
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        NSLog(@"onCreateSpotClicked");
        UIButton *createSpotButton = (UIButton *)sender;
        UIImage *backgroundImage = [UIImage imageNamed:@"add_spot_h"];
        [createSpotButton setImage:backgroundImage forState:UIControlStateNormal];
        
        // create new spot
        selectedSpot = [SPOT MR_createEntity];
        
        [self performSelector:@selector(PushToCreateSpotViewController) withObject:nil afterDelay:0.01];
    }
    else {
        self.isAllowClick = YES;
    }
}
- (void) PushToCreateSpotViewController
{
    [self performSegueWithIdentifier:@"PushDetailsViewControllerNoAnimation" sender:self];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self performSegueWithIdentifier:@"PushCreateSPOTViewControllerToEdit" sender:self];
    }
}

- (void)tableViewReloadData {
    if (self.searchDisplayController.isActive) {
        
        [self.fetchedResultsController performFetch:nil];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [formatterForMonthLabel stringFromDate:[[[sectionInfo objects] objectAtIndex:0] date]];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont fontWithName:FONT_NAME size:FONT_SMALL_SIZE];
    lbl.text = [formatterForMonthLabel stringFromDate:[[[sectionInfo objects] objectAtIndex:0] date]];
    lbl.textColor = [UIColor whiteColor];
    lbl.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Slice_icon_110"]];
    lbl.alpha = 0.9;
    return lbl;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    if ([[Banner shared] shouldShowAds]) {
        
        return [sectionInfo numberOfObjects]+1;
    }
    else{
        return [sectionInfo numberOfObjects];
    }
}

- (void)configureCell:(SWTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Add utility buttons
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[UIImage imageNamed:@"Slice_icon_120"] selectedIcon:[UIImage imageNamed:@"Slice_icon_120"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[UIImage imageNamed:@"Slice_icon_122"] selectedIcon:[UIImage imageNamed:@"Slice_icon_122"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[UIImage imageNamed:@"Slice_icon_117"] selectedIcon:[UIImage imageNamed:@"Slice_icon_117"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[UIImage imageNamed:@"Slice_icon_128"] selectedIcon:[UIImage imageNamed:@"Slice_icon_128"]];
    
    cell.rightUtilityButtons = rightUtilityButtons;
    
    cell.delegate = self;
    
    SPOT *spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel *spotNameLabel = (UILabel*)[cell viewWithTag:1];
    [spotNameLabel setText:spot.spot_name];
    spotNameLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_NORMAL_SIZE];
    
    UILabel *addressLabel = (UILabel*)[cell viewWithTag:2];
    [addressLabel setText: [NSString stringWithFormat:@"Address: %@", spot.address != nil ? spot.address : @""]];
    addressLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SMALL_SIZE];
    NSString *tagStringConcat = @"";
    for (int i=0; i<spot.tag.count; i++)
    {
        Tag *tag = [spot.tag.allObjects objectAtIndex:i];
        tagStringConcat = [tagStringConcat stringByAppendingFormat:(i==spot.tag.count-1)?@"%@":@"%@, ",tag.tag];
        
    }
    
    UILabel *tagsLabel = (UILabel*)[cell viewWithTag:3];
    [tagsLabel setText: [NSString stringWithFormat:@"Tags: %@", tagStringConcat]];
    tagsLabel.font =[UIFont fontWithName:FONT_NAME size:FONT_SMALL_SIZE];
    
    if (spot.image.count>0)
    {
        __weak UIImageView *imageView = (UIImageView*)[cell viewWithTag:4];
        imageView.clipsToBounds = YES;
        
        [appDelegate.detailsImageCacher getImageByFileName:[spot firstImageFileName] completionHandler:^(BOOL success, UIImage *image) {
            if (success) {
                UIImageView *innerImageView = imageView;
                innerImageView.image = image;
            }
        }];
        
    }
    
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:5];
    dateLabel.text = [formatterForDateLabel stringFromDate:spot.date];
    dateLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SMALL_SIZE];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id <NSFetchedResultsSectionInfo> lastSection;
    
    lastSection = self.fetchedResultsController.sections.lastObject;
    
    if (!(indexPath.section ==self.fetchedResultsController.sections.count - 1 && indexPath.row ==[lastSection numberOfObjects])) {
        
        return 60.0f;
    }
    else{
        
        return MEDIUM_ADS_HEIGHT + ADS_MARGIN_HEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> lastSection;
    
    
    lastSection = self.fetchedResultsController.sections.lastObject;
    
    if (!(indexPath.section ==self.fetchedResultsController.sections.count-1 && indexPath.row ==[lastSection numberOfObjects])) {
        
        SPOT *spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
        static NSString *CellIdentifier = @"SPOT List Cell";
        static NSString *NoImageCellIdentifier = @"SPOT List Cell No Image";
        SWTableViewCell *cell;
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:spot.image.count>0?CellIdentifier:NoImageCellIdentifier forIndexPath:indexPath];
            // Configure the cell...
            if (cell == nil) {
                cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:spot.image.count>0?CellIdentifier:NoImageCellIdentifier];
            }
            [self configureCell:cell atIndexPath:indexPath];
        }
        return cell;
    }else{
        
        UITableViewCell *cell;
        static NSString *cellBannerIdentifier = @"Cell_Banner";
        cell = [tableView dequeueReusableCellWithIdentifier:cellBannerIdentifier];
        if(!cell){
            
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellBannerIdentifier];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [[Banner shared] hideMediumBanner];
        
        [[Banner shared] showMediumBannerViewInView:cell];
        
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> lastSection;
    
    lastSection = self.fetchedResultsController.sections.lastObject;
    
    if (!(indexPath.section ==self.fetchedResultsController.sections.count - 1 && indexPath.row ==[lastSection numberOfObjects])) {
        
        self.searchDisplayController.searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        [[Banner shared]hideSmallBanner];
        
        
        [self performSegueWithIdentifier:@"PushDetailsViewController" sender:self];
    } else {
        return;
    }
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"spot_name contains[c] %@", searchText];
    
    self.fetchedResultsController = [SPOT MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:resultPredicate groupBy:@"month" delegate:self];
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"PushDetailsViewController"])
    {
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        SPOT *spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
        // Get reference to the destination view controller
        SpotDetailsXibViewController *detailsViewController = [segue destinationViewController];
        
        [detailsViewController setSpot:spot];
    }
    else if ([[segue identifier] isEqualToString:@"PushDetailsViewControllerNoAnimation"]) {
        SpotDetailsXibViewController *detailsViewController = [segue destinationViewController];
        
        [detailsViewController setSpot:selectedSpot];
    }
    else if ([[segue identifier] isEqualToString:@"PushDetailsViewControllerNoAnimationWithImageSelected"]) {
        SpotDetailsXibViewController *detailsViewController = [segue destinationViewController];
        SPOT *spot = appDelegate.actionSheetSimulationView.spot;
        [detailsViewController setSpot:spot];
    }
    else if ([[segue identifier] isEqualToString:@"PushGuideBookDetailsViewControllerNoAnimation"]) {
        GuideBookDetailsXibViewController *detailsViewController = [segue destinationViewController];
        
        [detailsViewController setGuideBook:selectedGuideBook];
    }
    else if ([[segue identifier] isEqualToString:@"PushCreateGuideBookViewController"]) {
        CreateGuideBookViewController *controller = [segue destinationViewController];
        
        [controller setGuideBook:selectedGuideBook];
    }
    else if ([[segue identifier] isEqualToString:@"PushCreateSPOTViewControllerWithImageSelected"])
    {
        
        SPOT *spot = appDelegate.actionSheetSimulationView.spot;
        
        // Get reference to the destination view controller
        CreateSPOTViewController *createSPOTViewController = [segue destinationViewController];
        
        [createSPOTViewController setSpot:spot];
    }
    else if ([[segue identifier] isEqualToString:@"PushCreateSPOTViewControllerToEdit"])
    {
        CreateSPOTViewController *createSPOTViewController = [segue destinationViewController];
        
        [createSPOTViewController setSpot:selectedSpot];
    }
    else if ([[segue identifier] isEqualToString:@"PushTagRegisterationViewControllerToEdit"])
    {
        // Get reference to the destination view controller
        TagRegisterationViewController *tagRegisterationViewController = [segue destinationViewController];
        
        [tagRegisterationViewController setSpot:selectedSpot];
    }
}


#pragma mark - NSFetchedResultsControllerDelegate

/*
 
 - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
 // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
 NSLog(@"controllerWillChangeContent");
 [self.searchDisplayController.searchResultsTableView beginUpdates];
 }
 
 
 - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
 
 NSLog(@"didChangeObject");
 
 switch(type) {
 
 case NSFetchedResultsChangeInsert:
 [self.searchDisplayController.searchResultsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
 break;
 
 case NSFetchedResultsChangeDelete:
 [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 break;
 
 case NSFetchedResultsChangeUpdate:
 [self configureCell:(SWTableViewCell*)[self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
 break;
 
 case NSFetchedResultsChangeMove:
 [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:[NSArray
 arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 [self.searchDisplayController.searchResultsTableView insertRowsAtIndexPaths:[NSArray
 arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
 break;
 }
 }
 
 
 - (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
 
 NSLog(@"didChangeSection");
 switch(type) {
 
 case NSFetchedResultsChangeInsert:
 [self.searchDisplayController.searchResultsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
 break;
 
 case NSFetchedResultsChangeDelete:
 [self.searchDisplayController.searchResultsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
 break;
 }
 }
 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
 NSLog(@"controllerDidChangeContent");
 [self.searchDisplayController.searchResultsTableView endUpdates];
 }
 
 */


#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    SPOT *spot;
    
    NSIndexPath *cellIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
    spot = [self.fetchedResultsController objectAtIndexPath:cellIndexPath];
    
    selectedSpot = spot;
    
    switch (index) {
        case 0:
        {
            // Delete button is pressed
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete SPOT"
                                                            message:@"Are you sure you want to delete?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Delete", nil];
            [alert show];
            break;
        }
        case 1:
        {
            // Tag button is pressed
            [self performSegueWithIdentifier:@"PushTagRegisterationViewControllerToEdit" sender:self];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 2:
        {
            // Airdrop button is pressed
            
            NSString *xmlFilePath = [appDelegate saveSpotToXML:spot];
            
            // Build a collection of activity items to share, in this case a url
            NSArray *activityItems = @[[NSURL fileURLWithPath:xmlFilePath]];
            
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            // Exclude all activities except AirDrop.
            NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                            UIActivityTypePostToWeibo,UIActivityTypeMessage, UIActivityTypeMail,UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
            activityController.excludedActivityTypes = excludedActivities;
            [self presentViewController:activityController animated:YES completion:nil];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 3:
        {
            // Edit button is pressed
            [self performSegueWithIdentifier:@"PushCreateSPOTViewControllerToEdit" sender:self];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        default:
            break;
    }
    
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)  // Cancel Button
    {
        NSLog(@"Nothing to do here");
    }
    else
        
    {
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSError *errorDeleteLocal;
        
        if([[NSUserDefaults standardUserDefaults]boolForKey:@"syncDropbox"]){
            
            [[SPDropBox sharedInstance]deleteFileAtPath:[NSString stringWithFormat:@"/%@",[SPOT_DATA_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.spotData",selectedSpot.uuid]]]];
            NSArray *imagesSpot = selectedSpot.image.allObjects;
            for(int i=0;i<selectedSpot.image.count;i++){
                
                Image *img = imagesSpot[i];
                NSLog(@"image:%@",img.image_file_name);
                [[SPDropBox sharedInstance]deleteFileAtPath:[NSString stringWithFormat:@"/%@",[IMAGE_PATH stringByAppendingPathComponent:img.image_file_name]]];
                
            }
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[SPOT_DATA_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.spotData",selectedSpot.uuid]]]);
            
        }
        else if([[NSUserDefaults standardUserDefaults]boolForKey:@"synciCloud"]){
            
            [[iCloud sharedCloud].remoteFiles removeObjectForKey:[selectedSpot.uuid stringByAppendingPathExtension:@"spotData"]];
            
            [[iCloud sharedCloud].localFiles removeObjectForKey:[selectedSpot.uuid stringByAppendingPathExtension:@"spotData"]];
            
            [[iCloud sharedCloud]deleteDocumentWithName:[selectedSpot.uuid stringByAppendingPathExtension:@"spotData"] completion:^(NSError *error) {
                
                if(error){
                    
                    NSLog(@"Could not delete file oniCloud -:%@ ",[error localizedDescription]);
                }
            }];
            
            NSArray *imagesSpot = selectedSpot.image.allObjects;
            for(int i=0;i<selectedSpot.image.count;i++){
                
                Image *img = imagesSpot[i];
                
                [[iCloud sharedCloud].remoteFiles removeObjectForKey:img.image_file_name];
                
                [[iCloud sharedCloud].localFiles removeObjectForKey:img.image_file_name];
                
                [[iCloud sharedCloud]deleteDocumentWithName:img.image_file_name completion:^(NSError *error) {
                    
                    if(error){
                        
                        NSLog(@"Could not delete file oniCloud -:%@ ",[error localizedDescription]);                    }
                }];
            }
        }
        
        if (selectedSpot.uuid) {
            
            [[NSFileManager defaultManager]removeItemAtPath:[[appDelegate applicationDocumentsDirectoryForSpotData] stringByAppendingPathComponent:[selectedSpot.uuid stringByAppendingPathExtension:@"spotData"]] error:&errorDeleteLocal];
        }
        
        if (errorDeleteLocal) {
            
            NSLog(@"Could not delete file onLocal -:%@ ",[errorDeleteLocal localizedDescription]);
        }
        
        [self deleteSpot:selectedSpot];
    }
}



- (void)deleteSpot:(SPOT *)spot {
    for (Image *image in spot.image)
    {
        NSString *savedImagePath = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:image.image_file_name];
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:savedImagePath error:&error];
        if (success) {
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
        [image MR_deleteEntity];
    }
    
    Country *country = spot.country;
    Region *region = spot.region;
    NSLog(@"!!! country %lu", (unsigned long)[country.spot count]);
    // delete guidebook info
    for (GuideBookInfo *guideBookInfo in spot.guide_book_info) {
        // sort guidebook info
        GuideBook *guideBook = guideBookInfo.guide_book;
        
        for (GuideBookInfo *info in guideBook.guide_book_info) {
            if (info.order.intValue > guideBookInfo.order.intValue) {
                info.order = @(info.order.intValue - 1);
            }
        }
        
        [guideBookInfo MR_deleteEntity];
    }
    spot.country = nil;
    spot.region = nil;
    [spot MR_deleteEntity];
    NSLog(@"!!! country %lu", (unsigned long)[country.spot count]);
    // delete country and region if they no longer contain any spot
    if (country.country.length > 0 && [country.spot count] == 0) {
        [country MR_deleteEntity];
    }
    if (region.region.length > 0 && [region.spot count] == 0) {
        [region MR_deleteEntity];
    }
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    // save
    [magicalContext MR_saveOnlySelfAndWait];
    
    [self tableViewReloadData];
}

- (IBAction)op:(id)sender {
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //    [self onSearchButtonClicked:self.searchButton];
    
    self.searchDisplayController.searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [[Banner shared]hideSmallBanner];
    [[Banner shared]hideMediumBanner];
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([[Banner shared] shouldShowAds]) {
        
        self.searchDisplayController.searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        
        [[Banner shared]showSmallBanner];
    }
    
}


#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    
    self.searchDisplayController.searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [[Banner shared]hideSmallBanner];
    [[Banner shared]hideMediumBanner];
}


@end
