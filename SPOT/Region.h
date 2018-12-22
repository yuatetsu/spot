//
//  Region.h
//  SPOT
//
//  Created by framgia on 7/23/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SPOT;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSSet *spot;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addSpotObject:(SPOT *)value;
- (void)removeSpotObject:(SPOT *)value;
- (void)addSpot:(NSSet *)values;
- (void)removeSpot:(NSSet *)values;

@end
