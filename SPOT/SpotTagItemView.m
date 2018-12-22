//
//  SpotTagItemView.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SpotTagItemView.h"
#import "AppDelegate.h"

@interface SpotTagItemView() {
}

@end

@implementation SpotTagItemView

AppDelegate *appDelegate;

- (id)initWithText:(NSString *)text andDarkBottomLine:(BOOL)darkBottomLine {
    
    self = [super initWithText:text andImage:[appDelegate getImageWithName:@"Tag"]];
    if (self) {
        self.textView.dataDetectorTypes = UIDataDetectorTypeLink;
        if (darkBottomLine) {
           [self setDarkBottomLine];
        }
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
