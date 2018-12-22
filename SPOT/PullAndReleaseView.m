//
//  PullAndReleaseView.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "PullAndReleaseView.h"
#import "AppDelegate.h"

@implementation PullAndReleaseView
AppDelegate *appDelegate;

- (id)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 320, 40);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, self.frame.size.width, 21)];
        label.font = appDelegate.smallFont;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        self.label = label;
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
