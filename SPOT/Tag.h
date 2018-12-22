//
//  Tag.h
//  SPOT
//
//  Created by framgia on 7/15/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SPOT;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSNumber * spot_count;
@property (nonatomic, retain) NSSet *spot;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addSpotObject:(SPOT *)value;
- (void)removeSpotObject:(SPOT *)value;
- (void)addSpot:(NSSet *)values;
- (void)removeSpot:(NSSet *)values;

@end
