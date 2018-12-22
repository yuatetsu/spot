//
//  TrafficRegisterationViewController.m
//  SPOT
//
//  Created by framgia on 7/21/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "TrafficRegisterationViewController.h"
#import "AppDelegate.h"
#import "Foursquare2.h"
#import "LPGoogleFunctions.h"
#import <CoreLocation/CoreLocation.h>
#import "TrafficListViewController.h"
#import "BlackActivityIndicatorView.h"

@interface TrafficRegisterationViewController () <UIPickerViewDataSource, UIPickerViewDelegate, LPGoogleFunctionsDelegate, CLLocationManagerDelegate, TrafficListViewControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    
}
@property (strong, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) NSArray *searchResults;

@property (strong, nonatomic) NSArray *searchResultsFromFourSquare;
@property (strong, nonatomic) NSArray *searchResultsFromGooglePlace;
@property (nonatomic, strong) LPGoogleFunctions *googleFunctions;
@property (strong, nonatomic) NSOperation *searchOperation;
@property (weak, nonatomic) IBOutlet UITableView *initialTableResult;
@property (assign, nonatomic) BOOL isAllowSearch;

@property (nonatomic) BOOL isAllowClick;
@property (nonatomic) BlackActivityIndicatorView *activityIndicator;

@end

@implementation TrafficRegisterationViewController

AppDelegate *appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isAllowSearch = YES;
	// Do any additional setup after loading the view.
    self.pickerData = appDelegate.transportationList;
    self.searchResults = nil;
    // Connect data
    self.transportationPicker.dataSource = self;
    self.transportationPicker.delegate = self;
    
    [self.transportationPicker selectRow:[self.spot.traffic integerValue] inComponent:0 animated:NO];
    if (self.spot.start_spot_name.length > 0) {
        self.startSpotNameLabel.text = self.spot.start_spot_name;
    }
    [self.initialTableResult setHidden:YES];
    
    [FontHelper setFontFamily:FONT_NAME forView:self.view andSubViews:YES];
//    
//    self.cancelButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_NORMAL_SIZE];
    
    BlackActivityIndicatorView *activityIndicator = [[BlackActivityIndicatorView alloc] initWithTopDistance:150];
    
    self.activityIndicator = activityIndicator;
    [self.view addSubview:self.activityIndicator];
}

- (void)dealloc {
    self.pickerData = nil;
    self.searchResults = nil;
    self.searchResultsFromFourSquare = nil;
    self.searchResultsFromGooglePlace = nil;
    self.googleFunctions = nil;
    self.searchOperation = nil;
    
    NSLog(@"Traffic died.");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.searchOperation) {
        [self.searchOperation cancel];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isAllowClick = YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"didSelectRow:%d", (int)row);
    NSLog(@"selected traffic: %@",[self.pickerData objectAtIndex:row]);
    self.spot.traffic = [NSNumber numberWithInteger:row];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) onDoneButtonClicked:(id)sender
{
    if (self.isAllowClick) {
        NSLog(@"TRAFFIC onDoneButtonClicked");
        self.isAllowClick = NO;
        self.navigationItem.rightBarButtonItem.enabled = false;

        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
        
        __weak SPOT *spot = self.spot;
        [magicalContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            SPOT *innerSpot = spot;
            if (success) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    AppDelegate *delegateApp = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [delegateApp saveSpotToXMLForSync:innerSpot];
                });
            }
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        self.isAllowClick = YES;
    }
}

- (IBAction)onBackButtonClicked:(id)sender {
    if (self.isAllowClick) {
        self.isAllowClick = NO;

        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        self.isAllowClick = YES;
    }
}

- (void)selectTraffic {
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView && self.searchResults) {
        return [self.searchResults count] + [self.searchResultsFromFourSquare count] + [self.searchResultsFromGooglePlace count];
    } else if(tableView == self.initialTableResult) {
        return [self.initiateSearchResultArray count];
    } else {
        return 0;
    }
//    if (self.searchResults || self.searchResultsFromFourSquare || self.searchResultsFromGooglePlace) {
//        NSLog(@"return thu 1 %lu", [self.searchResults count] + [self.searchResultsFromFourSquare count] + [self.searchResultsFromGooglePlace count]);
//        return [self.searchResults count] + [self.searchResultsFromFourSquare count] + [self.searchResultsFromGooglePlace count];
//    } else if (self.initiateSearchResultArray) {
//        NSLog(@"return thu 2 %lu", (unsigned long)[self.initiateSearchResultArray count]);
//        return [self.initiateSearchResultArray count];
//    } else {
//        NSLog(@"return thu 3 0");
//        return 0;
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    SPOT *spot = nil;
    if (self.searchResultsFromFourSquare || self.searchResultsFromGooglePlace || self.searchResults) {
        if (indexPath.row < [self.searchResults count]) {
            spot = [self.searchResults objectAtIndex:indexPath.row];
            cell.textLabel.text = spot.spot_name;
            cell.detailTextLabel.text = spot.spot_description;
        }else if (indexPath.row >= [self.searchResults count]) {
            if (self.searchResultsFromGooglePlace && self.searchResultsFromGooglePlace.count > (indexPath.row - [self.searchResults count])) {
                LPPlaceDetails *placeDetails = (LPPlaceDetails *)[self.searchResultsFromGooglePlace objectAtIndex:(indexPath.row - [self.searchResults count])];
                cell.textLabel.text = placeDetails.name;
                NSString *address = placeDetails.formattedAddress;
                address = address?address:@"";
                cell.detailTextLabel.text = address;
            }else if (self.searchResultsFromFourSquare && self.searchResultsFromFourSquare.count > indexPath.row - [self.searchResults count]) { // search result from foursquare
                NSDictionary *venue = [self.searchResultsFromFourSquare objectAtIndex:(indexPath.row - [self.searchResults count])];
                cell.textLabel.text = venue[@"name"];
                cell.detailTextLabel.text = venue[@"location"][@"address"];
            }
        }
    }else {
        if (self.initiateSearchResultArray && self.initiateSearchResultArray.count > indexPath.row) {
            NSDictionary *venue = [self.initiateSearchResultArray objectAtIndex:(indexPath.row)];
            cell.textLabel.text = venue[@"name"];
            cell.detailTextLabel.text = venue[@"location"][@"address"];
        }
    }
    
    cell.textLabel.font = appDelegate.normalFont;
    cell.detailTextLabel.font = appDelegate.smallFont;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(!self.cancelButton.hidden){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        if (indexPath.row < [self.searchResults count]) {
            //        self.spot.start_spot = [self.searchResults objectAtIndex:indexPath.row];
            SPOT *resultSpot = [self.searchResults objectAtIndex:indexPath.row];
            self.spot.start_spot_name = resultSpot.spot_name;
            self.spot.start_spot_lat = resultSpot.lat;
            self.spot.start_spot_lng = resultSpot.lng;
            NSLog(@"##using local data: %@ %@ %@##", self.spot.start_spot_name, self.spot.start_spot_lat, self.spot.start_spot_lng);
        } else if (self.searchResultsFromFourSquare && self.searchResultsFromFourSquare.count > (indexPath.row - [self.searchResults count])) {
            NSDictionary *venue = [self.searchResultsFromFourSquare objectAtIndex:(indexPath.row - [self.searchResults count])];
            self.spot.start_spot_name = venue[@"name"];
            self.spot.start_spot_lat = venue[@"location"][@"lat"];
            self.spot.start_spot_lng = venue[@"location"][@"lng"];
            NSLog(@"##using foursquare api: %@ %@ %@##", self.spot.start_spot_name, self.spot.start_spot_lat, self.spot.start_spot_lng);
        } else if (self.searchResultsFromGooglePlace && self.searchResultsFromGooglePlace.count > (indexPath.row - [self.searchResults count])) {
            LPPlaceDetails *placeDetails = (LPPlaceDetails *)[self.searchResultsFromGooglePlace objectAtIndex:(indexPath.row - [self.searchResults count])];
            self.spot.start_spot_name = placeDetails.name;
            self.spot.start_spot_lat = [NSNumber numberWithDouble:placeDetails.geometry.location.latitude];
            self.spot.start_spot_lng = [NSNumber numberWithDouble:placeDetails.geometry.location.longitude];
            NSLog(@"##using google api: %@ %@ %@##", self.spot.start_spot_name, self.spot.start_spot_lat, self.spot.start_spot_lng);
        }
        
        self.startSpotNameLabel.text = self.spot.start_spot_name;
    } else if (tableView == self.initialTableResult){
        NSDictionary *venue = [self.initiateSearchResultArray objectAtIndex:indexPath.row];
        self.spot.start_spot_name = venue[@"name"];
        self.spot.start_spot_lat = venue[@"location"][@"lat"];
        self.spot.start_spot_lng = venue[@"location"][@"lng"];
        self.startSpotNameLabel.text = self.spot.start_spot_name;
    }
    
    [self onCancelButtonClicked:nil];
}

-(void) reloadResultsTable {
    [self.initialTableResult reloadData];
//    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self.view endEditing:YES];
}


//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
//{
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"spot_name contains[c] %@", searchText];
//    //searchResults = [spotArray filteredArrayUsingPredicate:resultPredicate];
//    self.searchResults = [SPOT MR_findAllWithPredicate:resultPredicate];
//    
//    self.searchResultsFromFourSquare = nil;
//    self.searchResultsFromGooglePlace = nil;
//    
////    [self performSelectorOnMainThread:@selector(reloadResultsTable) withObject:nil waitUntilDone:YES];
//    
////    [self reloadResultsTable];
//    
//    [activityIndicator startAnimating];
//    self.isAllowSearch = NO;
//    __weak TrafficRegisterationViewController *blocksafeSelf = self;
//    
//    [self.searchOperation cancel];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        blocksafeSelf.searchOperation = [Foursquare2 venueSearchNearByLatitude:@([AppSettings latitude]) longitude:@([AppSettings longitude]) query:searchText limit:@(50) intent: intentBrowse radius:@(100000) categoryId:nil callback:^(BOOL success, id result){
//            NSLog(@"venueSearchNearLocation callback");
//            
//            if (success) {
//                //parse here
//                NSLog(@"success");
//                
//                blocksafeSelf.searchResultsFromGooglePlace = nil;
//                blocksafeSelf.searchResultsFromFourSquare = [[(NSDictionary*)result objectForKey:@"response"] objectForKey:@"venues"];
//                //[self parseSearchVenuesResultsDictionary:(NSDictionary*)result];
//                if (blocksafeSelf.searchResultsFromFourSquare && [blocksafeSelf.searchResultsFromFourSquare count]>0)
//                {
//                    [blocksafeSelf performSelectorOnMainThread:@selector(reloadResultsTable) withObject:nil waitUntilDone:YES];
//                }
//                blocksafeSelf.isAllowSearch = YES;
//                [activityIndicator stopAnimating];
//            }
//            else
//            {
//                blocksafeSelf.searchResultsFromFourSquare = nil;
//                [blocksafeSelf loadPlacesAutocompleteForInput:searchText saveSelf: blocksafeSelf];
//            }
//        }];
//        
//    });
//}



#pragma mark - UISearchBarDelegate

- (void)searchWithKeywords:(NSString *)keywords {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"spot_name contains[c] %@", keywords];
    //searchResults = [spotArray filteredArrayUsingPredicate:resultPredicate];
    self.searchResults = [SPOT MR_findAllWithPredicate:resultPredicate];
    
    self.isAllowSearch = NO;
    
    self.searchResultsFromFourSquare = nil;
    self.searchResultsFromGooglePlace = nil;
    
//    [self reloadResultsTable];
    
    [self.activityIndicator startAnimating];
    
    __weak TrafficRegisterationViewController *blocksafeSelf = self;
    
    [self.searchOperation cancel];
    
    self.searchOperation = [Foursquare2 venueSearchNearByLatitude:@([AppSettings latitude]) longitude:@([AppSettings longitude]) query:keywords limit:@(50) intent: intentGlobal radius:@(100000) categoryId:nil callback:^(BOOL success, id result){
        
        TrafficRegisterationViewController *innerSelf = blocksafeSelf;
        
        if (success) {
            //parse here
            NSLog(@"success %@", result);
            
            [innerSelf.activityIndicator stopAnimating];
            innerSelf.isAllowSearch = YES;
            
            blocksafeSelf.searchResultsFromGooglePlace = nil;
            blocksafeSelf.searchResultsFromFourSquare = [[(NSDictionary*)result objectForKey:@"response"] objectForKey:@"venues"];
            
            if (blocksafeSelf.searchResultsFromFourSquare && [blocksafeSelf.searchResultsFromFourSquare count]>0)
            {
                [blocksafeSelf performSelectorOnMainThread:@selector(reloadResultsTable) withObject:nil waitUntilDone:YES];
            }
        }
        else
        {
            blocksafeSelf.searchResultsFromFourSquare = nil;
            [blocksafeSelf loadPlacesAutocompleteForInput:keywords saveSelf:blocksafeSelf];
        }
        
        
    }];
  

}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    NSLayoutConstraint *constraint = self.searchBar.constraints[0];
    constraint.constant = 260;
    self.cancelButton.hidden = NO;
    
   [self.initialTableResult setHidden:NO];
    
   [self.activityIndicator startAnimating];
     
    if (self.initiateSearchResultArray.count > 0) {
        self.searchResultsFromFourSquare = [[NSArray alloc] initWithArray:self.initiateSearchResultArray];
        if (self.searchResultsFromFourSquare && [self.searchResultsFromFourSquare count]>0)
        {
            [self.activityIndicator stopAnimating];
            [self reloadResultsTable];
        }
    } else {
        
        self.isAllowSearch = NO;
        
        __weak TrafficRegisterationViewController *blocksafeSelf = self;
        [self.searchOperation cancel];
        
        // show results within a radius of 1000m
        
        self.searchOperation = [Foursquare2 venueSearchNearByLatitude:@([AppSettings latitude]) longitude:@([AppSettings longitude]) query:@"" limit:nil intent:intentBrowse radius:@(1000) categoryId:nil callback:^(BOOL success, id result) {
            
            TrafficRegisterationViewController *innerSelf = blocksafeSelf;
            
            // callback
            
            if (success) {
                //parse here
                innerSelf.searchResultsFromFourSquare = [[(NSDictionary*)result objectForKey:@"response"] objectForKey:@"venues"];
                
                [innerSelf.initiateSearchResultArray removeAllObjects];
                [innerSelf.initiateSearchResultArray addObjectsFromArray:innerSelf.searchResultsFromFourSquare];
                
                if (innerSelf.searchResultsFromFourSquare && [innerSelf.searchResultsFromFourSquare count]>0)
                {
                    [innerSelf reloadResultsTable];
                }
            }
            
            [innerSelf.activityIndicator stopAnimating];
            innerSelf.isAllowSearch = YES;
            
        }];
        
    }
    
    return YES;
}

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [self.initialTableResult setHidden:YES];
//}
- (IBAction)onCancelButtonClicked:(id)sender {
    [self.initialTableResult setHidden:YES];
    
    NSLayoutConstraint *constraint = self.searchBar.constraints[0];
    constraint.constant = 320;
    self.cancelButton.hidden = YES;
    self.searchBar.text = @"";
    
    [self.searchOperation cancel];
    self.isAllowSearch = YES;
    
    
    
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.isAllowSearch) {
        [self searchWithKeywords:self.searchBar.text];
        NSLog(@"search key: %@", self.searchBar.text);
    }else {
        NSLog(@"can not click search too fast");
    }
}



#pragma mark - LPGoogleFunctions

- (LPGoogleFunctions *)googleFunctions
{
    if (!_googleFunctions) {
        _googleFunctions = [LPGoogleFunctions new];
//        NSString *googleAPIBrowserKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GoogleAPIBrowserKey"];
        NSString *googleAPIBrowserKey = GOOGLE_API_BROWSER_KEY;
        _googleFunctions.googleAPIBrowserKey = googleAPIBrowserKey;
        _googleFunctions.delegate = self;
        _googleFunctions.sensor = YES;
        _googleFunctions.languageCode = @"en";
    }
    return _googleFunctions;
}

- (void)loadPlacesAutocompleteForInput:(NSString *)input saveSelf: (TrafficRegisterationViewController *)blockSaveSelf
{
    NSLog(@"loadPlacesAutocompleteforinput");
//    self.searchDisplayController.searchBar.text = input;
    
    __weak TrafficRegisterationViewController *weakSelf = self;
    
    [self.googleFunctions loadPlacesAutocompleteWithDetailsForInput:input offset:(int)[input length] radius:0 location:nil placeType:LPGooglePlaceTypeGeocode countryRestriction:nil successfulBlock:^(NSArray *placesWithDetails) {
        NSLog(@"successful");
        
        TrafficRegisterationViewController *innerSelf = weakSelf;
      
        [innerSelf.activityIndicator stopAnimating];
        innerSelf.isAllowSearch = YES;
        
        innerSelf.searchResultsFromGooglePlace = [NSMutableArray arrayWithArray:placesWithDetails];
        
        [blockSaveSelf performSelectorOnMainThread:@selector(reloadResultsTable) withObject:nil waitUntilDone:YES];
    } failureBlock:^(LPGoogleStatus status) {
        TrafficRegisterationViewController *innerSelf = weakSelf;
        
        [innerSelf.activityIndicator stopAnimating];
        innerSelf.isAllowSearch = YES;
        innerSelf.searchResultsFromGooglePlace = [NSMutableArray new];
        [innerSelf reloadResultsTable];
    }];
}

#pragma mark - LPGoogleFunctions Delegate

- (void)googleFunctionsWillLoadPlacesAutocomplate:(LPGoogleFunctions *)googleFunctions forInput:(NSString *)input
{
    NSLog(@"willLoadPlacesAutcompleteForInput: %@", input);
}

- (void)googleFunctions:(LPGoogleFunctions *)googleFunctions didLoadPlacesAutocomplate:(LPPlacesAutocomplete *)placesAutocomplate
{
    NSLog(@"didLoadPlacesAutocomplete - Delegate");
}

- (void)googleFunctions:(LPGoogleFunctions *)googleFunctions errorLoadingPlacesAutocomplateWithStatus:(LPGoogleStatus)status
{
    NSLog(@"errorLoadingPlacesAutocomplateWithStatus - Delegate: %@", [LPGoogleFunctions getGoogleStatus:status]);
}

#pragma mark - Navigation 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"TrafficListEmbed"]) {
        TrafficListViewController  * trafficListController = (TrafficListViewController *) [segue destinationViewController];
        
        trafficListController.delegate = self;
        
        [trafficListController setTraffic:self.spot.traffic.intValue];
        
//        UITableView *tableView = [trafficListController tableView];
        
//        UITableViewCell *cell = [trafficListController tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        
//        NSArray *visibleIndexPaths = [trafficListController.tableView indexPathsForVisibleRows];
        
//        NSLog(@"%@", cell);
        
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
//        [trafficListController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - TrafficListViewControllerDelegate

- (void)didSelectTraffic:(int)traffic {
    self.spot.traffic = @(traffic);
}




@end
