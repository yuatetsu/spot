//
//  StackPanel.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/10/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "StackPanel.h"

@implementation StackPanel {
    float contentHeight;
}

-(id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame   {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
//    self.children = [[NSMutableArray alloc] init];
    contentHeight = 0;
    self.minHeight = self.bounds.size.height;
}

- (void)addView:(UIView *)view {
    [self addChild:view];
}

- (void)addChild:(UIView *)view {
    // add subview
//    [self.children addObject:view];
    view.frame = CGRectMake(0, contentHeight, view.frame.size.width, view.frame.size.height);
    [self addSubview:view];
    contentHeight += view.frame.size.height;
   
    [self updateFrameWithHeight:contentHeight];
    
    // call delegate method
    [self.delegate didAddView:view];
}

- (void)updateFrameWithHeight:(float)height {
    CGRect rect = self.frame;
    float h = self.minHeight > height ? self.minHeight : height;
    rect.size.height = h;
    self.frame = rect;

}

- (void)updateLayout {
    contentHeight = 0;
    for (int i = 0; i < self.subviews.count; i++) {
        UIView *v = self.subviews[i];
        v.frame = CGRectMake(0, contentHeight, v.frame.size.width, v.frame.size.height);
        contentHeight += v.frame.size.height;
    }
    
    [self updateFrameWithHeight:contentHeight];
}

- (void)updateLayoutOfView:(UIView *)view {
   contentHeight = 0;
    BOOL needUpdateFrame = NO;
    for (int i = 0; i < self.subviews.count; i++) {
        UIView *v = self.subviews[i];
        if (needUpdateFrame) {
            v.frame = CGRectMake(0, contentHeight, v.frame.size.width, v.frame.size.height);
        }
        contentHeight += v.frame.size.height;
        if (v == view) {
            needUpdateFrame = YES;
        }
    }
    
    [self updateFrameWithHeight:contentHeight];
}

- (void)dealloc {
    self.delegate = nil;
    NSLog(@"Stack Panel died.");
}

@end
