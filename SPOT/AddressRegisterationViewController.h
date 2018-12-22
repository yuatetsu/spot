//
//  AddressRegisterationViewController.h
//  SPOT
//
//  Created by framgia on 7/22/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPOT.h"

@protocol AddressRegisterationViewControllerDelegate <NSObject>

- (void)didSelectAddress: (NSString *)venueID;

@end


@interface AddressRegisterationViewController : UITableViewController

@property (strong, nonatomic) SPOT* spot;

@property (strong, nonatomic) IBOutlet UISearchBar* searchBar;

@property (nonatomic, strong) NSMutableArray *initiateSearchResultArray;

- (IBAction) onAddButtonClicked:(id)sender;

@property (nonatomic, weak) id <AddressRegisterationViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationBar *searchNavigationBar;


@end
