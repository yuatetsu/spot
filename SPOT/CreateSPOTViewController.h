//
//  CreateSPOTViewController.h
//  SPOT
//
//  Created by framgia on 7/17/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPOT.h"

@protocol CreateSPOTViewControllerDelegate <NSObject>

@optional
- (void)didCreateNewSpot:(SPOT *)spot;

@end

@interface CreateSPOTViewController : UIViewController 

@property (strong, nonatomic) SPOT* spot;

@property (strong, nonatomic) IBOutlet UITextField *spotNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *telTextField;
@property (strong, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) id <CreateSPOTViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextView *memoTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textView_constraint;
- (IBAction) resignFirstResponder:(id)sender;
- (IBAction) onDoneButtonClicked:(id)sender;
- (void) dismissKeyboard;


- (IBAction)onFoursquareButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *foursquareButton;


@end
