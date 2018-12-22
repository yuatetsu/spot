//
//  SPOT.h
//  SPOT
//
//  Created by nguyen hai dang on 9/24/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CheckIn, Country, GuideBook, GuideBookInfo, Image, Region, SPOT, Tag;

@interface SPOT : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSDate * month;
@property (nonatomic, retain) NSString * pdf_file_name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * spot_description;
@property (nonatomic, retain) NSString * spot_name;
@property (nonatomic, retain) NSNumber * start_spot_lat;
@property (nonatomic, retain) NSNumber * start_spot_lng;
@property (nonatomic, retain) NSString * start_spot_name;
@property (nonatomic, retain) NSString * thumbnail_file_name;
@property (nonatomic, retain) NSNumber * traffic;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSSet *checkin;
@property (nonatomic, retain) Country *country;
@property (nonatomic, retain) NSSet *guide_book_info;
@property (nonatomic, retain) NSSet *image;
@property (nonatomic, retain) Region *region;
@property (nonatomic, retain) SPOT *start_spot;
@property (nonatomic, retain) NSSet *start_spot_for_guide_book;
@property (nonatomic, retain) NSSet *tag;
@property (nonatomic, retain) NSSet *voice;
@property (nonatomic, assign) BOOL is_need_create_xml;

@property (nonatomic, strong) NSString *time_line_image;

@end

@interface SPOT (CoreDataGeneratedAccessors)

- (void)addCheckinObject:(CheckIn *)value;
- (void)removeCheckinObject:(CheckIn *)value;
- (void)addCheckin:(NSSet *)values;
- (void)removeCheckin:(NSSet *)values;

- (void)addGuide_book_infoObject:(GuideBookInfo *)value;
- (void)removeGuide_book_infoObject:(GuideBookInfo *)value;
- (void)addGuide_book_info:(NSSet *)values;
- (void)removeGuide_book_info:(NSSet *)values;

- (void)addImageObject:(Image *)value;
- (void)removeImageObject:(Image *)value;
- (void)addImage:(NSSet *)values;
- (void)removeImage:(NSSet *)values;

- (void)addStart_spot_for_guide_bookObject:(GuideBook *)value;
- (void)removeStart_spot_for_guide_bookObject:(GuideBook *)value;
- (void)addStart_spot_for_guide_book:(NSSet *)values;
- (void)removeStart_spot_for_guide_book:(NSSet *)values;

- (void)addTagObject:(Tag *)value;
- (void)removeTagObject:(Tag *)value;
- (void)addTag:(NSSet *)values;
- (void)removeTag:(NSSet *)values;

- (void)addVoiceObject:(NSManagedObject *)value;
- (void)removeVoiceObject:(NSManagedObject *)value;
- (void)addVoice:(NSSet *)values;
- (void)removeVoice:(NSSet *)values;

@end
