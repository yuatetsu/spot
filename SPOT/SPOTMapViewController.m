//
//  SPOTMapViewController.m
//  SPOT
//
//  Created by framgia on 7/30/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SPOTMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapInfoWindow.h"
#import "SpotDetailsXibViewController.h"
#import "BlackActivityIndicatorView.h"
#import "Foursquare2.h"
#import "AppDelegate.h"

@interface SPOTMapViewController ()<GMSMapViewDelegate>
{
    BOOL isShowingMarker;
    
}

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *marker;
@property (strong, nonatomic) BlackActivityIndicatorView *activityIndicator;
@property (nonatomic) NSOperation *operation;


@end

@implementation SPOTMapViewController

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
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Get the reference to the current toolbar buttons
    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
    // This is how you remove the button from the toolbar and animate it
    [toolbarButtons removeObject:self.saveButton];
    [self setToolbarItems:toolbarButtons animated:YES];
    
    
    if (self.spot.lat.doubleValue || self.spot.lng.doubleValue) {
        @autoreleasepool {
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.spot.lat doubleValue]
                                                                    longitude:[self.spot.lng doubleValue]
                                                                         zoom:15];
            GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:[self.spot.lat intValue]?camera:nil];
            self.mapView = mapView;
            [self.mapView setDelegate:self];
            //mapView = [[GMSMapView alloc] initWithFrame:CGRectZero];
            //mapView.myLocationEnabled = YES;
            self.self.view = self.mapView;
            
            // Creates a marker in the center of the map.
            GMSMarker *marker = [[GMSMarker alloc] init];
            self.marker = marker;
            self.marker.position = CLLocationCoordinate2DMake([self.spot.lat doubleValue], [self.spot.lng doubleValue]);
            self.marker.title = self.spot.spot_name;
            self.marker.snippet = self.spot.address;
            self.marker.icon = [appDelegate getImageWithName:@"Marker"];
            self.marker.map = self.mapView;
            
            // show info window
            [self.mapView setSelectedMarker:marker];
        }
    }
    else {
        if (self.spot.address) {
            @autoreleasepool {
                GMSMapView *mapView = [GMSMapView new];
                self.mapView = mapView;
                [self.mapView setDelegate:self];
                //mapView = [[GMSMapView alloc] initWithFrame:CGRectZero];
                //mapView.myLocationEnabled = YES;
                //                innerSelf.view = nil;
                self.view = self.mapView;
                
                self.activityIndicator = [[BlackActivityIndicatorView alloc] initWithTopDistance:150];
                [self.view addSubview:self.activityIndicator];
                [self.activityIndicator startAnimating];
                
                
                
                // Creates a marker in the center of the map.
                GMSMarker *marker = [[GMSMarker alloc] init];
                self.marker = marker;
                
                self.marker.title = self.spot.spot_name;
                self.marker.snippet = self.spot.address;
                self.marker.icon = [appDelegate getImageWithName:@"Marker"];
                self.marker.map = self.mapView;
                
                // show info window
                [self.mapView setSelectedMarker:self.marker];
                
                __weak SPOTMapViewController *weakSelf = self;
                
                [self.operation cancel];
                self.operation = [Foursquare2 venueSearchNearByLatitude:@([AppSettings latitude]) longitude:@([AppSettings longitude]) query:weakSelf.spot.address limit:nil intent: intentBrowse radius:@(10000) categoryId:nil callback:^(BOOL success, id result){
                        SPOTMapViewController *innerSelf = weakSelf;
                        
                        NSNumber *lat = 0;
                        NSNumber *lng = 0;
                        
                        if (success) {
                            
                            NSLog(@"success");
                            
                            NSArray *venues = [[(NSDictionary*)result objectForKey:@"response"] objectForKey:@"venues"];
                            if (venues.count > 0) {
                                
                                NSDictionary *venue = [venues firstObject];
                                
                                lat = venue[@"location"][@"lat"];
                                lng = venue[@"location"][@"lng"];
                            }
                            
                            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[lat doubleValue]
                                                                                    longitude:[lng doubleValue]
                                                                                         zoom:15];
                            
                            [innerSelf.mapView setCamera:camera];
                            [innerSelf.marker setPosition:CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue])];
                            [innerSelf.activityIndicator stopAnimating];
                        }
                   
                }];
            }
        }
    }
}

- (void)dealloc {
    [self.mapView clear];
    [self.mapView removeFromSuperview] ;
    self.mapView.delegate = nil;
    self.mapView = nil ;
    
    NSLog(@"Maps view died");
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate{
    NSLog(@"didLongPressAtCoordinate");
    
    self.marker.position = coordinate;
    
//    [self.navigationController setToolbarHidden:NO animated:YES];
    
    // Get the reference to the current toolbar buttons
    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
    // This is how you add the save button to the toolbar and animate it
    if (![toolbarButtons containsObject:self.saveButton]) {
        // The following line adds the object to the end of the array.
        // If you want to add the button somewhere else, use the `insertObject:atIndex:`
        // method instead of the `addObject` method.
        [toolbarButtons addObject:self.saveButton];
        [self setToolbarItems:toolbarButtons animated:YES];
    }
}

-(void) mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
//    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
//    [self.navigationController setToolbarHidden:NO animated:YES];
}

-(void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    [self performSegueWithIdentifier:@"PushDetailsViewController" sender:self];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    @autoreleasepool {
        GoogleMapInfoWindow *infoWindow =  [[[NSBundle mainBundle] loadNibNamed:@"GoogleMapInfoWindow" owner:self options:nil] objectAtIndex:0];
        infoWindow.spotNameLabel.text = marker.title;
        infoWindow.spotNameLabel.layer.cornerRadius = 5.0f;
        infoWindow.addressLabel.text = marker.snippet;
        return infoWindow;
    }
}

-(IBAction)onBackButtonClicked:(id)sender
{
    if (!isShowingMarker) {
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(IBAction)onSaveButtonClicked:(id)sender
{
    self.spot.lat = [NSNumber numberWithDouble:self.marker.position.latitude];
    self.spot.lng = [NSNumber numberWithDouble:self.marker.position.longitude];
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    // save
    [magicalContext MR_saveOnlySelfAndWait];
    
    // Get the reference to the current toolbar buttons
    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
    // This is how you remove the button from the toolbar and animate it
    [toolbarButtons removeObject:self.saveButton];
    [self setToolbarItems:toolbarButtons animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"PushDetailsViewController"])
    {
        // Get reference to the destination view controller
        SpotDetailsXibViewController *detailsViewController = [segue destinationViewController];
        
        [detailsViewController setSpot:self.spot];
    }
}

@end
