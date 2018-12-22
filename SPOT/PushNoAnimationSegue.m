//
//  PushNoAnimationSegue.m
//  SPOT
//
//  Created by Truong Anh Tuan on 9/24/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "PushNoAnimationSegue.h"

@implementation PushNoAnimationSegue

-(void) perform{
    [[[self sourceViewController] navigationController] pushViewController:[self   destinationViewController] animated:NO];
}

@end
