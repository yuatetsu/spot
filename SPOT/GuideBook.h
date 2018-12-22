//
//  GuideBook.h
//  SPOT
//
//  Created by framgia on 7/15/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GuideBookInfo, SPOT;

@interface GuideBook : NSManagedObject

@property (nonatomic, retain) NSNumber * foursquare_spot_lat;
@property (nonatomic, retain) NSNumber * foursquare_spot_lng;
@property (nonatomic, retain) NSString * foursquare_spot_name;
@property (nonatomic, retain) NSString * guide_book_name;
@property (nonatomic, retain) NSString * pdf_file_name;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSSet *guide_book_info;
@property (nonatomic, retain) SPOT *start_spot;
@property (nonatomic, retain) NSNumber * start_spot_selected_from_foursquare;
@property (nonatomic, retain) NSString * uuid;
@end

@interface GuideBook (CoreDataGeneratedAccessors)

- (void)addGuide_book_infoObject:(GuideBookInfo *)value;
- (void)removeGuide_book_infoObject:(GuideBookInfo *)value;
- (void)addGuide_book_info:(NSSet *)values;
- (void)removeGuide_book_info:(NSSet *)values;

@end
