//
//  SPOTListTableViewController.m
//  SPOT
//
//  Created by framgia on 7/9/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SPOTListTableViewController.h"
#import "SWTableViewCell.h"
#import "AppDelegate.h"
#import "SPOT.h"
#import "Tag.h"
#import "Image.h"
#import "GuideBookInfo.h"
#import "TagRegisterationViewController.h"
#import "AppDelegate.h"
#import "CreateGuideBookViewController.h"
#import "SPDropBox.h"
#import "iCloud+spotiCloudAddition.h"
#import "AppDelegate.h"
#import "ImageUtility.h"
#import "Country.h"
#import "Region.h"
#import "SPOT+Image.h"
#import "Voice.h"
#import "SpotCell.h"
#import "ImageCacher.h"
#import "TagListViewController.h"
#import "Banner.h"
#import "SpotDetailsXibViewController.h"
#import "AirdropService.h"
#import "GuideBookInfoType.h"

@interface SPOTListTableViewController () <SWTableViewCellDelegate, CreateSPOTViewControllerDelegate, SpotCellDelegate>

{
    
    BOOL hasToShowSpotDetails;
    BOOL isPushingDetailsView;
    BOOL shouldReloadTableView;
    BOOL isViewPresented;
    BOOL isAllowClick;
    BOOL shouldShowAds;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedSearchResultsController;
@property (nonatomic, copy) NSArray *spots;
@property (nonatomic) NSDateFormatter *formatterForDateLabel;
@property (nonatomic) NSDateFormatter *formatterForMonthLabel;
@property (nonatomic) SPOT *selectedSpot;

@end

@implementation SPOTListTableViewController

AppDelegate *appDelegate;

//CATransition *animation;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    @autoreleasepool {
        //hide search bar
        self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        self.formatterForDateLabel = dateFormatter;
        
        NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
        [monthFormatter setDateFormat:@"MMMM yyyy"];
        [monthFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        self.formatterForMonthLabel = dateFormatter;
        
        //    [FontHelper setFontFamily:FONT_NAME forView:self.view andSubViews:YES];
        
        if (self.filterDate)
        {
            // moved from calendar screen
            NSDate *startDate = self.filterDate;
            NSTimeInterval length;
            
            [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                                            startDate:&startDate
                                             interval:&length
                                              forDate:startDate];
            
            NSDate *endDate = [startDate dateByAddingTimeInterval:length];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)", startDate, endDate];
            NSFetchedResultsController *fetchedResultsController = [SPOT MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:predicate groupBy:nil delegate:nil];
            self.fetchedResultsController = fetchedResultsController;
            
            // hide section header because there is only 1 section
            [self.tableView setSectionHeaderHeight:0];
            
            // remove search bar
            [self.tableView setTableHeaderView:nil];
            
            // hide search button
            // Get the reference to the current toolbar buttons
            NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
            
            // This is how you remove the button from the toolbar
            [toolbarButtons removeObject:self.searchButton];
            [toolbarButtons removeObject:self.addButton];
            [self setToolbarItems:toolbarButtons animated:NO];
            
        }
        else
        {
            // moved from top screen or tag list screen
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY tag.tag like %@", self.filterTag];
            
            NSFetchedResultsController *fetchedResultsController = [SPOT MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:self.filterTag?predicate:nil groupBy:@"month" delegate:nil];
            
            self.fetchedResultsController = fetchedResultsController;
            
        }
        shouldReloadTableView = NO;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSendAirDropFinish) name:@"SaveAirDropFileFinish" object:nil];

    }
    
}

- (void)handleSendAirDropFinish {
    shouldReloadTableView = YES;
    [self performSelectorOnMainThread:@selector(tableViewReloadData) withObject:nil waitUntilDone:YES];
}

- (void)dealloc {
 
    self.spots = nil;
    self.fetchedResultsController = nil;
    self.fetchedSearchResultsController = nil;
    self.formatterForMonthLabel = nil;
    self.formatterForDateLabel = nil;
   
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"SPOT list died.");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    NSLog(@"viewWillAppear spot list");
    [super viewWillAppear:animated];
    
    shouldShowAds = [[Banner shared] shouldShowAds];
    if (shouldShowAds) {
        [[Banner shared]showSmallBannerAboveToolbar];
    }
    isViewPresented = YES;
    isAllowClick = YES;
    
    // change search icon => tag icon if transition from create guide book screen
    if (self.guideBook && !self.filterTag) {
        UIImage *tagImage = [UIImage imageNamed:@"Slice_icon_13"];
        self.searchButton.image = tagImage;
    }
    
    
    // skip reload at first time
    //    NSLog(@"%@", appDelegate.spotTableLastUpdateDate);
    //    NSLog(@"%@", self.lastReloadDataDate);
    //    if (appDelegate.spotTableLastUpdateDate && ([appDelegate.spotTableLastUpdateDate compare:self.lastReloadDataDate] == NSOrderedDescending)) {
    //         [self tableViewReloadData];
    //    }
    
    [self tableViewReloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    isViewPresented = NO;
    isPushingDetailsView = NO;
}


-(void)viewWillDisappear:(BOOL)animated
{
    //    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillDisappear:animated];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [[Banner shared]hideSmallBannerAboveToolbar];
    shouldReloadTableView = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    self.navigationController.navigationBar.translucent = NO;
    
    //    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    //        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7 specific
}

- (void)hideAllCellUtilityButtons {
    UITableView *tableView = self.tableView;
    for (NSInteger j = 0; j < [tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
        {
            @autoreleasepool {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if ([cell isKindOfClass:[SWTableViewCell class]]) {
                    SWTableViewCell *swCell = (SWTableViewCell *)cell;
                    [swCell hideUtilityButtonsAnimated:YES];
                }
            }
        }
    }
}

- (void)tableViewReloadData {
    if (!shouldReloadTableView) {
        return;
    }
    shouldReloadTableView = NO;
    //    self.lastReloadDataDate = [NSDate date];
    
    if (self.searchDisplayController.isActive) {
        [self.fetchedSearchResultsController performFetch:nil];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else {
        [self.fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    }
    
    //    [self.fetchedResultsController performFetch:nil];
    //    [self.tableView reloadData];
    
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideAllCellUtilityButtons];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count;
    if (tableView == self.tableView){
        count = self.fetchedResultsController.sections.count;
    }
    else count = self.fetchedSearchResultsController.sections.count;
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo;
    if (tableView == self.tableView){
        sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    }
    else {
        sectionInfo = [self.fetchedSearchResultsController.sections objectAtIndex:section];
    }
    if ([[sectionInfo objects] count] > 0) {
        NSString *title = [self.formatterForMonthLabel stringFromDate:[[[sectionInfo objects] objectAtIndex:0] date]];
        return title;
    }
    return @"";
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    @autoreleasepool {
        id <NSFetchedResultsSectionInfo> sectionInfo;
        if (tableView == self.tableView){
            sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
        }
        else {
            sectionInfo = [self.fetchedSearchResultsController.sections objectAtIndex:section];
        }
        UILabel *lbl = [[UILabel alloc] init];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = appDelegate.smallFont;
        if (sectionInfo) {
            NSString *title = [self.formatterForMonthLabel stringFromDate:[[[sectionInfo objects] objectAtIndex:0] date]];
            lbl.text = title;
        }
        lbl.textColor = [UIColor whiteColor];
        lbl.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Slice_icon_110"]];
        lbl.alpha = 0.9;
        return lbl;
    }
}


/*
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
 #warning Incomplete method implementation.
 // Return the number of rows in the section.
 return 0;
 }
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo;
    NSInteger numberOfRows;
    
    if (tableView == self.tableView){
        
        sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
        
        if (sectionInfo == nil) {
            numberOfRows = 1;
        }
        else if(section<self.fetchedResultsController.sections.count-1){
            numberOfRows = [sectionInfo numberOfObjects];
            
        }
        else {
            if (shouldShowAds) {
                numberOfRows = [sectionInfo numberOfObjects]+1;
            }
            else {
                numberOfRows = [sectionInfo numberOfObjects];
            }
        }
    }
    else {
        
        sectionInfo = [self.fetchedSearchResultsController.sections objectAtIndex:section];
        if(section<self.fetchedSearchResultsController.sections.count-1){
            
            numberOfRows = [sectionInfo numberOfObjects];
        }
        else{
            if (shouldShowAds) {
                numberOfRows = [sectionInfo numberOfObjects]+1;
            }
            else{
                numberOfRows = [sectionInfo numberOfObjects];
            }
        }
    }
    
    return numberOfRows;
}


-(NSUInteger)countAllObjectInSections:(NSArray*)sections{
    
    NSUInteger count = 0;
    
    for (id <NSFetchedResultsSectionInfo> sectionInfo in sections) {
        
        count += [sectionInfo numberOfObjects];
    }
    
    return count;
}

- (void)configureCellDisplay:(SWTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    @autoreleasepool {
        SpotCell *spotCell = (SpotCell *)cell;
        [spotCell addUtilityButton];
        spotCell.delegate = self;
        
        // get spot
        SPOT *spot;
        if (tableView == self.tableView) {
            spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        else {
            spot = [self.fetchedSearchResultsController objectAtIndexPath:indexPath];
        }
        
        // config name label
        UILabel *spotNameLabel = spotCell.spotNameLabel;
        NSString *spotName = spot.spot_name;
        [spotNameLabel setText:spotName];
        
        
        // config address label
        UILabel *addressLabel = spotCell.addressLabel;
        NSString *address = [NSString stringWithFormat:@"Address: %@", spot.address != nil ? spot.address : @""];
        [addressLabel setText: address];
        
        
        // config tag label
        NSString *tagStringConcat = @"";
        for (int i=0; i<spot.tag.count; i++)
        {
            Tag *tag = [spot.tag.allObjects objectAtIndex:i];
            tagStringConcat = [tagStringConcat stringByAppendingFormat:(i==spot.tag.count-1)?@"%@":@"%@, ",tag.tag];
            
        }
        
        UILabel *tagsLabel = spotCell.tagsLabel;
        NSString *tag = [NSString stringWithFormat:@"Tags: %@", tagStringConcat];
        [tagsLabel setText: tag];
        
        
        // config image pager
        if (spot.image.count>0)
        {
            __weak UIImageView *imageView = spotCell.detailsImageView;
            imageView.clipsToBounds = YES;
            
            [appDelegate.detailsImageCacher getImageByFileName:[spot firstImageFileName] completionHandler:^(BOOL success, UIImage *image) {
                UIImageView *innerImageView = imageView;
                if (success) {
                    innerImageView.image = image;
                }
            }];
            
        }
        
        UILabel *dateLabel = spotCell.dateLabel;
        NSString *title = [self.formatterForDateLabel stringFromDate:spot.date];
        dateLabel.text = title;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id <NSFetchedResultsSectionInfo> lastSection;
    
    if (tableView == self.tableView){
        
        lastSection = self.fetchedResultsController.sections.lastObject;
    }
    else {
        lastSection = self.fetchedSearchResultsController.sections.lastObject;
    }
    // case last row of last section of table view is ads
    if((tableView == self.tableView && indexPath.section==self.fetchedResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects])){
        //banner
        return MEDIUM_ADS_HEIGHT + SMALL_ADS_HEIGHT + ADS_MARGIN_HEIGHT;
    }
    // case last row of last section of search table is ads
    else if (tableView != self.tableView && indexPath.section==self.fetchedSearchResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects]){
        
        if ([self countAllObjectInSections:self.fetchedSearchResultsController.sections]>=2) {
            
            return MEDIUM_ADS_HEIGHT + SMALL_ADS_HEIGHT + ADS_MARGIN_HEIGHT;
        }
        else{
            
            return MEDIUM_ADS_HEIGHT + ADS_MARGIN_HEIGHT;
        }
    }
    else return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @autoreleasepool {
        id <NSFetchedResultsSectionInfo> lastSection;
        
        if (tableView == self.tableView){
            
            lastSection = self.fetchedResultsController.sections.lastObject;
        }
        else {
            lastSection = self.fetchedSearchResultsController.sections.lastObject;
        }
        
        // NSLog(@"indexPath....%ld:%ld.....max%lu",(long)indexPath.section,(long)indexPath.row,(unsigned long)[lastSection numberOfObjects]);
        
        
        if(!((tableView == self.tableView && indexPath.section==self.fetchedResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects])|| (tableView != self.tableView && indexPath.section==self.fetchedSearchResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects]))){
            
            SPOT *spot = nil;
            if (tableView == self.tableView) {
                spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
            }
            else {
                spot = [self.fetchedSearchResultsController objectAtIndexPath:indexPath];
            }
            static NSString *CellIdentifier = @"SPOT List Cell";
            static NSString *NoImageCellIdentifier = @"SPOT List Cell No Image";
            SWTableViewCell *cell;
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                cell = (SWTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:spot.image.count>0?CellIdentifier:NoImageCellIdentifier];
            }else{
                cell = (SWTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:spot.image.count>0?CellIdentifier:NoImageCellIdentifier forIndexPath:indexPath];
            }
            // Configure the cell...
            if (cell == nil) {
                cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:spot.image.count>0?CellIdentifier:NoImageCellIdentifier];
                /*[self configureCellUtilityDisplay:cell atIndexPath:indexPath inTableView:tableView];*/
            }
            
            [self configureCellDisplay:cell atIndexPath:indexPath inTableView:tableView];
            
            return cell;
        }
        else{
            
            UITableViewCell *cell;
            static NSString *cellBannerIdentifier = @"Cell_Banner";
            cell = [tableView dequeueReusableCellWithIdentifier:cellBannerIdentifier];
            if(!cell){
                
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellBannerIdentifier];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            //        [[Banner shared] hideMediumBanner];
            
            [[Banner shared] showMediumBannerViewInView:cell];
            
            return cell;
        }

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isAllowClick) {
        isAllowClick = NO;
        if (isPushingDetailsView) {
            return;
        }
        
        id <NSFetchedResultsSectionInfo> lastSection;
        
        if (tableView == self.tableView){
            
            lastSection = self.fetchedResultsController.sections.lastObject;
        }
        else {
            lastSection = self.fetchedSearchResultsController.sections.lastObject;
        }
        
        if(!((tableView == self.tableView && indexPath.section==self.fetchedResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects])|| (tableView != self.tableView && indexPath.section==self.fetchedSearchResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects]))){
            
            if (self.guideBook)
            {
                @autoreleasepool {
                    // if transition from create guide book screen
                    GuideBookInfo *guideBookInfo = [GuideBookInfo MR_createEntity];
                    
                    // set info_type to spot (2)
                    guideBookInfo.info_type = [NSNumber numberWithInt:GuideBookInfoTypeSpot];
                    if (tableView == self.tableView){
                        guideBookInfo.spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    }
                    else {
                        guideBookInfo.spot = [self.fetchedSearchResultsController objectAtIndexPath:indexPath];
                    }
                    NSIndexPath *selectedCellIndexPath = self.indexPathForInsertingIntoGuideBook;
                    if (selectedCellIndexPath)
                    {
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(guide_book = %@) AND (order > %d)", self.guideBook.objectID, selectedCellIndexPath.row];
                        NSArray *needUpdateGuideBookInfo = [GuideBookInfo MR_findAllWithPredicate:predicate];
                        
                        
                        for (GuideBookInfo *info in needUpdateGuideBookInfo)
                        {
                            info.order = [NSNumber numberWithInt:info.order.intValue + 1];
                        }
                        
                        guideBookInfo.order = [NSNumber numberWithInteger:selectedCellIndexPath.row + 1];
                    }
                    else
                    {
                        guideBookInfo.order = [NSNumber numberWithInteger:self.guideBook.guide_book_info.count];
                    }
                    guideBookInfo.guide_book = self.guideBook;
                    [self.guideBook addGuide_book_infoObject:guideBookInfo];
                    
                    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
                    // save
                    [magicalContext MR_saveOnlySelfAndWait];
                    
                    __weak GuideBook *weakGuideBook = guideBookInfo.guide_book;
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        GuideBook *innerGuideBook = weakGuideBook;
                        [appDelegate saveGuideBookToXMLForSync:innerGuideBook];
                    });
                    // in case guidebook add spot directly
                    if (!self.filterTag) {
                        [self performSelector:@selector(popSelf) withObject:nil afterDelay:0.05];
                    }
                    // in case guidebook add spot when search by tag
                    else {
                        [self performSelector:@selector(popSelfAndTag) withObject:nil afterDelay:0.05];
                    }
                }
            }
            else
            {
                @autoreleasepool {
                    isPushingDetailsView = YES;
                    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
                    SPOT *spot;
                    if (indexPath){
                        spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    }
                    else {
                        indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                        spot = [self.fetchedSearchResultsController objectAtIndexPath:indexPath];
                    }
                    
                    self.selectedSpot = spot;
                    
                    [self performSelector:@selector(pushDetails) withObject:nil afterDelay:0.05];
                }
            }
        }
        else {
            // click the margin of ads
            NSLog(@"click banner");
            isAllowClick = YES;
        }
    }
    else {
        isAllowClick = YES;
    }
}

- (void)popSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popSelfAndTag {
    NSArray* controllers = [[self navigationController] viewControllers];
    UIViewController* requireController = nil;
    for (int i = 0; i < [controllers count]; i++) {
        requireController = [[[self navigationController] viewControllers] objectAtIndex:i];
        if ([requireController isKindOfClass:[CreateGuideBookViewController class]]) {
            [[self navigationController] popToViewController:requireController animated:YES];
        }
    }
}

- (void)pushDetails {
    
    [self performSegueWithIdentifier:@"PushDetailsViewControllerXib" sender:self];
}

#pragma mark - SearchDisplayControllerDelegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate;
    if (self.filterTag)
    {
        resultPredicate = [NSPredicate predicateWithFormat:@"(spot_name contains[c] %@) and (tag.tag contains[c] %@)", searchText, self.filterTag];
    }
    else
    {
        resultPredicate = [NSPredicate predicateWithFormat:@"spot_name contains[c] %@", searchText];
    }
    
    //delete cache
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSFetchedResultsController *fetchedResultsController = [SPOT MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:resultPredicate groupBy:@"month" delegate:nil];

    self.fetchedSearchResultsController = fetchedResultsController;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    [self hideAllCellUtilityButtons];
    
//    for (id cell  in self.searchDisplayController.searchResultsTableView.visibleCells) {
//        
//        if ([cell isKindOfClass:[SpotCell class]]) {
//            
//            SpotCell *spotCell = cell;
//            [spotCell addUtilityButton];
//        }
//    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"PushDetailsViewControllerXib"])
    {
        // Get reference to the destination view controller
        SpotDetailsXibViewController *detailsViewController = [segue destinationViewController];
        if ([self.searchDisplayController isActive]) {
            detailsViewController.spots = [self.fetchedSearchResultsController fetchedObjects];
            
        }
        else {
            detailsViewController.spots = [self.fetchedResultsController fetchedObjects];
        }
        
        [detailsViewController setSpot:self.selectedSpot];
    }
    else if ([[segue identifier] isEqualToString:@"PushDetailsViewControllerXibNoAnimation"])
    {
        // Get reference to the destination view controller
        SpotDetailsXibViewController *detailsViewController = [segue destinationViewController];
        
        
        [detailsViewController setSpot:self.selectedSpot];
    }
    else if ([[segue identifier] isEqualToString:@"PushDetailsViewControllerNoAnimation"])
    {
        // Get reference to the destination view controller
        SpotDetailsXibViewController *detailsViewController = [segue destinationViewController];
        
        
        [detailsViewController setSpot:self.selectedSpot];
    }
    else if ([[segue identifier] isEqualToString:@"PushCreateSPOTViewControllerToEdit"])
    {
        // Get reference to the destination view controller
        CreateSPOTViewController *createSPOTViewController = [segue destinationViewController];
        createSPOTViewController.delegate = self;
        [createSPOTViewController setSpot:self.selectedSpot];
    }
    else if ([[segue identifier] isEqualToString:@"PushCreateSPOTViewControllerToCreate"])
    {
        // Get reference to the destination view controller
        CreateSPOTViewController *createSPOTViewController = [segue destinationViewController];
        createSPOTViewController.delegate = self;
    }
    
    else if ([[segue identifier] isEqualToString:@"PushTagRegisterationViewControllerToEdit"])
    {
        // Get reference to the destination view controller
        TagRegisterationViewController *tagRegisterationViewController = [segue destinationViewController];
        
        [tagRegisterationViewController setSpot:self.selectedSpot];
    }
    else if ([[segue identifier] isEqualToString:@"PushTagsViewController"])
    {
        TagListViewController *tagListViewController = [segue destinationViewController];
        tagListViewController.guideBook = self.guideBook;
        tagListViewController.indexPathForInsertingIntoGuideBook = self.indexPathForInsertingIntoGuideBook;
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (IBAction)onBackButtonClicked:(id)sender
{
    //    if (self.isViewLoaded && self.view.window){
    //        [self performSelector:@selector(popSelf) withObject:nil afterDelay:0.1];
    //    }
    if (isAllowClick) {
        isAllowClick = NO;
        [self popSelf];
    }
    else {
        isAllowClick = YES;
    }
}
- (IBAction)onSearchButtonClicked:(id)sender
{
    if (isAllowClick) {
        // change search icon => tag icon if transition from create guide book screen
        if (self.guideBook && !self.filterTag) {
            [self performSegueWithIdentifier:@"PushTagsViewController" sender:self];
        }
        else {
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self.searchDisplayController.searchBar becomeFirstResponder];
        }
    }
    else {
        isAllowClick = YES;
    }
}

- (void)onAddButtonClick:(id)sender {
    //    shouldReloadViewData = YES;
    if (isAllowClick) {
        isAllowClick = NO;
        [self addSpot];
    }
    else {
        isAllowClick = YES;
    }
}

- (void)addSpot {
    //    DetailsViewController *detailsController = [[DetailsViewController alloc] init];
    //    detailsController.spot = selectedSpot;
    //    [self.navigationController pushViewController:detailsController animated:NO];
    
    SPOT *spot = [SPOT MR_createEntity];
    self.selectedSpot = spot;
    
    [self performSegueWithIdentifier:@"PushDetailsViewControllerXibNoAnimation" sender:self];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self performSegueWithIdentifier:@"PushCreateSPOTViewControllerToEdit" sender:self];
    }
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    if (isAllowClick) {
        isAllowClick = NO;
        SPOT *spot;
        if (self.searchDisplayController.active){
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
            spot = [self.fetchedSearchResultsController objectAtIndexPath:indexPath];
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        
        self.selectedSpot = spot;
        
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
                [self sendAirdropWithSpot:spot];
                
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
    else {
        isAllowClick = YES;
    }
}

- (void)sendAirdropWithSpotTest:(SPOT *)spot {
    AirdropService *service = [AirdropService new];
    
    NSString *filePath = [service sendSpot:spot];
    
    [service importObjectFromFile:filePath];
}

- (void)sendAirdropWithSpot:(SPOT *)spot {
    AirdropService *service = [AirdropService new];
    SPOT *localSpot = spot;
    NSString *filePath = [service sendSpot:localSpot];
    
    // Build a collection of activity items to share, in this case a url
    NSArray *activityItems = @[[NSURL fileURLWithPath:filePath]];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    // Exclude all activities except AirDrop.
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,UIActivityTypeMessage, UIActivityTypeMail,UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    activityController.excludedActivityTypes = excludedActivities;
    
    [self presentViewController:activityController animated:YES completion:^{
        isAllowClick = YES;
    }];
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
            
            [[SPDropBox sharedInstance]deleteFileAtPath:[NSString stringWithFormat:@"/%@",[SPOT_DATA_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.spotData",self.selectedSpot.uuid]]]];
            NSArray *imagesSpot = self.selectedSpot.image.allObjects;
            for(int i=0;i<self.selectedSpot.image.count;i++){
                
                Image *img = imagesSpot[i];
                NSLog(@"image:%@",img.image_file_name);
                [[SPDropBox sharedInstance]deleteFileAtPath:[NSString stringWithFormat:@"/%@",[IMAGE_PATH stringByAppendingPathComponent:img.image_file_name]]];
                
            }
            //
            NSArray *voiceSpot = self.selectedSpot.voice.allObjects;
            for (int i=0; i<self.selectedSpot.voice.count; i++) {
                
                Voice *voice = voiceSpot[i];
                [[SPDropBox sharedInstance]deleteFileAtPath:[NSString stringWithFormat:@"/%@",[MEMO_VOICE_DATA_PATH stringByAppendingFormat:@"/%@.%@",voice.uuid, EXTENSION_RECORD]]];
            }
            
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[SPOT_DATA_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.spotData",self.selectedSpot.uuid]]]);
            
        }
        else if([[NSUserDefaults standardUserDefaults]boolForKey:@"synciCloud"]){
            
            [[iCloud sharedCloud].remoteFiles removeObjectForKey:[self.selectedSpot.uuid stringByAppendingPathExtension:@"spotData"]];
            
            [[iCloud sharedCloud].localFiles removeObjectForKey:[self.selectedSpot.uuid stringByAppendingPathExtension:@"spotData"]];
            
            [[iCloud sharedCloud]deleteDocumentWithName:[self.selectedSpot.uuid stringByAppendingPathExtension:@"spotData"] completion:^(NSError *error) {
                
                if(error){
                    
                    NSLog(@"Could not delete file oniCloud -:%@ ",[error localizedDescription]);
                }
            }];
            
            NSArray *imagesSpot = self.selectedSpot.image.allObjects;
            for(int i=0;i<self.selectedSpot.image.count;i++){
                
                Image *img = imagesSpot[i];
                
                [[iCloud sharedCloud].remoteFiles removeObjectForKey:img.image_file_name];
                
                [[iCloud sharedCloud].localFiles removeObjectForKey:img.image_file_name];
                
                [[iCloud sharedCloud]deleteDocumentWithName:img.image_file_name completion:^(NSError *error) {
                    
                    if(error){
                        
                        NSLog(@"Could not delete file oniCloud -:%@ ",[error localizedDescription]);                    }
                }];
            }
            
            NSArray *voiceSpot = self.selectedSpot.voice.allObjects;
            for(int i=0;i<self.selectedSpot.voice.count;i++){
                
                Voice* voice = voiceSpot[i];
                
                [[iCloud sharedCloud].remoteFiles removeObjectForKey:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD]];
                
                [[iCloud sharedCloud].localFiles removeObjectForKey:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD]];
                
                [[iCloud sharedCloud]deleteDocumentWithName:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD] completion:^(NSError *error) {
                    
                    if(error){
                        
                        NSLog(@"Could not delete file oniCloud -:%@ ",[error localizedDescription]);                    }
                }];
            }
        }
        
        if (self.selectedSpot.uuid) {
            
            [[NSFileManager defaultManager]removeItemAtPath:[[appDelegate applicationDocumentsDirectoryForSpotData] stringByAppendingPathComponent:[self.selectedSpot.uuid stringByAppendingPathExtension:@"spotData"]] error:&errorDeleteLocal];
        }
        
        if (errorDeleteLocal) {
            
            NSLog(@"Could not delete file onLocal -:%@ ",[errorDeleteLocal localizedDescription]);
        }
        
        [self deleteSpot:self.selectedSpot];
    }
    isAllowClick = YES;
}



- (void)deleteSpot:(SPOT *)deletedSpot {
    SPOT *spot = deletedSpot;
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
    
    for (Voice*voice in spot.voice)
    {
        
        NSError *errorDeleteLocal;
        
        [[NSFileManager defaultManager]removeItemAtPath:[[appDelegate applicationDocumentsDirectoryForMemoVoice] stringByAppendingPathComponent:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD]] error:&errorDeleteLocal];
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
    NSSet *spotTag = spot.tag;
    for (Tag *tag in spotTag) {
        if ([tag.spot count] == 1) {
            [tag MR_deleteEntity];
        }
    }
    
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
    
    shouldReloadTableView = YES;
    [self tableViewReloadData];
    
//    [self.fetchedResultsController performFetch:nil];
//    [self.fetchedSearchResultsController performFetch:nil];
//    
//    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - CreateSPOTViewControllerDelegate

- (void)didCreateNewSpot:(SPOT *)spot {
    self.selectedSpot = spot;
    hasToShowSpotDetails = YES;
}

- (IBAction)longPressGestureRecognized:(id)sender {
    if (self.guideBook) {
        UILongPressGestureRecognizer *gesture =  (UILongPressGestureRecognizer *)sender;
        CGPoint p;
        
        NSIndexPath *indexPath;
        SPOT *spot;
        
        if (self.searchDisplayController.active) {
            p = [gesture locationInView:self.searchDisplayController.searchResultsTableView];
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForRowAtPoint:p];
            if (indexPath) {
                spot = [self.fetchedSearchResultsController objectAtIndexPath:indexPath];
            }
        }
        else {
            p = [gesture locationInView:self.tableView];
            indexPath = [self.tableView indexPathForRowAtPoint:p];
            if (indexPath) {
                spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
            }
        }
        
        
        if (spot) {
            isPushingDetailsView = YES;
            self.selectedSpot = spot;
            
            [self performSegueWithIdentifier:@"PushDetailsViewController" sender:self];
        }
    }
}

//- (IBAction)longPressRecognized:(id)sender {
//    NSLog(@"longPressRecognized");
//}

#pragma mark - SpotCellDelegate

- (void)longPressGestureRecognizeOnCell:(SWTableViewCell *)cell {
    if (!self.guideBook) {
        return;
    }
    NSIndexPath *indexPath;
    SPOT *spot;
    
    if (self.searchDisplayController.active) {
        indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
        if (indexPath) {
            spot = [self.fetchedSearchResultsController objectAtIndexPath:indexPath];
        }
    }
    else {
        indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath) {
            spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
    }
    
    
    if (spot) {
        isPushingDetailsView = YES;
        self.selectedSpot = spot;
        
        [self performSegueWithIdentifier:@"PushDetailsViewControllerXib" sender:self];
    }
    
}

//-(void)dealloc{
//    
//    [[Banner shared]hideMediumBanner];
//    
//}

#pragma mark - ScrollViewDelegate
//
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    
//  
//    for (id cell  in self.tableView.visibleCells) {
//            
//            if ([cell isKindOfClass:[SpotCell class]]) {
//                
//                SpotCell *spotCell = cell;
//                [spotCell addUtilityButton];
//            }
//        }
//    
//    
//    for (id cell  in self.searchDisplayController.searchResultsTableView.visibleCells) {
//        
//        if ([cell isKindOfClass:[SpotCell class]]) {
//            
//            SpotCell *spotCell = cell;
//            [spotCell addUtilityButton];
//        }
//    }
//
//}

@end
