//
//  TopScreenViewController.h
//  SPOT
//
//  Created by framgia on 7/4/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopScreenViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *spotNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *guideNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *countryNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *regionNumberLabel;
@property (strong, nonatomic) IBOutlet UIActionSheet *topScreenActionSheet;

//ImageBackGround

@property (weak, nonatomic) IBOutlet UIButton *searchButton;



@property (strong, nonatomic) IBOutlet UIScrollView* scrollView;

- (IBAction) onSettingsButtonClicked: (id) sender;
- (IBAction) onMapsButtonClicked: (id) sender;
- (IBAction) onSearchButtonClicked: (id) sender;
- (IBAction) onCalendarButtonClicked: (id) sender;
- (IBAction) onGuideBookButtonClicked: (id) sender;
- (IBAction) onTagsButtonClicked: (id) sender;
- (IBAction) onCameraBarButtonClicked: (id) sender;
- (IBAction)onSpotListButtonClicked:(id)sender;
- (IBAction)onAddGuideBookButtonClicked:(id)sender;
- (IBAction)onAddSpotButtonClicked:(id)sender;


// property for design
@property (weak, nonatomic) IBOutlet UIView *searchBackgoundView;



@end
