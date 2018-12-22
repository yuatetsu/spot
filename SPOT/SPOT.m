//
//  SPOT.m
//  SPOT
//
//  Created by nguyen hai dang on 9/24/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SPOT.h"
#import "CheckIn.h"
#import "Country.h"
#import "GuideBook.h"
#import "GuideBookInfo.h"
#import "Image.h"
#import "Region.h"
#import "SPOT.h"
#import "Tag.h"


@implementation SPOT

@dynamic address;
@dynamic date;
@dynamic lat;
@dynamic lng;
@dynamic memo;
@dynamic month;
@dynamic pdf_file_name;
@dynamic phone;
@dynamic spot_description;
@dynamic spot_name;
@dynamic start_spot_lat;
@dynamic start_spot_lng;
@dynamic start_spot_name;
@dynamic thumbnail_file_name;
@dynamic traffic;
@dynamic url;
@dynamic uuid;
@dynamic checkin;
@dynamic country;
@dynamic guide_book_info;
@dynamic image;
@dynamic region;
@dynamic start_spot;
@dynamic start_spot_for_guide_book;
@dynamic tag;
@dynamic voice;
@dynamic is_need_create_xml;
@dynamic time_line_image;

- (NSDate *)monthDateFromDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    NSDate *monthDate = [calendar dateFromComponents:components];
    return monthDate;
}

- (void)setDate:(NSDate *)date {
    [self willChangeValueForKey:@"date"];
    [self setPrimitiveValue:date forKey:@"date"];
    [self didChangeValueForKey:@"date"];
    
    NSDate *month = [self monthDateFromDate:date];
    [self willChangeValueForKey:@"month"];
    [self setPrimitiveValue:month forKey:@"month"];
    [self didChangeValueForKey:@"month"];
}

@end
