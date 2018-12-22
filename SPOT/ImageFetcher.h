//
//  ImageFetcher.h
//  SPOT
//
//  Created by Truong Anh Tuan on 9/30/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageFetcher <NSObject>

- (UIImage *)load:(NSString *)fileName;

@end
