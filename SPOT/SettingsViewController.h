//
//  SettingsViewController.h
//  SPOT
//
//  Created by Truong Anh Tuan on 8/18/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foursquare2.h"

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *passcodeSwitch;

@property (weak, nonatomic) IBOutlet UIButton *changePasscodeButton;

@property (weak, nonatomic) IBOutlet UISwitch *prioritySwitch;

@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;

@property (weak, nonatomic) IBOutlet UISwitch *foursquareSwitch;


- (IBAction)onChangePasscodeButtonClicked:(id)sender;

- (IBAction)onPasscodeSwitchValueChanged:(id)sender;

- (IBAction)onPrioritySwitchValueChanged:(id)sender;

- (IBAction)onBackButtonClicked:(id)sender;

- (IBAction)foursquareSwitchValueChanged:(id)sender;

@end
