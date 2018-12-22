//
//  SpotCell.m
//  SPOT
//
//  Created by Truong Anh Tuan on 9/27/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SpotCell.h"
#import "AppDelegate.h"

@interface SpotCell() {
    UILongPressGestureRecognizer *longPressGesture;
//    BOOL isAddedUtilityButton;
}



@end

@implementation SpotCell

AppDelegate *appDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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

-(void)awakeFromNib{
    
    _spotNameLabel.font = appDelegate.normalFont;
    
    // config address label
    _addressLabel.font = appDelegate.smallFont;
    
    _tagsLabel.font = appDelegate.smallFont;
    
    _dateLabel.font = appDelegate.smallFont;
}

-(void)addUtilityButton{
    
    if (!self.rightUtilityButtons) {
        
//        isAddedUtilityButton = YES;
        
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[appDelegate getImageWithName:@"Delete"] selectedIcon:[appDelegate getImageWithName:@"Delete"]];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[appDelegate getImageWithName:@"TagWhite"] selectedIcon:[appDelegate getImageWithName:@"Tag"]];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[appDelegate getImageWithName:@"Airdrop"] selectedIcon:[appDelegate getImageWithName:@"Airdrop"]];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[appDelegate getImageWithName:@"Edit"] selectedIcon:[appDelegate getImageWithName:@"Edit"]];
        
        self.rightUtilityButtons = rightUtilityButtons;
    }
    
}

- (void)scrollViewPressed:(UIGestureRecognizer *)gestureRecognizer {
    [super scrollViewPressed:gestureRecognizer];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"scrollViewPressed");
        [self.delegate longPressGestureRecognizeOnCell:self];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
