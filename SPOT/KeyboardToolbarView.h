//
//  KeyboardToolbarView.h
//  SPOT
//
//  Created by framgia on 7/17/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "customButton.h"

@protocol KeyboardToolbarViewDelegate <NSObject>

- (void) onCalendarButtonClicked: (id)sender;
- (void) onTrafficButtonClicked: (id)sender;
- (void) onCameraButtonClicked: (id)sender;
- (void) onAddressButtonClicked: (id)sender;
- (void) onTagButtonClicked: (id)sender;

@end

@interface KeyboardToolbarView : UIView

@property (assign, nonatomic) BOOL touch;

-(IBAction)onDateButtonClicked:(id)sender;
-(IBAction)onTrafficButtonClicked:(id)sender;
-(IBAction)onPhotoButtonClicked:(id)sender;
-(IBAction)onAddressButtonClicked:(id)sender;
-(IBAction)onTagButtonClicked:(id)sender;


//calendar

@property (weak, nonatomic) IBOutlet UILabel *yearlabel;
@property (weak, nonatomic) IBOutlet UILabel *monthlabel;
@property (weak, nonatomic) IBOutlet customButton *btnCalendar;
@property (weak, nonatomic) IBOutlet UIView *selectedCalendarView;
@property (weak, nonatomic) IBOutlet UIImageView *pointSelectCalendar;
@property (weak, nonatomic) id <KeyboardToolbarViewDelegate> delegate;


//traffic

@property (weak, nonatomic) IBOutlet customButton *btnTraffic;
@property (weak, nonatomic) IBOutlet UIImageView *pointSelectTraffic;


//Photo

@property (weak, nonatomic) IBOutlet customButton *btnPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *pointSelectPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;

//Adress

@property (weak, nonatomic) IBOutlet customButton *btnAdress;
@property (weak, nonatomic) IBOutlet UIImageView *pointSelectAddress;

//Tags

@property (weak, nonatomic) IBOutlet UIView *btnTags;
@property (weak, nonatomic) IBOutlet UIView *nonSelectTagsView;
@property (weak, nonatomic) IBOutlet UIView *selectedTagsView;
@property (weak, nonatomic) IBOutlet UILabel *tagLbl;
@property (weak, nonatomic) IBOutlet UIImageView *pointselectTag;


@end
