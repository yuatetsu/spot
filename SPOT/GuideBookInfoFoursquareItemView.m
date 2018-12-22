//
//  GuideBookInfoFoursquareItemView.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "GuideBookInfoFoursquareItemView.h"
#import "AppDelegate.h"

@implementation GuideBookInfoFoursquareItemView

AppDelegate *appDelegate;

- (id)initWithText:(NSString *)text {
    
    self = [super initWithText:text andImage:[appDelegate getImageWithName:@"Foursquare"]];
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
