//
//  ItemViewBase.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "ItemViewBase.h"
#import "AppDelegate.h"
#import "MMMarkdown.h"

@implementation ItemViewBase

AppDelegate *appDelegate;

- (id)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        [self addTextView:text withWidth:300];
        [self setBounds:CGRectMake(0, 0, 320, self.textView.frame.size.height > 30 ? self.textView.frame.size.height : 30)];
        [self addSeparatorView];
    }
    
    return self;
}

- (id)initWithText:(NSString *)text andImage:(UIImage *)image {
    self = [super init];
    if (self) {
        @autoreleasepool {
            self.backgroundColor = [UIColor whiteColor];
            self.clipsToBounds = YES;
            [self addImageView:image];
            [self addTextView:text withWidth:280];
            [self setBounds:CGRectMake(0, 0, 320, self.textView.frame.size.height > 30 ? self.textView.frame.size.height : 30)];
            
            if (self.bounds.size.height > 40) {
                if (self.imageView) {
                    CGRect rect = self.imageView.frame;
                    rect.origin.y += 7;
                    self.imageView.frame = rect;
                }
            }
            
            [self addSeparatorView];
        }
    }
    
    return self;
}

- (id)initWithText:(NSString *)text andImage:(UIImage *)image andSecondImage:(UIImage *)secondImage {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        [self addImageView:image];
        [self addTextView:text withWidth:250];
        [self addSecondImageView:secondImage];
        [self setBounds:CGRectMake(0, 0, 320, self.textView.frame.size.height > 30 ? self.textView.frame.size.height : 30)];
        
        if (self.bounds.size.height > 40) {
            if (self.imageView) {
                CGRect rect = self.imageView.frame;
                rect.origin.y += 7;
                self.imageView.frame = rect;
            }
            if (self.secondImageView) {
                CGRect rect = self.secondImageView.frame;
                rect.origin.y += 7;
                self.secondImageView.frame = rect;
            }
        }
        
        [self addSeparatorView];
    }
    
    return self;
}

- (void)dealloc {
    [self removeFromSuperview];
}

- (void)addImageView: (UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 2, 28, 28)];
    imageView.image = image;
    imageView.opaque = YES;
    imageView.contentMode = UIViewContentModeCenter;
    self.imageView = imageView;
    [self addSubview:imageView];
}

- (void)addSecondImageView: (UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(284, 2, 28, 28)];
    imageView.image = image;
    imageView.opaque = YES;
    imageView.contentMode = UIViewContentModeCenter;
    self.secondImageView = imageView;
    [self addSubview:imageView];
}

- (void)addTextView: (NSString *)text withWidth:(float)width {
    UIFont *font = appDelegate.smallFont;
    CGRect rect = [self contentSizeOfText:text withWidth:width andFont:font];
    
    UITextView *textView = [[UITextView alloc] init];
    int x = width >= 300 ? 8 : 30;
    textView.frame = CGRectMake(x, -1, width, (int)rect.size.height + textView.textContainerInset.bottom + textView.textContainerInset.top + 1);
    textView.text = text;
    textView.opaque = YES;
    textView.font = font;
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.textColor = [UIColor darkGrayColor];
    self.textView = textView;
    [self addSubview:textView];
    
}

- (void)addSeparatorView {
    CGRect rect = [self bounds];
    rect.origin.y = rect.size.height - 1;
    rect.size.height = 1;
    UIView *separatorView = [[UIView alloc] initWithFrame:rect];
    separatorView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    separatorView.opaque = YES;
    self.separatorView = separatorView;
    [self addSubview:separatorView];
    
}

- (void)setDarkBottomLine {
    if (self.separatorView) {
        CGRect rect = [self bounds];
        rect.origin.y = rect.size.height - 2;
        rect.size.height = 2;
        self.separatorView.backgroundColor = [UIColor darkGrayColor];
        self.separatorView.frame = rect;
    }
}

- (CGRect) contentSizeOfText:(NSString *)text withWidth:(float)width andFont:(UIFont *)font {
    // in case of null string
    NSString *str = [NSString stringWithFormat:@"%@", text];
    
    CGSize boundingSize = CGSizeMake(width, CGFLOAT_MAX);
    return [str boundingRectWithSize:boundingSize
                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                           attributes:@{NSFontAttributeName:font}
                              context:nil];
    
}

- (void)updateLayout {
    CGRect rect = [self bounds];
    rect.origin.y = rect.size.height - 1;
    rect.size.height = 1;
    self.separatorView.frame = rect;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
