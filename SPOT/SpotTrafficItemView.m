//
//  SpotTrafficItemView.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SpotTrafficItemView.h"
#import "AppDelegate.h"

@implementation SpotTrafficItemView

AppDelegate *appDelegate;

- (id)initWithText:(NSString *)text andTrafficIconIndex:(int)index {
    self = [super initWithText:text andImage:[appDelegate getImageWithName:@"Traffic"] andSecondImage:[appDelegate getTrafficIconByType:index]];
    if (self) {
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
