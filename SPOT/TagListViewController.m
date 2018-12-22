//
//  TagListViewController.m
//  SPOT
//
//  Created by framgia on 8/8/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "TagListViewController.h"
#import "Tag.h"
#import "SWTableViewCell.h"
#import "SPOTListTableViewController.h"
#import "TagCell.h"

@interface TagListViewController () <NSFetchedResultsControllerDelegate, TagCellDelegate> {
    Tag *selectedTag;
    UIActivityIndicatorView *activityIndicator;
    BOOL isPushingDetailsView;
    BOOL shouldShowAds;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TagListViewController

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
    
    [self.searchNavigationBar setBarTintColor:[UIColor whiteColor]];
    
    
    // show indicator
//    activityIndicator = [UIActivityIndicatorView new];
//    activityIndicator.center = (CGPoint){self.view.frame.size.width/2, self.view.frame.size.height/2};
//    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//    [self.view addSubview:activityIndicator];
//    [activityIndicator startAnimating];
    
    self.fetchedResultsController = [Tag MR_fetchAllSortedBy:@"spot_count" ascending:NO withPredicate:nil groupBy:nil delegate:self];
    
}

- (void)dealloc {
    NSLog(@"Tag list died.");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    shouldShowAds = [[Banner shared] shouldShowAds];
    if (shouldShowAds) {
        [[Banner shared]showSmallBannerAboveToolbar];
    }
    [self reloadResultsTable];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    isPushingDetailsView = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[Banner shared]hideSmallBannerAboveToolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction) onAddButtonClicked:(id)sender
{
    if (self.searchBar.text.length==0) return;
    Tag *tag = [Tag MR_findFirstByAttribute:@"tag" withValue:self.searchBar.text];
    if (tag) return;
    tag = [Tag MR_createEntity];
    tag.tag = self.searchBar.text;
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    // save
    [magicalContext MR_saveOnlySelfAndWait];
    [self.searchBar setText:@""];
    [self searchBar:self.searchBar textDidChange:@""];
    
//    [self tableViewReloadData];
    
}

- (void)onBackButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)swipeRightRecognized:(id)sender {
    NSLog(@"swipeRightRecognized");
    //    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self.view endEditing:YES];
}

- (void)hideAllCellUtilityButtons {
    UITableView *tableView = self.tableView;
    for (NSInteger j = 0; j < [tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            if ([cell isKindOfClass:[SWTableViewCell class]]) {
                SWTableViewCell *swCell = (SWTableViewCell *)cell;
                [swCell hideUtilityButtonsAnimated:YES];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideAllCellUtilityButtons];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id <NSFetchedResultsSectionInfo> lastSection;
    lastSection = self.fetchedResultsController.sections.lastObject;

    // check if the last row is ads
    if(indexPath.section==self.fetchedResultsController.sections.count-1 && indexPath.row==[lastSection numberOfObjects]){
        // banner row
        return ADS_MARGIN_HEIGHT + SMALL_ADS_HEIGHT + MEDIUM_ADS_HEIGHT;
    }
    else return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultsController fetchedObjects] count] + (shouldShowAds ? 1 : 0);
//    id <NSFetchedResultsSectionInfo> sectionInfo;
//    sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
//    
//    // case not the last section
//    if(section<self.fetchedResultsController.sections.count-1){
//        
//        return [sectionInfo numberOfObjects];
//    }
//    // add ads in last section
//    else {
//        // case ads is avaiable, +1 row in last section
//        if (shouldShowAds) {
//            return [sectionInfo numberOfObjects]+1;
//        }
//        // case ads is unavaiable, 
//        else{
//            return [sectionInfo numberOfObjects];
//        }
//    }    
}
- (void)configureCell:(TagCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    // Add utility buttons
    
    cell.delegate = self;
    [cell addUtilityButton];
    
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.tagTextField setText:[NSString stringWithFormat:@"%@",[tag tag]]];
    
    [cell.spotCountLabel setText:[NSString stringWithFormat:@"%d",(int)[[tag spot] count]]];
    
    UIButton* doneButton = cell.doneButton;
    [doneButton setHidden:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // case last row of last section is ads
    if ((indexPath.section == self.fetchedResultsController.sections.count - 1) && (indexPath.row == [self.fetchedResultsController.sections.lastObject numberOfObjects])) {
        UITableViewCell *cell;
        static NSString *cellBannerIdentifier = @"Cell_Banner";
        cell = [tableView dequeueReusableCellWithIdentifier:cellBannerIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellBannerIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [[Banner shared] showMediumBannerViewInView:cell];
        return cell;
    }
    
    static NSString *CellIdentifier = @"Tag Cell";
    TagCell *cell;
    cell = (TagCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    if (cell == nil) {
        cell = [[TagCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath inTableView:tableView];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // click margin of banner
    if ((indexPath.section == self.fetchedResultsController.sections.count - 1) && (indexPath.row == [self.fetchedResultsController.sections.lastObject numberOfObjects])) {
        NSLog(@"click banner");
        return;
    }
    if (isPushingDetailsView) {
        return;
    }
    isPushingDetailsView = YES;
    [self.view endEditing:YES];
    [self hideAllCellUtilityButtons];
    [self performSelector:@selector(pushDetails) withObject:nil afterDelay:0.05];
    
}

- (void)pushDetails {
     [self performSegueWithIdentifier:@"PushSpotListTableViewController" sender:self];
}



-(void) reloadResultsTable {
//    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"tag contains[c] %@", searchText];
    self.fetchedResultsController = [Tag MR_fetchAllSortedBy:@"spot_count" ascending:NO withPredicate:searchText.length>0?resultPredicate:nil groupBy:nil delegate:self];
    
    [self performSelectorOnMainThread:@selector(reloadResultsTable) withObject:nil waitUntilDone:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"PushSpotListTableViewController"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Tag *tag;
        tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
        // Get reference to the destination view controller
        SPOTListTableViewController *spotListTableViewController = [segue destinationViewController];
        
        [spotListTableViewController setFilterTag:tag.tag];
        
        // case transition from find spot by tag of guidebook
        if (self.guideBook) {
            [spotListTableViewController setGuideBook:self.guideBook];
            [spotListTableViewController setIndexPathForInsertingIntoGuideBook:self.indexPathForInsertingIntoGuideBook];
        }
    }
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    NSLog(@"controllerWillChangeContent");
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSLog(@"didChangeObject");
    UITableView *tableView;
    tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(TagCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath inTableView:tableView];
            break;
            
        case NSFetchedResultsChangeMove:
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
    tableView = self.tableView;
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
}

#pragma mark - SWTableViewCellDelegate, TagCellDelegate

- (void)tagCellDidEndEditing:(TagCell *)tagCell {
    Tag *tag = selectedTag;
    NSString *tagName = tagCell.tagTextField.text;
    if ([Tag MR_findFirstByAttribute:@"tag" withValue:tagName])
    {
        NSLog(@"tag %@ already exist", tagName);
        tagCell.tagTextField.text = tag.tag;
    }
    else {
        tag.tag = tagName;
        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
        // save
        [magicalContext MR_saveOnlySelfAndWait];
    }
    
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:cellIndexPath];
    selectedTag = tag;
    
    switch (index) {
        case 0:
        {
            // Edit button is pressed
            
            [cell hideUtilityButtonsAnimated:NO];
            
            TagCell *tagCell = (TagCell *)cell;
            
            [tagCell beginEditing];
            
            break;
        }
            
        case 1:
        {
            // Delete button is pressed
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Tag"
                                                            message:@"Are you sure you want to delete?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Delete", nil];
            [alert show];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

#pragma mark - SearchDisplayControllerDelegate

//- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView{
//    
//    for (id cell  in self.searchDisplayController.searchResultsTableView.visibleCells) {
//        
//        if ([cell isKindOfClass:[TagCell class]]) {
//            
//            TagCell *tagCell = cell;
//            [tagCell addUtilityButton];
//        }
//    }
//}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) // Cancel Button
    {
        NSLog(@"Nothing to do here");
    }
    else
    {
        
        [selectedTag MR_deleteEntity];
        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
        // save
        [magicalContext MR_saveOnlySelfAndWait];
        
//        [self tableViewReloadData];
        
        NSLog(@"Delete the cell");
        
        
    }
}

//- (void)tableViewReloadData {
//    [self.fetchedResultsController performFetch:nil];
//    [self.tableView reloadData];
//}

#pragma mark - ScrollViewDelegate

//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    
//    
//    for (id cell  in self.tableView.visibleCells) {
//        
//        if ([cell isKindOfClass:[TagCell class]]) {
//            
//            TagCell *tagCell = cell;
//            [tagCell addUtilityButton];
//        }
//    }
//    
//    
//    for (id cell  in self.searchDisplayController.searchResultsTableView.visibleCells) {
//        
//        if ([cell isKindOfClass:[TagCell class]]) {
//            
//            TagCell *tagCell = cell;
//            [tagCell addUtilityButton];
//        }
//    }
//    
//}

@end
