//
//  iCloud+spotiCloudAddition.h
//  iCloudTest
//
//  Created by nguyen hai dang on 8/27/14.
//  Copyright (c) 2014 nguyen hai dang. All rights reserved.
//

#import "iCloud.h"

@interface iCloud (spotiCloudAddition)

- (NSDictionary*)getLocalStatus;

- (void)startup; 
- (void)internalShutdownSuccess;
- (void)internalShutdownFailed;
- (void)internalShutdownForced;
- (void)forceStopifRunning;



@end
