//
//  FontHelper.h
//  SPOT
//
//  Created by framgia on 8/27/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FontHelper : NSObject

+(void)setFontFamily:(NSString*)fontFamily forView:(UIView*)view andSubViews:(BOOL)isSubViews;

@end
