//
//  GuideBookTableViewController.h
//  SPOT
//
//  Created by framgia on 7/9/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface GuideBookTableViewController : UITableViewController <SWTableViewCellDelegate>

- (IBAction)onBackButtonClicked:(id)sender;
- (IBAction)onSearchButtonClicked:(id)sender;
- (IBAction)onAddButtonClicked:(id)sender;

//@property (nonatomic) NSDate *lastReloadDataDate;

@end
