//
//  SPOT+Image.m
//  SPOT
//
//  Created by Truong Anh Tuan on 9/26/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SPOT+Image.h"
#import "Image.h"

@implementation SPOT (Image)

- (NSString *) firstImageFileName {
    if (self.image.count > 0) {
        if (![StringHelpers isNilOrWhitespace:self.time_line_image]) {
            return self.time_line_image;
        }
        else {
            BOOL nameCardPriority = [AppSettings namecardPriority];
            NSArray *array = [self.image allObjects];
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"is_name_card" ascending: !nameCardPriority];
            NSArray* sortedArray = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            return [[sortedArray firstObject] image_file_name];
        }
        
    }
    
    return nil;
}

- (NSArray *) sortedImages {
    BOOL nameCardPriority = [AppSettings namecardPriority];
    NSArray *array = [self.image allObjects];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"is_name_card" ascending: !nameCardPriority];
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    // if spot has thumbnail
    if (![StringHelpers isNilOrWhitespace:self.time_line_image]) {
        NSMutableArray *mutableSortedArray = [NSMutableArray new];
  
        for (Image *image in self.image) {
            if (image.image_file_name == self.time_line_image) {
                [mutableSortedArray insertObject:image atIndex:0];
            }
            else{
                [mutableSortedArray addObject:image];
            }
        }
   
        return mutableSortedArray;
    }
    
    else {
        return sortedArray;
    }
}


@end
