//
//  GuideBook+Addition.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "GuideBook+Addition.h"
#import "GuideBookInfo.h"

@implementation GuideBook (Addition)

- (int) dayCount {
    int count = 0;
    if (self.guide_book_info != nil) {
        for (GuideBookInfo *info in self.guide_book_info) {
            if (info.day_from_start_day.intValue > 0) {
                count++;
            }
        }
    }
    
    return count;
}

@end
