//
//  GuideBookInfo.h
//  SPOT
//
//  Created by framgia on 7/15/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GuideBook, SPOT;

@interface GuideBookInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * info_type;
@property (nonatomic, retain) NSNumber * day_from_start_day;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * trafic_time;
@property (nonatomic, retain) GuideBook *guide_book;
@property (nonatomic, retain) SPOT *spot;

@end
