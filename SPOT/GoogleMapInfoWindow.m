//
//  GoogleMapInfoWindow.m
//  SPOT
//
//  Created by framgia on 9/12/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "GoogleMapInfoWindow.h"
#import "AppDelegate.h"

@implementation GoogleMapInfoWindow
AppDelegate *appDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _spotNameLabel.font = appDelegate.smallFont;
        _spotNameLabel.layer.cornerRadius = 20.0f;
        _spotNameLabel.clipsToBounds = YES;
    }
    return self;
    
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
