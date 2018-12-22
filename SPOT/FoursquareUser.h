//
//  FoursquareUser.h
//  SPOT
//
//  Created by Bui Van Hung on 8/28/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FoursquareUser : NSManagedObject

@property (nonatomic, retain) NSDate * last_checkin;
@property (nonatomic, retain) NSString * username;

@end
