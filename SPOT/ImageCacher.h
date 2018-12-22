//
//  ImageCacher.h
//  SPOT
//
//  Created by Truong Anh Tuan on 9/30/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageFetcher.h"

@interface ImageCacher : NSObject
- (UIImage *)getImageByFileName:(NSString *)fileName;

- (void)getImageByFileName:(NSString *)fileName completionHandler: (void (^)(BOOL success, UIImage *image))completionHandler;

- (void)getImageByFileNames:(NSArray *)fileNames completionHandler: (void (^)(BOOL success, NSArray *images))completionHandler;


- (void)clearCache;

- (id)initWithFetcher:(id<ImageFetcher>)fetcher;
@end
