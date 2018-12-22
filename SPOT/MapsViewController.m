//
//  MapsViewController.m
//  SPOT
//
//  Created by framgia on 7/9/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "MapsViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SPOT.h"
#import "GoogleMapInfoWindow.h"
#import "AppDelegate.h"
#import "SpotDetailsXibViewController.h"

@interface MapsViewController ()<GMSMapViewDelegate>
{
    GMSMapView *mapView;
}
@property (strong, nonatomic) NSArray *spotArray;
@property (strong, nonatomic) SPOT *selectedSpot;
@property (weak, nonatomic) IBOutlet UIView *mapView;
@end

@implementation MapsViewController

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
    
    
    self.spotArray = [SPOT MR_findAll];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[AppSettings latitude]
                                                            longitude:[AppSettings longitude]
                                                                 zoom:14];
    mapView = [GMSMapView mapWithFrame:self.mapView.bounds camera:camera];
    
    [self.mapView addSubview:mapView];
    [mapView setDelegate:self];
    mapView.settings.compassButton = YES;
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    
    for (SPOT *spot in self.spotArray)
    {
        @autoreleasepool {
            if (spot.lat.doubleValue || spot.lng.doubleValue)
            {
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake(spot.lat.doubleValue, spot.lng.doubleValue);
                marker.title = spot.spot_name;
                marker.snippet = spot.address;
                marker.icon = [appDelegate getImageWithName:@"Marker"];
                marker.map = mapView;
                marker.userData = spot;
            }
        }
    }

    
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    // change status bar
    appDelegate.statusBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    appDelegate.statusBar.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)dealloc {
    [mapView clear];
    [mapView removeFromSuperview] ;
    mapView.delegate = nil;
    mapView = nil ;
    self.spotArray = nil;
    
    NSLog(@"Maps died.");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBackButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) mapView:(GMSMapView *)map didChangeCameraPosition:(GMSCameraPosition *)position
{
    //    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void) mapView:(GMSMapView *)map idleAtCameraPosition:(GMSCameraPosition *)position
{
    //    [self.navigationController setToolbarHidden:NO animated:YES];
}
-(BOOL) mapView:(GMSMapView *)map didTapMarker:(GMSMarker *)marker
{
    // show info window
    [mapView setSelectedMarker:marker];
    return YES;
}
-(void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    self.selectedSpot = marker.userData;
    [self performSegueWithIdentifier:@"PushDetailsViewController" sender:self];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    @autoreleasepool {
        GoogleMapInfoWindow *infoWindow =  [[[NSBundle mainBundle] loadNibNamed:@"GoogleMapInfoWindow" owner:self options:nil] objectAtIndex:0];
        
        infoWindow.spotNameLabel.text = marker.title;
        infoWindow.spotNameLabel.textColor = [UIColor whiteColor];
        
        infoWindow.spotNameLabel.layer.cornerRadius = 5.0f;
        
        infoWindow.addressLabel.text = marker.snippet;
        infoWindow.addressLabel.textColor = [UIColor whiteColor];
        
        return infoWindow;
    }
    
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
        
        [detailsViewController setSpot:self.selectedSpot];
    }
}


@end