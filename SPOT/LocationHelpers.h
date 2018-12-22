//
//  LocationHelpers.h
//  SPOT
//
//  Created by Truong Anh Tuan on 9/11/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationHelpers : NSObject

+ (double)getDistanceByKmBetweenStartLat: (double)startLat startLng:(double)startLng endLat:(double)endLat endLng:(double)endLng;

@end
