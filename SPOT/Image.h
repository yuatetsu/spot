//
//  Image.h
//  SPOT
//
//  Created by nguyen hai dang on 9/8/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SPOT;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * image_file_name;
@property (nonatomic, retain) NSNumber * is_name_card;
@property (nonatomic, retain) NSNumber * image_size;
@property (nonatomic, retain) NSString * origin_image_file_name;
@property (nonatomic, retain) SPOT *spot;

@end
