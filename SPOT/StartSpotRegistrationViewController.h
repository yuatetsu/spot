//
//  StartSpotRegistrationViewController.h
//  SPOT
//
//  Created by Truong Anh Tuan on 9/10/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPOT;

@protocol StartSpotRegistrationViewControllerDelegate <NSObject>

- (void)didSelectStartSpot:(SPOT *)spot;
- (void)didSelectFoursquareVenueWithName: (NSString *)name lat: (double)lat lng: (double)lng;

@end

@interface StartSpotRegistrationViewController : UITableViewController

@property (nonatomic) id <StartSpotRegistrationViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end
