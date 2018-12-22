//
//  GuideBookDetailsXibViewController.h
//  SPOT
//
//  Created by Truong Anh Tuan on 10/6/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GuideBook;

@interface GuideBookDetailsXibViewController : UIViewController

@property (nonatomic) GuideBook *guideBook;
@property (nonatomic) NSArray *guideBooks;

- (IBAction)onBackButtonClicked:(id)sender;

- (IBAction)onAddButtonClicked:(id)sender;

- (IBAction)onEditButtonClicked:(id)sender;

- (IBAction)onPdfButtonClicked:(id)sender;

- (IBAction)onAirdropButtonClicked:(id)sender;



@end
