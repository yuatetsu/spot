 //
//  AppSettings.m
//  SPOT
//
//  Created by Truong Anh Tuan on 8/28/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "AppSettings.h"

@implementation AppSettings

+ (BOOL)namecardPriority {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL priority = [defaults boolForKey:@"NamecardPriority"];
    return priority;
}

+ (void)setNamecardPriority:(BOOL)priority {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:priority forKey:@"NamecardPriority"];
    [defaults synchronize];
}

+ (double) latitude {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    double lat = [defaults doubleForKey:@"Latitude"];
    return lat;
}

+ (void)setLatitude: (double)lat {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:lat forKey:@"Latitude"];
    [defaults synchronize];
}

+ (BOOL) usedMicrophone {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isUsed = [defaults boolForKey:@"UsedMicrophone"];
    return isUsed;
}

+ (void)setUsedMicrophone: (BOOL)isUsed {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isUsed forKey:@"UsedMicrophone"];
    [defaults synchronize];
}

+ (double) longitude {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    double lng = [defaults doubleForKey:@"Longitude"];
    return lng;
}

+ (void)setLongitude: (double)lng {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:lng forKey:@"Longitude"];
    [defaults synchronize];
}

+ (BOOL) isAuthorizedFoursquare {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isAuthorizedFoursquare"];
}

+ (void) setIsAuthorizedFoursquare:(BOOL)isAuthorizedFoursquare {
    [[NSUserDefaults standardUserDefaults]setBool:isAuthorizedFoursquare forKey:@"isAuthorizedFoursquare"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (NSString *) getFoursquareUser {
    NSString *foursquareUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"foursquareUser"];
    if (foursquareUser.length > 0) {
        return foursquareUser;
    }
    return nil;
}

+ (void) setFoursquareUser: (NSString *)foursquareUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:foursquareUser forKey:@"foursquareUser"];
    [defaults synchronize];
}

+ (BOOL) isSecondRun {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL secondRun = [defaults boolForKey:@"IsSecondRun"];
    return secondRun;
}

+ (void)setIsSecondRun:(BOOL)secondRun {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:secondRun forKey:@"IsSecondRun"];
    [defaults synchronize];
}
@end
