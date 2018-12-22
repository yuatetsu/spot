//
//  StringHelpers.h
//  SPOT
//
//  Created by Truong Anh Tuan on 8/26/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringHelpers : NSObject

+ (NSString *)stringByTrimmingWhitespace:(NSString *)str;
+ (NSString *)stringByRemovingAllWhitespace:(NSString *)str;
+ (BOOL)isNilOrWhitespace:(NSString *)str;
+ (NSString *)htmlString:(NSString *)str;
+ (NSString *)validFileNameFromString: (NSString *)str;

@end
