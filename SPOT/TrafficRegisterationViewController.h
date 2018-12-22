//
//  TrafficRegisterationViewController.h
//  SPOT
//
//  Created by framgia on 7/21/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPOT.h"

@interface TrafficRegisterationViewController : UIViewController

@property (strong, nonatomic) SPOT* spot;

@property (strong, nonatomic) IBOutlet UILabel* startSPOTLabel;
@property (strong, nonatomic) IBOutlet UIPickerView* transportationPicker;
@property (weak, nonatomic) IBOutlet UILabel *startSpotNameLabel;
@property (nonatomic, strong) NSMutableArray *initiateSearchResultArray;

- (IBAction) onDoneButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *trafficListContainerView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)onCancelButtonClicked:(id)sender;


@end
