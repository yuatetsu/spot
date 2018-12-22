//
//  SPOT+Tag.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/3/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SPOT+Tag.h"
#import "Tag.h"

@implementation SPOT (Tag)
- (NSString *)tagText {
    NSString *tagStringConcat = @"";
    for (int i=0; i<self.tag.count; i++)
    {
        Tag *tag = [self.tag.allObjects objectAtIndex:i];
        tagStringConcat = [tagStringConcat stringByAppendingFormat:(i==self.tag.count-1)?@"%@":@"%@, ",tag.tag];
    }
    return tagStringConcat;
}
@end
