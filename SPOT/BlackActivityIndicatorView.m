//
//  BlackActivityIndicatorView.m
//  SPOT
//
//  Created by Bui Van Hung on 10/2/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "BlackActivityIndicatorView.h"

@implementation BlackActivityIndicatorView

- (id) initWithTopDistance : (float)top
{
    self = [super init];
    self.center = (CGPoint){[[[UIApplication sharedApplication] delegate] window].frame.size.width/2, top};
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.color = [UIColor blackColor];
    return self;
}

- (id) initWithTopDistance : (float)top andColor: (UIColor *)color
{
    self = [super init];
    self.center = (CGPoint){[[[UIApplication sharedApplication] delegate] window].frame.size.width/2, top};
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.color = color;
    return self;
}

- (id) initWithColor : (UIColor *)color {
    self = [super init];
    self.center = (CGPoint){[[[UIApplication sharedApplication] delegate] window].frame.size.width/2, [[[UIApplication sharedApplication] delegate] window].frame.size.height/2};
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.color = color;
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
