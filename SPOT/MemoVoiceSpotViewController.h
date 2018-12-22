//
//  MemoVoiceSpotViewController.h
//  SPOT
//
//  Created by nguyen hai dang on 9/23/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPOT.h"

@interface MemoVoiceSpotViewController : UITableViewController


@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (strong, nonatomic) SPOT* spot;


@end
