//
//  DateRegisterationViewController.h
//  SPOT
//
//  Created by framgia on 7/21/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPOT.h"

@interface DateRegisterationViewController : UIViewController

@property (strong, nonatomic) SPOT* spot;


@property (strong, nonatomic) IBOutlet UILabel* currentDateLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker* datePicker;

- (IBAction) onDatePickerValueChanged:(id)sender;
- (IBAction) onDoneButtonClicked:(id)sender;


@end
