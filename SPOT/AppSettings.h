//
//  AppSettings.h
//  SPOT
//
//  Created by Truong Anh Tuan on 8/28/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject

+ (BOOL) namecardPriority;
+ (void)setNamecardPriority:(BOOL)priority;
+ (double) latitude;
+ (void)setLatitude: (double)lat;
+ (double) longitude;
+ (void)setLongitude: (double)lng;
+ (BOOL) isAuthorizedFoursquare;
+ (void) setIsAuthorizedFoursquare:(BOOL)isAuthorizedFoursquare;
+ (NSString *) getFoursquareUser;
+ (void) setFoursquareUser: (NSString *)foursquareUser;
+ (BOOL) usedMicrophone;
+ (void) setUsedMicrophone: (BOOL)isUsed;


+ (BOOL) isSecondRun;
+ (void)setIsSecondRun:(BOOL)secondRun;

@end
