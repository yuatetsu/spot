//
//  TagCell.m
//  SPOT
//
//  Created by Truong Anh Tuan on 8/28/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "TagCell.h"
#import "AppDelegate.h"

@interface TagCell() <UITextFieldDelegate>
{
//    BOOL isAddedUtilityButton;
}

@end

@implementation TagCell

AppDelegate *appDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
//        isAddedUtilityButton = NO;
        //    Config utility buttons
    }
    
    return self;
}

-(void)addUtilityButton{
    
    if (!self.rightUtilityButtons) {
        
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[appDelegate getImageWithName:@"Edit"] selectedIcon:[appDelegate getImageWithName:@"Edit"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[appDelegate getImageWithName:@"Delete"] selectedIcon:[appDelegate getImageWithName:@"Delete"]];
        
        self.rightUtilityButtons = rightUtilityButtons;
    }
}


- (void)awakeFromNib
{
    self.tagTextField.delegate = self;
    self.spotCountLabel.font = appDelegate.normalFont;
    self.doneButton.titleLabel.font = appDelegate.normalFont;
    self.tagTextField.font = appDelegate.normalFont;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)onDoneButtonClicked:(id)sender {
    [self.tagTextField endEditing:YES];
    [self.tagTextField setUserInteractionEnabled:NO];
    
    [self.doneButton setHidden:YES];
    [self.spotCountLabel setHidden:NO];
    [self.tagTextField setEnabled:NO];
    
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [self.delegate tagCellDidEndEditing:self];
}

- (void)beginEditing {
    [self.tagTextField setEnabled:YES];
    [self.spotCountLabel setHidden:YES];
    [self.tagTextField setUserInteractionEnabled:YES];
    
    [self.tagTextField becomeFirstResponder];
    
    [self.doneButton setHidden:NO];
    
    [self setAccessoryType:UITableViewCellAccessoryNone];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    
    [self onDoneButtonClicked:nil];
    return NO;
}

@end
