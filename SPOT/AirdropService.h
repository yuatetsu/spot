//
//  AirdropService.h
//  SPOT
//
//  Created by Truong Anh Tuan on 10/22/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SPOT;
@class GuideBook;

@interface AirdropService : NSObject

- (NSString *)sendSpot:(SPOT *)spot;
- (NSString *)sendGuideBook:(GuideBook *)guideBook;
- (void)importObjectFromFile:(NSString *)filePath;
- (void)importObjectFromUrl:(NSURL *)url;
@end
