//
//  StartSpotRegistrationViewController.m
//  SPOT
//
//  Created by Truong Anh Tuan on 9/10/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "StartSpotRegistrationViewController.h"
#import "SPOT.h"
#import "Foursquare2.h"
#import "AppDelegate.h"
#import "BlackActivityIndicatorView.h"

@interface StartSpotRegistrationViewController () <NSFetchedResultsControllerDelegate, UISearchBarDelegate>
{
    BlackActivityIndicatorView *activityIndicator;
}

@property (strong, nonatomic) NSArray *startSpotSearchResultsFromDatabase;
@property (strong, nonatomic) NSArray *startSpotSearchResultsFromFourSquare;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSOperation *searchOperation;
@property (assign, nonatomic) BOOL isAllowSearch;
@end



@implementation StartSpotRegistrationViewController

AppDelegate *appDelegate;

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
    
    activityIndicator = [[BlackActivityIndicatorView alloc] initWithTopDistance:150];
    [self.view addSubview:activityIndicator];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"spot_name != ''"];
    
    self.fetchedResultsController = [SPOT MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:predicate groupBy:nil delegate:self];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)dealloc {
    NSLog(@"GuideBook start spot died.");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.toolbar.hidden = YES;
    self.isAllowSearch = YES;
//    [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setToolbarHidden:NO];
    self.navigationController.toolbar.hidden = NO;
}

- (IBAction)onBackButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.startSpotSearchResultsFromDatabase == nil) {
        return 1;
    }
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    if (self.startSpotSearchResultsFromDatabase == nil) {
        sectionName = @"";
    }
    else {
        switch (section) {
            case 0:
                sectionName = @"SPOT";
                break;
            case 1:
            default:
                sectionName = @"Foursquare";
                break;
        }
    }
    return sectionName;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    UILabel *myLabel = [[UILabel alloc] init];
//    myLabel.frame = CGRectMake(20, 8, 320, 20);
//    myLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SMALL_SIZE];
//    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
//    
//    UIView *headerView = [[UIView alloc] init];
//    [headerView addSubview:myLabel];
//    
//    return headerView;
//}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.startSpotSearchResultsFromDatabase == nil){
        return [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
    }
    else {
        switch (section) {
            case 0:
                return [self.startSpotSearchResultsFromDatabase count];
            default:
                return [self.startSpotSearchResultsFromFourSquare count];
        }
     
    }
    
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPOT *spot = nil;
    if (self.startSpotSearchResultsFromDatabase == nil) {
        spot = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    else {
        int row = indexPath.row;
        if (row < self.startSpotSearchResultsFromDatabase.count) {
            spot = [self.startSpotSearchResultsFromDatabase objectAtIndex:indexPath.row];
        }
        
    }
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SpotCell"];
    
    if (spot != nil) {
        cell.textLabel.text = spot.spot_name;
        cell.detailTextLabel.text = spot.address;
    }
    else {
        // this row's data is from foursquare
        NSDictionary *venue = [self.startSpotSearchResultsFromFourSquare objectAtIndex:(indexPath.row - self.startSpotSearchResultsFromDatabase.count)];
        cell.textLabel.text = venue[@"name"];
        

        NSString *address = venue[@"location"][@"address"];
        address = address?address:@"";
        cell.detailTextLabel.text = address;
        

    }
    
    cell.textLabel.font = appDelegate.normalFont;
    cell.detailTextLabel.font = appDelegate.smallFont;
    
    // Configure the cell...

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.startSpotSearchResultsFromDatabase == nil) {
        [self.delegate didSelectStartSpot:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
    else {
        if (indexPath.row < self.startSpotSearchResultsFromDatabase.count) {
            [self.delegate didSelectStartSpot:[self.startSpotSearchResultsFromDatabase objectAtIndex:indexPath.row]];
        }
        else {
            NSDictionary *venue = [self.startSpotSearchResultsFromFourSquare objectAtIndex:(indexPath.row - self.startSpotSearchResultsFromDatabase.count)];
            NSLog(@"%@", venue);
            NSString *name = venue[@"name"];
            double lat = [venue[@"location"][@"lat"] doubleValue];
            double lng = [venue[@"location"][@"lng"] doubleValue];
            [self.delegate didSelectFoursquareVenueWithName:name lat:lat lng:lng];
            
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - SearchDisplayControllerDelegate

- (void)searchWithKeywords:(NSString *)searchText
{
//    NSLog(@"searchWithKeywords");
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"spot_name contains[c] %@", searchText];
    self.isAllowSearch = NO;
    
    self.startSpotSearchResultsFromDatabase = [SPOT MR_findAllSortedBy:@"date" ascending:NO withPredicate:resultPredicate];
    
    NSString *searchKeywords = searchText;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"spot_name CONTAINS[c] %@",searchKeywords];
    self.startSpotSearchResultsFromDatabase = [SPOT MR_findAllWithPredicate:predicate];
    
    [self reloadResultsTable];
    
    NSLog(@"StartSpotRegistration searchWithKeywords :MainThread:%@ CurrentThread:%@",[NSThread mainThread],[NSThread currentThread]);
    
    [activityIndicator startAnimating];
    
    // search spot from foursquare
    [self.searchOperation cancel];
    
    __weak StartSpotRegistrationViewController *blocksafeSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        blocksafeSelf.searchOperation = [Foursquare2 venueSearchNearLocation:@"" query:searchKeywords limit:nil intent:intentGlobal radius:@(500) categoryId:nil callback:^(BOOL success, id result){
            
            NSLog(@"venueSearchNearLocation callback");
            [activityIndicator stopAnimating];
            
            blocksafeSelf.isAllowSearch = YES;
            if (success) {
                //parse here
                NSLog(@"success");
                blocksafeSelf.startSpotSearchResultsFromFourSquare = [[(NSDictionary*)result objectForKey:@"response"] objectForKey:@"venues"];
                //[self parseSearchVenuesResultsDictionary:(NSDictionary*)result];
//                if (blocksafeSelf.startSpotSearchResultsFromFourSquare && [self.startSpotSearchResultsFromFourSquare count]>0)
//                {
//                    [blocksafeSelf performSelectorOnMainThread:@selector(reloadResultsTable) withObject:nil waitUntilDone:YES];
//                }
            }
            
            [blocksafeSelf performSelectorOnMainThread:@selector(reloadResultsTable) withObject:nil waitUntilDone:YES];
        }];
        
    });
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
//    NSLog(@"filterContentForSearchText");
//    [self search:searchText];

}

- (void)reloadResultsTable
{
    [self.tableView reloadData];
//    [self.searchDisplayController.searchResultsTableView reloadData];
}
//
//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
////    NSLog(@"searchDisplayController");
//    [self filterContentForSearchText:searchString
//                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                      objectAtIndex:[self.searchDisplayController.searchBar
//                                                     selectedScopeButtonIndex]]];
//    
//    return YES;
//}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"search text: %@", [self.searchBar text]);
//    NSLog(@"searchBarSearchButtonClicked");
    if (self.isAllowSearch) {
        [self searchWithKeywords:[self.searchBar text]];
    } else {
        NSLog(@"can not click many time");
    }

}

@end
