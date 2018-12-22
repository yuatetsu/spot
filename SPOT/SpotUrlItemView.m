//
//  SpotUrlItemView.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SpotUrlItemView.h"
#import "AppDelegate.h"

@implementation SpotUrlItemView

AppDelegate *appDelegate;

- (id)initWithText:(NSString *)text {
    
    self = [super initWithText:text andImage:[appDelegate getImageWithName:@"Url"]];
    if (self) {
        self.textView.dataDetectorTypes = UIDataDetectorTypeLink;
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
