//
//  ItemViewBase.h
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemViewBase : UIView

@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UIImageView *secondImageView;
@property (weak, nonatomic) UITextView *textView;
@property (weak, nonatomic) UIView *separatorView;
@property (nonatomic) NSString *text;

- (id)initWithText:(NSString *)text;
- (id)initWithText:(NSString *)text andImage:(UIImage *)image;
- (id)initWithText:(NSString *)text andImage:(UIImage *)image andSecondImage:(UIImage *)secondImage;
- (void)updateLayout;

- (void)addImageView: (UIImage *)image;
- (void)addTextView: (NSString *)text withWidth:(float)width;
- (void)addSeparatorView ;

- (void)setDarkBottomLine;

@end
