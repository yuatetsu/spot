//
//  SpotDetailsViewController.h
//  SPOT
//
//  Created by Truong Anh Tuan on 10/3/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPOT.h"

@interface SpotDetailsXibViewController : UIViewController

@property (nonatomic) SPOT * spot;
@property (nonatomic, copy) NSArray * spots;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


- (IBAction)onBackButtonClicked:(id)sender;

- (IBAction)onAddButtonClicked:(id)sender;

- (IBAction)onEditButtonClicked:(id)sender;


- (IBAction)onPdfButtonClicked:(id)sender;

- (IBAction)onAirdropButtonClicked:(id)sender;

- (IBAction)onMapButtonClicked:(id)sender;



@end
