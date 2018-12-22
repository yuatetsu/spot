//
//  Tag.m
//  SPOT
//
//  Created by framgia on 7/15/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "Tag.h"
#import "SPOT.h"


@implementation Tag

@dynamic tag;
@dynamic spot_count;
@dynamic spot;

- (void)addSpotObject:(SPOT *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"spot" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"spot"] addObject:value];
    [self didChangeValueForKey:@"spot" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    NSLog(@"%d",self.spot_count.intValue);
    self.spot_count = [NSNumber numberWithInteger:[self.spot_count integerValue] + 1];
    NSLog(@"%d",self.spot_count.intValue);
    
}
- (void)removeSpotObject:(SPOT *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"spot" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"spot"] removeObject:value];
    [self didChangeValueForKey:@"spot" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    self.spot_count = [NSNumber numberWithInteger:[self.spot_count integerValue] - 1];
}
- (void)addSpot:(NSSet *)values
{
    [self willChangeValueForKey:@"spot" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    [[self primitiveValueForKey:@"spot"] unionSet:values];
    [self didChangeValueForKey:@"spot" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    self.spot_count = [NSNumber numberWithInteger:self.spot.count];
}
- (void)removeSpot:(NSSet *)values
{
    [self willChangeValueForKey:@"spot" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    [[self primitiveValueForKey:@"spot"] minusSet:values];
    [self didChangeValueForKey:@"spot" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    self.spot_count = [NSNumber numberWithInteger:self.spot.count];
}
@end
