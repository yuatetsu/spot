//
//  LocationHelpers.m
//  SPOT
//
//  Created by Truong Anh Tuan on 9/11/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "LocationHelpers.h"
#import <CoreLocation/CoreLocation.h>

@implementation LocationHelpers

+ (double)getDistanceByKmBetweenStartLat: (double)startLat startLng:(double)startLng endLat:(double)endLat endLng:(double)endLng {
    
    CLLocation *startSpotLocation = [[CLLocation alloc] initWithLatitude:startLat longitude:startLng];
    
    CLLocation *destinationSpotLocation = [[CLLocation alloc] initWithLatitude:endLat longitude:endLng];
    
    CLLocationDistance distance = [destinationSpotLocation distanceFromLocation:startSpotLocation];
    return distance / 1000;
}
@end
