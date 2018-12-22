//
//  SPOTListTableViewController.h
//  SPOT
//
//  Created by framgia on 7/9/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideBook.h"

@interface SPOTListTableViewController : UITableViewController

@property (strong, nonatomic) NSString* filterTag;
@property (strong, nonatomic) NSDate* filterDate;
@property (strong, nonatomic) NSIndexPath* indexPathForInsertingIntoGuideBook;
@property (strong, nonatomic) GuideBook* guideBook;

//@property (nonatomic) NSDate *lastReloadDataDate;

- (IBAction)onBackButtonClicked:(id)sender;
- (IBAction)onSearchButtonClicked:(id)sender;
- (IBAction)onAddButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;



@end
