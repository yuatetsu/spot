//
//  TrafficListViewController.h
//  SPOT
//
//  Created by Truong Anh Tuan on 9/16/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrafficListViewControllerDelegate <NSObject>

- (void)didSelectTraffic: (int)traffic;

@end


@interface TrafficListViewController : UITableViewController

- (void)setTraffic: (int)traffic;

@property (nonatomic, weak) id <TrafficListViewControllerDelegate> delegate;


@end
