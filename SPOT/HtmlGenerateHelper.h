//
//  HtmlGenerateHelper.h
//  SPOT
//
//  Created by framgia on 8/27/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuideBook.h"
#import "SPOT.h"


@interface HtmlGenerateHelper : NSObject

+(NSString*)generateHtmlStringForSpot:(SPOT*)spot;
+(NSString*)generateHtmlStringForGuideBook:(GuideBook *)guideBook;

@end
