//
//  GuideBookTableViewController.m
//  SPOT
//
//  Created by framgia on 7/9/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "GuideBookTableViewController.h"
#import "SPOT.h"
#import "GuideBook.h"
#import "GuideBookCell.h"
#import "SWTableViewCell.h"
#import "AppDelegate.h"
#import "CreateGuideBookViewController.h"
#import "GuideBookInfo.h"
#import "AppDelegate.h"
#import "SPDropBox.h"
#import "iCloud+spotiCloudAddition.h"
#import "Image.h"
#import "GuideBookInfoType.h"
#import "SPOT+Image.h"
#import "GuideBookDetailsXibViewController.h"
#import "AirdropService.h"


@interface GuideBookTableViewController ()  <NSFetchedResultsControllerDelegate>
{
    GuideBook *selectedGuideBook;
    BOOL isPushingDetailsView;
    BOOL shouldReloadTableView;
    BOOL isViewPresented;
    UIActivityIndicatorView *activityIndicator;
    BOOL isAllowClick;
    BOOL bannerIsShowed;
    BOOL shouldShowAds;
    NSIndexPath *selectedIndexPath;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedSearchResultsController;

@end

@implementation GuideBookTableViewController

AppDelegate* appDelegate;

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
    
    //    self.lastReloadDataDate = [NSDate date];
    
    [FontHelper setFontFamily:FONT_NAME forView:self.view andSubViews:YES];
    
    self.tableView.contentOffset = CGPointMake(0,  self.searchDisplayController.searchBar.frame.size.height);
    
    NSFetchedResultsController *fetchedResultsController = [GuideBook MR_fetchAllSortedBy:@"start_date" ascending:NO withPredicate:nil groupBy:nil delegate:self];
    self.fetchedResultsController = fetchedResultsController;
    
    
    shouldReloadTableView = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSendAirDropFinish) name:@"SaveAirDropFileFinish" object:nil];
}

- (void) handleSendAirDropFinish {
    shouldReloadTableView = YES;
    [self performSelectorOnMainThread:@selector(tableViewReloadData) withObject:nil waitUntilDone:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"GuideBook list died.");
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    bannerIsShowed = NO;
    [self.navigationController setNavigationBarHidden:YES];
    isAllowClick = YES;
    isViewPresented = YES;
    shouldShowAds = [[Banner shared] shouldShowAds];
    if (shouldShowAds) {
        [[Banner shared]showSmallBannerAboveToolbar];
    }
    //hide search bar
    //    self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
    
    //    self.tableView.contentOffset = CGPointMake(0, 20);
    
    //    NSLog(@"%@", appDelegate.guideBookTableLastUpdateDate);
    //    NSLog(@"%@", self.lastReloadDataDate);
    //
    //    // skip reload at first time
    //    if (appDelegate.guideBookTableLastUpdateDate && ([appDelegate.guideBookTableLastUpdateDate compare:self.lastReloadDataDate] == NSOrderedDescending)) {
    //        [self tableViewReloadData];
    //    }
    
    
    [self tableViewReloadData];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [[Banner shared]hideSmallBannerAboveToolbar];
    
    shouldReloadTableView = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    if (self.fetchedResultsController) {
//        return;
//    }
//    
//    self.fetchedResultsController = [GuideBook MR_fetchAllSortedBy:@"start_date" ascending:NO withPredicate:nil groupBy:nil delegate:self];
//    
//    [self.tableView reloadData];
//    
//    
//    [activityIndicator stopAnimating];
    
//    for (id cell  in self.tableView.visibleCells) {
//        
//        if ([cell isKindOfClass:[GuideBookCell class]]) {
//            
//            GuideBookCell *guideBookCell = cell;
//            [guideBookCell addUtilityButton];
//        }
//    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    isPushingDetailsView = NO;
    isViewPresented = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)onBackButtonClicked:(id)sender {
    if (isAllowClick) {
        isAllowClick = NO;
        [self popSelf];
        //    [self performSelector:@selector(popSelf) withObject:nil afterDelay:0.1];
    }
    else {
        isAllowClick = YES;
    }
}

- (void)popSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onAddButtonClicked:(id)sender {
    if (isAllowClick) {
        isAllowClick = NO;
        //    shouldReloadViewData = YES;
        [self createGuideBook];
        //    [self performSelector:@selector(createGuideBook) withObject:nil afterDelay:0.1];
    }
    else {
        isAllowClick = YES;
    }
}

- (void)createGuideBook {
    selectedGuideBook = [GuideBook MR_createEntity];
    
    [self performSegueWithIdentifier:@"PushGuideBookDetailsViewControllerNoAnimation" sender:self];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self performSegueWithIdentifier:@"PushCreateGuideBookViewControllerForEditingNoAnimation" sender:self];
    }
}

- (void)onSearchButtonClicked:(id)sender {
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.searchDisplayController.searchBar becomeFirstResponder];
}

- (void)hideAllCellUtilityButtons {
    UITableView *tableView = self.tableView;
    for (NSInteger j = 0; j < [tableView numberOfSections]; ++j)
    {
        //        for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
        //        {
        //            SWTableViewCell *swCell = (SWTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
        //            [swCell hideUtilityButtonsAnimated:YES];
        //
        //        }
        
        {
            if (j<[tableView numberOfSections]-1) {
                for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
                {
                    SWTableViewCell *swCell = (SWTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                    [swCell hideUtilityButtonsAnimated:YES];
                    
                }
            }else{
                
                for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]-1; ++i)
                {
                    SWTableViewCell *swCell = (SWTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                    [swCell hideUtilityButtonsAnimated:YES];
                    
                }
            }
            
        }
        
    }
    
    
}

- (void)tableViewReloadData {
    NSLog(@"GUIDEBOOK LIST tableViewReloadData");
    
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
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideAllCellUtilityButtons];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return self.fetchedResultsController.sections.count;
    }
    else {
        return self.fetchedSearchResultsController.sections.count;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    id <NSFetchedResultsSectionInfo> sectionInfo;
    
    if (tableView == self.tableView){
        
        return [self.fetchedResultsController fetchedObjects].count + (shouldShowAds ? 1 : 0);
        
//        sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
//        
//        if(section<self.fetchedResultsController.sections.count-1){
//            
//            return [sectionInfo numberOfObjects];
//        }
//        
//        else{
//            
//            if (shouldShowAds) {
//                
//                bannerIsShowed = YES;
//                return [sectionInfo numberOfObjects]+1;
//            }
//            else{
//                
//                return [sectionInfo numberOfObjects];
//            }
//        }
    }
    else {
        
        return [self.fetchedSearchResultsController fetchedObjects].count + (shouldShowAds ? 1 : 0);
        
//        sectionInfo = [self.fetchedSearchResultsController.sections objectAtIndex:section];
//        if(section<self.fetchedSearchResultsController.sections.count-1){
//            
//            return [sectionInfo numberOfObjects];
//        }
//        else{
//            
//            if (shouldShowAds) {
//                
//                bannerIsShowed = YES;
//                return [sectionInfo numberOfObjects]+1;
//            }
//            else{
//                
//                return [sectionInfo numberOfObjects];
//            }
//        }
    }
}


-(NSUInteger)countAllObjectInSections:(NSArray*)sections{
    
    NSUInteger count = 0;
    
    for (id <NSFetchedResultsSectionInfo> sectionInfo in sections) {
        
        count += [sectionInfo numberOfObjects];
    }
    
    return count;
}

/*- (void)configUtilityCell:(GuideBook *)guideBook cell:(GuideBookCell *)cell
{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[UIImage imageNamed:@"Slice_icon_120"] selectedIcon:[UIImage imageNamed:@"Slice_icon_120"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[UIImage imageNamed:@"Slice_icon_128"] selectedIcon:[UIImage imageNamed:@"Slice_icon_128"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[UIImage imageNamed:@"Slice_icon_117"] selectedIcon:[UIImage imageNamed:@"Slice_icon_117"]];
    
    
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
}*/


- (void)configDisplayCell:(GuideBook *)guideBook cell:(GuideBookCell *)cell
{
    // Configure the cell...
    @autoreleasepool {
        [cell addUtilityButton];
        cell.delegate = self;
        
        cell.nameLabel.text = [StringHelpers isNilOrWhitespace:guideBook.guide_book_name] ? @"<No name>" : guideBook.guide_book_name;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        
        cell.dateLabel.text = [dateFormatter stringFromDate:guideBook.start_date];
        
        NSString *imageFileName = nil;
        
        if (guideBook.start_spot.image.count > 0)
        {
            imageFileName = [guideBook.start_spot firstImageFileName];
            
        }
        else {
            
            NSArray *guideBookInfoArray = [guideBook.guide_book_info allObjects];
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
            
            NSArray *sortedGuideBookInfoArray= [guideBookInfoArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            for (GuideBookInfo *info in sortedGuideBookInfoArray) {
                if (info.info_type.intValue == GuideBookInfoTypeSpot && info.spot.image.count > 0) {
                    
                    imageFileName = [info.spot firstImageFileName];
                    break;
                }
            }
        }
        
        __weak UIImageView *imageView = cell.spotImageView;
        imageView.clipsToBounds = YES;
        
        if (imageFileName) {
            [appDelegate.detailsImageCacher getImageByFileName:imageFileName completionHandler:^(BOOL success, UIImage *image) {
                
                if (success) {
                    UIImageView *innerImageView = imageView;
                    innerImageView.image = image;
                    image = nil;
                }
            }];
        }
        
        if (!imageFileName) {
            [cell.spotImageView setHidden:YES];
            [cell.contentView.constraints[0] setConstant:15];
            [cell.nameLabel.constraints[1] setConstant:297];
        }
        else {
            [cell.spotImageView setHidden:NO];
            [cell.contentView.constraints[0] setConstant:65];
            [cell.nameLabel.constraints[1] setConstant:247];
        }

    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> lastSection;
    
    if (tableView == self.tableView){
        
        lastSection = self.fetchedResultsController.sections.lastObject;
    }
    else {
        lastSection = self.fetchedSearchResultsController.sections.lastObject;
    }
    
    if((tableView == self.tableView && indexPath.section==self.fetchedResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects])){
        
        return ADS_MARGIN_HEIGHT + MEDIUM_ADS_HEIGHT + SMALL_ADS_HEIGHT;
        //banner
    }
    else if (tableView != self.tableView && indexPath.section==self.fetchedSearchResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects]){
        
        if ([self countAllObjectInSections:self.fetchedSearchResultsController.sections]>=2) {
            
            return ADS_MARGIN_HEIGHT + MEDIUM_ADS_HEIGHT + SMALL_ADS_HEIGHT;
        }
        else{
            
            return MEDIUM_ADS_HEIGHT + ADS_MARGIN_HEIGHT;
        }
    }
    else return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> lastSection;
    
    if (tableView == self.tableView){
        
        lastSection = self.fetchedResultsController.sections.lastObject;
    }
    else {
        lastSection = self.fetchedSearchResultsController.sections.lastObject;
    }
    
    if(!((tableView == self.tableView && indexPath.section==self.fetchedResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects])|| (tableView != self.tableView && indexPath.section==self.fetchedSearchResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects]))){
        @autoreleasepool {
            GuideBook *guideBook = nil;
            GuideBookCell *cell;
            if (tableView == self.tableView) {
                guideBook = [self.fetchedResultsController objectAtIndexPath:indexPath];
                cell = [tableView dequeueReusableCellWithIdentifier:@"GuideBookCell" forIndexPath:indexPath];
            }
            else  {
                guideBook = [self.fetchedSearchResultsController objectAtIndexPath:indexPath];
                
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"GuideBookCell"];
            }
            
            if (cell == nil) {
                cell = [[GuideBookCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"GuideBookCell"];
                cell.textLabel.text = guideBook.guide_book_name;
                return cell;
            }
            
            [self configDisplayCell:guideBook cell:cell];
            
            
            return cell;
        }
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isAllowClick) {

        if (isPushingDetailsView) {
            return;
        }
        isAllowClick = NO;
        
        selectedIndexPath = indexPath;
        
        @autoreleasepool {
            id <NSFetchedResultsSectionInfo> lastSection;
            
            if (tableView == self.tableView){
                
                lastSection = self.fetchedResultsController.sections.lastObject;
            }
            else {
                lastSection = self.fetchedSearchResultsController.sections.lastObject;
            }
            
            if(!((tableView == self.tableView && indexPath.section==self.fetchedResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects])|| (tableView != self.tableView && indexPath.section==self.fetchedSearchResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects]))){
                
                isPushingDetailsView = YES;
                if (tableView == self.tableView) {
                    selectedGuideBook = [self.fetchedResultsController objectAtIndexPath:indexPath];
                }
                else {
                    selectedGuideBook = [self.fetchedSearchResultsController objectAtIndexPath:indexPath];
                }
                [self hideAllCellUtilityButtons];
                //    [self viewGuideBookDetails];
                [self performSelector:@selector(viewGuideBookDetails) withObject:nil afterDelay:0.05];
            }
            else
            {
                NSLog(@"click banner");
                isAllowClick = YES;
            }
        }
        
    }
    else {
        isAllowClick = YES;
    }
}

- (void)viewGuideBookDetails {
    
    [self performSegueWithIdentifier:@"PushGuideBookDetailsXibViewController" sender:self];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushGuideBookDetailsXibViewController"]){
        
        GuideBookDetailsXibViewController *guideBookDetailsViewController = segue.destinationViewController;
        guideBookDetailsViewController.guideBook = selectedGuideBook;
        guideBookDetailsViewController.guideBooks = [self.searchDisplayController isActive]
        ? [self.fetchedSearchResultsController fetchedObjects]
        : [self.fetchedResultsController fetchedObjects];
    }
    else if ([segue.identifier isEqualToString:@"PushGuideBookDetailsViewControllerNoAnimation"]) {
        GuideBookDetailsXibViewController *guideBookDetailsViewController = segue.destinationViewController;
        guideBookDetailsViewController.guideBook = selectedGuideBook;
    }
    else if ([segue.identifier isEqualToString:@"PushCreateGuideBookViewControllerForEditingNoAnimation"]){
        CreateGuideBookViewController *createGuideBookViewController = segue.destinationViewController;
        createGuideBookViewController.guideBook = selectedGuideBook;
    }
    else if ([segue.identifier isEqualToString:@"PushCreateGuideBookViewControllerForEditing"]){
        CreateGuideBookViewController *createGuideBookViewController = segue.destinationViewController;
        createGuideBookViewController.guideBook = selectedGuideBook;
    }
}



#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    NSLog(@"controllerDidChangeContent");
    
//    shouldReloadTableView = YES;
//    
//    if (isViewPresented) {
//        if ((controller == self.fetchedResultsController && !self.searchDisplayController.active) || (controller == self.fetchedSearchResultsController && self.searchDisplayController.active)) {
//            NSLog(@"controllerDidChangeContent and reload table view");
//            [self tableViewReloadData];
//        }
//    }
}

/*
 
 - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
 // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
 NSLog(@"controllerWillChangeContent");
 if (controller == self.fetchedResultsController) {
 [self.tableView beginUpdates];    }
 else {
 [self.searchDisplayController.searchResultsTableView beginUpdates];
 }
 
 
 }
 
 
 - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
 
 NSLog(@"didChangeObject");
 UITableView *tableView;
 if (controller == self.fetchedResultsController){
 tableView = self.tableView;
 } else {
 tableView = self.searchDisplayController.searchResultsTableView;
 }
 
 
 switch(type) {
 
 case NSFetchedResultsChangeInsert:
 NSLog(@"NSFetchedResultsChangeInsert");
 [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
 break;
 
 case NSFetchedResultsChangeDelete:
 NSLog(@"NSFetchedResultsChangeDelete");
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 break;
 
 case NSFetchedResultsChangeUpdate:
 NSLog(@"NSFetchedResultsChangeUpdate");
 
 //            [self configCell:[self.fetchedResultsController objectAtIndexPath:indexPath] cell:(GuideBookCell *)[tableView cellForRowAtIndexPath:indexPath]];
 
 [self configCell:[controller objectAtIndexPath:indexPath] cell:(GuideBookCell *)[tableView cellForRowAtIndexPath:indexPath]];
 break;
 
 case NSFetchedResultsChangeMove:
 NSLog(@"NSFetchedResultsChangeMove");
 [tableView deleteRowsAtIndexPaths:[NSArray
 arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 [tableView insertRowsAtIndexPaths:[NSArray
 arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
 break;
 }
 }
 
 
 - (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
 
 NSLog(@"didChangeSection");
 UITableView *tableView;
 if (controller == self.fetchedResultsController){
 tableView = self.tableView;
 } else {
 tableView = self.searchDisplayController.searchResultsTableView;
 }
 switch(type) {
 
 case NSFetchedResultsChangeInsert:
 [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
 break;
 
 case NSFetchedResultsChangeDelete:
 [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
 break;
 }
 }
 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
 NSLog(@"controllerDidChangeContent");
 [self.tableView endUpdates];
 [self.searchDisplayController.searchResultsTableView endUpdates];
 }
 
 */



#pragma mark - SearchDisplayControllerDelegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate;
    
    resultPredicate = [NSPredicate predicateWithFormat:@"guide_book_name contains[c] %@", searchText];
    
    NSFetchedResultsController *fetchedSearchResultsController = [GuideBook MR_fetchAllSortedBy:@"start_date" ascending:NO withPredicate:resultPredicate groupBy:nil delegate:self];
    self.fetchedSearchResultsController = fetchedSearchResultsController;
    
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
    //    _isSearching = YES;
    [self hideAllCellUtilityButtons];
    
}

//- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
//{
//    _isSearching = NO;
//}


#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    if (isAllowClick) {
        isAllowClick = NO;
        
        GuideBook *guideBook;
        
        if ([self.searchDisplayController isActive]) {
            selectedIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
            guideBook = [self.fetchedSearchResultsController objectAtIndexPath:selectedIndexPath];
        }
        else {
            selectedIndexPath = [self.tableView indexPathForCell:cell];
            guideBook = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        }
        
        if (guideBook != nil) {
            selectedGuideBook = guideBook;
            
            switch (index) {
                    
                case 0: // Delete
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete GUIDE BOOK"
                                                                    message:@"Are you sure you want to delete?"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@"Delete", nil];
                    [alert show];
                    
                    break;
                }
                case 1: // Edit
                {
                    [self performSegueWithIdentifier:@"PushCreateGuideBookViewControllerForEditing" sender:self];
                    break;
                }
                case 2: // AirDrop
                {
                    [self sendAirdropWithGuideBook:guideBook];
                }
                default:
                    break;
            }
            
        }
        [cell hideUtilityButtonsAnimated:NO];
        
    }
    else {
        isAllowClick = YES;
    }
    
   
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
        isAllowClick = YES;
    }];
}



- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) // Cancel Button
    {
        NSLog(@"Nothing to do here");
    }
    else
    {
        
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSError *errorDeleteLocal;
        
        if([[NSUserDefaults standardUserDefaults]boolForKey:@"syncDropbox"]){
            
            [[SPDropBox sharedInstance]deleteFileAtPath:[NSString stringWithFormat:@"/%@",[GUIDE_BOOK_DATA_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.spotGuidebookData",selectedGuideBook.uuid]]]];
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[GUIDE_BOOK_DATA_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.spotGuidebookData",selectedGuideBook.uuid]]]);
            
        }
        else if([[NSUserDefaults standardUserDefaults]boolForKey:@"synciCloud"]){
            
            [[iCloud sharedCloud].remoteFiles removeObjectForKey:[selectedGuideBook.uuid stringByAppendingPathExtension:@"spotGuidebookData"]];
            
            [[iCloud sharedCloud].localFiles removeObjectForKey:[selectedGuideBook.uuid stringByAppendingPathExtension:@"spotGuidebookData"]];
            
            [[iCloud sharedCloud]deleteDocumentWithName:[selectedGuideBook.uuid stringByAppendingPathExtension:@"spotGuidebookData"] completion:^(NSError *error) {
                
                if(error){
                    
                    NSLog(@"Could not delete file oniCloud -:%@ ",[error localizedDescription]);
                }
            }];
            
        }
        
        if (selectedGuideBook.uuid) {
            
            [[NSFileManager defaultManager]removeItemAtPath:[[appDelegate applicationDocumentsDirectoryForGuideBookData] stringByAppendingPathComponent:[selectedGuideBook.uuid stringByAppendingPathExtension:@"spotGuidebookData"]] error:&errorDeleteLocal];
        }
        
        
        [self deleteGuideBook:selectedGuideBook];
    }
    isAllowClick = YES;
}

- (void)deleteGuideBook:(GuideBook *)guideBook {
    
    for (GuideBookInfo *guideBookInfo in guideBook.guide_book_info) {
        [guideBookInfo MR_deleteEntity];
    }
    
    [guideBook MR_deleteEntity];
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    [magicalContext MR_saveOnlySelfAndWait];
    
    NSLog(@"Delete guide book");
    
//    [self.fetchedResultsController performFetch:nil];
//    [self.fetchedSearchResultsController performFetch:nil];
//    
//    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    shouldReloadTableView = YES;
    [self tableViewReloadData];
}

#pragma mark - ScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
//    for (id cell  in self.tableView.visibleCells) {
//        
//        if ([cell isKindOfClass:[GuideBookCell class]]) {
//            
//            GuideBookCell *guideBookCell = cell;
//            [guideBookCell addUtilityButton];
//        }
//    }
//    
//    
//    for (id cell  in self.searchDisplayController.searchResultsTableView.visibleCells) {
//        
//        if ([cell isKindOfClass:[GuideBookCell class]]) {
//            
//            GuideBookCell *guideBookCell = cell;
//            [guideBookCell addUtilityButton];
//        }
//    }
    
}



@end
