//
//  SPOT+Traffic.m
//  SPOT
//
//  Created by Truong Anh Tuan on 9/11/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SPOT+Traffic.h"
#import "LocationHelpers.h"
#import "AppDelegate.h"


@implementation SPOT (Traffic)

AppDelegate *appDelegate;


- (NSString *)trafficText {
    
    if (self.start_spot_name) {
        if (self.start_spot_lat.floatValue && self.start_spot_lng.floatValue && self.lat.floatValue && self.lng.floatValue ){
            
            return [NSString stringWithFormat:@"Distance from %@: %.1f km", self.start_spot_name, [LocationHelpers getDistanceByKmBetweenStartLat:self.start_spot_lat.doubleValue startLng:self.start_spot_lng.doubleValue endLat:self.lat.doubleValue endLng:self.lng.doubleValue]];
            
        }
        else {
            return self.start_spot_name;
        }
    }
    else {
        return @"";
    }
    
    
    return nil;
}

- (NSString *)trafficDescription {
    
    if (self.start_spot_name) {
        if ((self.start_spot_lat || self.start_spot_lng) && (self.lat || self.lng )){
            
            if (self.traffic.intValue) {
                return [NSString stringWithFormat:@"Distance from %@: %.1f km by %@", self.start_spot_name, [LocationHelpers getDistanceByKmBetweenStartLat:self.start_spot_lat.doubleValue startLng:self.start_spot_lng.doubleValue endLat:self.lat.doubleValue endLng:self.lng.doubleValue] , appDelegate.transportationList[self.traffic.intValue]];
            }
            else {
                return [NSString stringWithFormat:@"Distance from %@: %.1f km", self.start_spot_name, [LocationHelpers getDistanceByKmBetweenStartLat:self.start_spot_lat.doubleValue startLng:self.start_spot_lng.doubleValue endLat:self.lat.doubleValue endLng:self.lng.doubleValue]];
            }
        }
        else {
            return self.start_spot_name;
        }
    }
    else {
        if (self.traffic.intValue) {
            return appDelegate.transportationList[self.traffic.intValue];
        }
        else {
            return @"";
        }
        
        return @"";
    }
    
    
    return nil;
}
@end
