//
//  TagListViewController.h
//  SPOT
//
//  Created by framgia on 8/8/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideBook.h"

@interface TagListViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UISearchBar* searchBar;

- (IBAction) onAddButtonClicked:(id)sender;

- (IBAction)onBackButtonClicked:(id)sender;

- (IBAction)swipeRightRecognized:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *tagItem;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;


@property (weak, nonatomic) IBOutlet UINavigationBar *searchNavigationBar;

@property (strong, nonatomic) NSIndexPath* indexPathForInsertingIntoGuideBook;
@property (strong, nonatomic) GuideBook* guideBook;

@end
