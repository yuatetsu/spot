//
//  SPOTMapViewController.h
//  SPOT
//
//  Created by framgia on 7/30/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPOT.h"

@interface SPOTMapViewController : UIViewController

@property (strong, nonatomic) SPOT* spot;

@property (strong, nonatomic) IBOutlet UIBarButtonItem* saveButton;

-(IBAction)onBackButtonClicked:(id)sender;
-(IBAction)onSaveButtonClicked:(id)sender;

@end
