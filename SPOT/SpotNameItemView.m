//
//  SpotNameItemView.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SpotNameItemView.h"
#import "AppDelegate.h"

@implementation SpotNameItemView

AppDelegate * appDelegate;

- (id)initWithText:(NSString *)text {
    
    self = [super initWithText:text andImage:[appDelegate getImageWithName:@"SpotName"]];
    if (self) {
        
    }
    return self;
}

@end
