//
//  Voice.h
//  SPOT
//
//  Created by nguyen hai dang on 9/24/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SPOT;

@interface Voice : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) SPOT *spot;

@end
