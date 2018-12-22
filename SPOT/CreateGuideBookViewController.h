//
//  CreateGuideBookViewController.h
//  SPOT
//
//  Created by framgia on 8/13/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GuideBook;

@interface CreateGuideBookViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *guideBookNameTextField;

@property (strong, nonatomic) IBOutlet UITextField *startDateTextField;

@property (weak, nonatomic) IBOutlet UIButton *selectStartSpotButton;


- (IBAction)onSelectStartSpotButtonClicked:(id)sender;


@property (strong, nonatomic) GuideBook *guideBook;

-(IBAction)onAddDayButtonClicked:(id)sender;
-(IBAction)onAddSPOTButtonClicked:(id)sender;
-(IBAction)onAddMemoButtonClicked:(id)sender;

-(IBAction)onDoneButtonClicked:(id)sender;

- (IBAction)tapGestureRecognized:(id)sender;


- (IBAction)longPressRecognized:(id)sender;


@end
