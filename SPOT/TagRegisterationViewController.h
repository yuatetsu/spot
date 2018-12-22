//
//  TagRegisterationViewController.h
//  SPOT
//
//  Created by framgia on 7/21/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TITokenField.h"
#import "SPOT.h"

@interface TagRegisterationViewController : UITableViewController

@property (strong, nonatomic) SPOT* spot;

@property (strong, nonatomic) IBOutlet UIView *tokenFieldContainingView;
@property (strong, nonatomic) IBOutlet TITokenFieldView *tokenFieldView;

@property (strong, nonatomic) NSMutableArray *tagResultsArray;

- (IBAction) onDoneButtonClicked:(id)sender;

@end
