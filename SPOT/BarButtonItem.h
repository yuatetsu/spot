//
//  BarButtonItem.h
//  SPOT
//
//  Created by Truong Anh Tuan on 9/12/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarButtonItem : UIBarButtonItem

@property (nonatomic, strong) UIButton *button;

-(id)initWithButtonFrame:(CGRect)frame;

-(void)setFontAndColorAndTextForButton:(UIFont *)font andColor:(UIColor *)color andText:(NSString *)text;

-(void)setTitle:(NSString *)title;

@end
