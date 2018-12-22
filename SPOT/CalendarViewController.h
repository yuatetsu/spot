//
//  CalendarViewController.h
//  SPOT
//
//  Created by framgia on 8/11/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *calendarView;

- (IBAction)onLeftButtonClicked:(id)sender;
- (IBAction)onRightButtonClicked:(id)sender;
- (IBAction)onBackButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleCendarItem;
@end
