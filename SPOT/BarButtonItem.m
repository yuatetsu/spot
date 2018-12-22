//
//  BarButtonItem.m
//  SPOT
//
//  Created by Truong Anh Tuan on 9/12/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "BarButtonItem.h"
#import "AppDelegate.h"

@implementation BarButtonItem
AppDelegate *appDelegate;

-(id)initWithButtonFrame:(CGRect)frame{
    
    if (self = [super init]) {
        _button = [[UIButton alloc]initWithFrame:frame];
        _button.backgroundColor = [UIColor clearColor];
        _button.titleLabel.font = appDelegate.normalFont;
        _button.titleLabel.textColor = [UIColor whiteColor];
        self.customView = _button;
    }
    
    return self;
}


-(void)setFontAndColorAndTextForButton:(UIFont *)font andColor:(UIColor *)color andText:(NSString *)text{
    
    _button.titleLabel.font = font;
    _button.titleLabel.textColor = color;
    _button.titleLabel.text = text;
}

-(void)setTitle:(NSString *)title{
    
    [self.button setTitle:title forState:UIControlStateNormal];
}

@end
