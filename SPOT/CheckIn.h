//
//  CheckIn.h
//  SPOT
//
//  Created by framgia on 7/15/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SPOT;

@interface CheckIn : NSManagedObject

@property (nonatomic, retain) NSDate * last_checkin_date;
@property (nonatomic, retain) SPOT *spot;

@end
