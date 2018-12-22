//
//  AddressRegisterationViewController.m
//  SPOT
//
//  Created by framgia on 7/22/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "AddressRegisterationViewController.h"
#import "AppDelegate.h"
#import "Foursquare2.h"
#import "Country.h"
#import "Region.h"
#import <CoreLocation/CoreLocation.h>
#import "LPGoogleFunctions.h"
#import "BlackActivityIndicatorView.h"

//NSString *const googleAPIBrowserKey = @"AIzaSyADNExm3N8B8njiliUOcT9XuGfOW1qNOFs";

@interface AddressRegisterationViewController () <LPGoogleFunctionsDelegate, UISearchBarDelegate>
{
    
}

@property (strong, nonatomic) NSArray *searchResultsFromFourSquare;
@property (strong, nonatomic) NSArray *searchResultsFromGooglePlace;
@property (strong, nonatomic) NSOperation *searchOperation;
@property (assign, nonatomic) BOOL isCheckinFoursquare;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;

@property (nonatomic, strong) LPGoogleFunctions *googleFunctions;
@property (assign, nonatomic) BOOL isAllowSearch;

@property (nonatomic) BlackActivityIndicatorView *activityIndicator;


@end

@implementation AddressRegisterationViewController

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
    
    [self.searchBar becomeFirstResponder];
    self.isAllowSearch = YES;
    
    BlackActivityIndicatorView *activityIndicator = [[BlackActivityIndicatorView alloc] initWithTopDistance:150];
    
    self.activityIndicator = activityIndicator;
    [self.view addSubview:self.activityIndicator];
    
    self.isCheckinFoursquare = NO;
    [self.searchNavigationBar setBarTintColor:[UIColor whiteColor]];
    

    if([self.initiateSearchResultArray count] > 0){
        self.searchResultsFromFourSquare = [[NSArray alloc] initWithArray:self.initiateSearchResultArray];
        if (self.searchResultsFromFourSquare && [self.searchResultsFromFourSquare count]>0)
        {
            [self reloadResultsTable];
        }  
    } else {
        [self.activityIndicator startAnimating];
        self.isAllowSearch = NO;
        
        __weak AddressRegisterationViewController *blocksafeSelf = self;
        
        self.searchOperation = [Foursquare2 venueSearchNearByLatitude:@([AppSettings latitude]) longitude:@([AppSettings longitude]) query:@"" limit:nil intent:intentBrowse radius:@(1000) categoryId:nil callback:^(BOOL success, id result) {
            
            AddressRegisterationViewController *innerSelf = blocksafeSelf;
            
            if (success) {
                
                NSLog(@"success");
                innerSelf.searchResultsFromFourSquare= [[(NSDictionary*)result objectForKey:@"response"] objectForKey:@"venues"];
                
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
}

- (void)dealloc {
    self.searchResultsFromFourSquare = nil;
    self.searchResultsFromGooglePlace = nil;
    self.googleFunctions = nil;
    self.searchOperation = nil;
    
    NSLog(@"Address died.");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.searchOperation) {
        [self.searchOperation cancel];
    }
}
- (IBAction)onBackButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) onAddButtonClicked:(id)sender
{
    if (self.searchBar.text.length==0) return;
    
    // delete previous country and region if they no longer contain any spot
    Country *previousCountry = self.spot.country;
    Region *previousRegion = self.spot.region;
    
    self.spot.address = self.searchBar.text;
    self.spot.country = nil;
    self.spot.region = nil;
    
    if (previousCountry.country.length > 0) {
        if ([previousCountry.spot count] == 0) {
            [previousCountry MR_deleteEntity];
        }
    }
    
    if (previousRegion.region.length > 0) {
        if ([previousRegion.spot count] == 0) {
            [previousRegion MR_deleteEntity];
        }
    }
    
    if (self.delegate) {
        [self.delegate didSelectAddress:nil];
    }
    
    [self saveAndPopSelf];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResultsFromFourSquare.count + self.searchResultsFromGooglePlace.count;
}



-(void) reloadResultsTable {
    [self.tableView reloadData];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (self.searchResultsFromFourSquare && self.searchResultsFromFourSquare.count > 0 && indexPath.row < self.searchResultsFromFourSquare.count)
    {
        // results from foursquare
        NSDictionary *venue = [self.searchResultsFromFourSquare objectAtIndex:indexPath.row];
        cell.textLabel.text = venue[@"name"];
        //        NSArray *formattedAddress = venue[@"location"][@"formattedAddress"];
        NSString *address = venue[@"location"][@"address"];
        
        address = address?address:@"";
        /*
         for(int i=0; i<formattedAddress.count; i++)
         {
         NSString* addressInfo = [formattedAddress objectAtIndex:i];
         if (addressInfo && ![addressInfo isEqualToString:@""])
         {
         address = [address stringByAppendingFormat:[address isEqualToString:@""]?@"%@":@", %@",addressInfo];
         }
         }
         */
        cell.detailTextLabel.text = address;
    }
    else if (self.searchResultsFromGooglePlace && self.searchResultsFromGooglePlace.count > 0 && indexPath.row < self.searchResultsFromGooglePlace.count)
    {
        // results from Google Place
        LPPlaceDetails *placeDetails = (LPPlaceDetails *)[self.searchResultsFromGooglePlace objectAtIndex:indexPath.row];
        cell.textLabel.text = placeDetails.name;
        NSString *address = placeDetails.formattedAddress;
        
        address = address?address:@"";
        cell.detailTextLabel.text = address;
    }
    
    cell.textLabel.font = appDelegate.normalFont;
    cell.detailTextLabel.font = appDelegate.smallFont;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    return cell;
}
- (void)saveAndPopSelf
{
    __weak SPOT *spot = self.spot;
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.view.userInteractionEnabled = false;
    
    NSString* selectedCountry = nil;
    NSString* selectedRegion = nil;
    NSDictionary *venue = nil;
    
    Country *previousCountry = self.spot.country;
    Region *previousRegion = self.spot.region;
    
    if (indexPath.row < self.searchResultsFromFourSquare.count)
    {
        // from FourSquare
        venue = [self.searchResultsFromFourSquare objectAtIndex:indexPath.row];
        NSLog(@"venue: %@",venue);
//        if (self.spot.spot_name.length == 0) {
            self.spot.spot_name = venue[@"name"];
//        }
        
//        if (self.spot.phone.length == 0) {
            self.spot.phone = venue[@"contact"][@"phone"];
//        }
//        if (self.spot.url.length == 0) {
            self.spot.url = venue[@"url"];
//        }
        NSString *address = venue[@"location"][@"address"];
        
        self.spot.address = [NSString stringWithFormat:@"%@ %@", venue[@"name"] , address != nil ? address : @"" ];
        
        selectedCountry = venue[@"location"][@"country"];
        selectedRegion = venue[@"location"][@"state"];
        self.spot.lat = venue[@"location"][@"lat"];
        self.spot.lng = venue[@"location"][@"lng"];
    }
    else
    {
        // from Google Place
        
        LPPlaceDetails *placeDetails = (LPPlaceDetails *)[self.searchResultsFromGooglePlace objectAtIndex:indexPath.row];
        NSLog(@"placeDetails: %@",placeDetails);
//        if (self.spot.spot_name.length == 0) {
            self.spot.spot_name = placeDetails.name;
//        }
        
        if (self.spot.phone.length == 0) {
            // Google Place API does not provide the phone number, is it exact?
        }
//        if (self.spot.url.length == 0) {
            self.spot.url = placeDetails.url;
//        }
        self.spot.address = [NSString stringWithFormat:@"%@ %@", placeDetails.name ,placeDetails.formattedAddress];
        
        //selectedCountry = venue[@"location"][@"country"];
        //selectedRegion = venue[@"location"][@"state"];
        self.spot.lat = [NSNumber numberWithDouble:placeDetails.geometry.location.latitude];
        self.spot.lng = [NSNumber numberWithDouble:placeDetails.geometry.location.longitude];
    }
    
    
    if (selectedCountry)
    {
        Country *country = [Country MR_findFirstByAttribute:@"country" withValue:selectedCountry];
        if (!country){
            country = [Country MR_createEntity];
        }
        country.country = selectedCountry;
        self.spot.country = country;
    }
    
    if (selectedRegion)
    {
        Region *region = [Region MR_findFirstByAttribute:@"region" withValue:selectedRegion];
        if (!region){
            region = [Region MR_createEntity];
        }
        region.region = selectedRegion;
        self.spot.region = region;
    }
    
    if (previousCountry.country.length > 0) {
        if ([previousCountry.spot count] == 0) {
            [previousCountry MR_deleteEntity];
        }
    }
    
    if (previousRegion.region.length > 0) {
        if ([previousRegion.spot count] == 0) {
            [previousRegion MR_deleteEntity];
        }
    }
    
    if (self.delegate) {
        [self.delegate didSelectAddress:venue[@"id"]];
    }
    
    NSLog(@"select address");
    
    [self saveAndPopSelf];
}


- (void)searchWithKeywords:(NSString *)searchText
{
    [self.activityIndicator startAnimating];
    NSLog(@"begin search");
    self.searchResultsFromFourSquare = nil;
    self.searchResultsFromGooglePlace = nil;
    
    // clear table data
    [self reloadResultsTable];
    
    self.isAllowSearch = NO;
    [self.searchOperation cancel];

    __weak AddressRegisterationViewController *blocksafeSelf = self;
    
    self.searchOperation = [Foursquare2 venueSearchNearByLatitude:@([AppSettings latitude]) longitude:@([AppSettings longitude]) query:searchText limit:@(50) intent: intentGlobal radius:@(100000) categoryId:nil callback:^(BOOL success, id result){
        
        AddressRegisterationViewController *innerBlock = blocksafeSelf;
        if (success) {
            
            NSLog(@"success");
            
            [innerBlock.activityIndicator stopAnimating];
            innerBlock.isAllowSearch = YES;
           
            innerBlock.searchResultsFromGooglePlace = nil;
            innerBlock.searchResultsFromFourSquare = [[(NSDictionary*)result objectForKey:@"response"] objectForKey:@"venues"];
           
            if (innerBlock.searchResultsFromFourSquare && [innerBlock.searchResultsFromFourSquare count]>0)
            {
                [innerBlock reloadResultsTable];
            }
        }
        else
        {
            innerBlock.searchResultsFromFourSquare = nil;
            [innerBlock loadPlacesAutocompleteForInput:searchText];
        }
    }];
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
//    [self searchWithKeywords:searchText];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
}

#pragma mark - UITableViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self.view endEditing:YES];
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

- (void)loadPlacesAutocompleteForInput:(NSString *)input
{
    self.searchDisplayController.searchBar.text = input;
    __weak AddressRegisterationViewController *blocksafeSelf = self;
    [self.googleFunctions loadPlacesAutocompleteWithDetailsForInput:input offset:(int)[input length] radius:0 location:nil placeType:LPGooglePlaceTypeGeocode countryRestriction:nil successfulBlock:^(NSArray *placesWithDetails) {
        NSLog(@"successful");
        
        AddressRegisterationViewController *innerSelf = blocksafeSelf;
        
        [innerSelf.activityIndicator stopAnimating];
        innerSelf.isAllowSearch = YES;
        innerSelf.searchResultsFromGooglePlace = [NSMutableArray arrayWithArray:placesWithDetails];
        
        [innerSelf reloadResultsTable];
    } failureBlock:^(LPGoogleStatus status) {
        NSLog(@"Error - Block: %@", [LPGoogleFunctions getGoogleStatus:status]);
        
        AddressRegisterationViewController *innerSelf = blocksafeSelf;
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

#pragma mark - UISearchBarDelegate 

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.isAllowSearch) {
        [self searchWithKeywords:self.searchBar.text];
    }else {
        NSLog(@"can not click search too fast");
    }
}

@end
