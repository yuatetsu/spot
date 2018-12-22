//
//  ImageCacher.m
//  SPOT
//
//  Created by Truong Anh Tuan on 9/30/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "ImageCacher.h"
#import "ImageFetcher.h"

@interface ImageCacher() {
    NSMutableDictionary *imageDictionary;
    id <ImageFetcher> imageFetcher;
    NSLock *lock;
}

@end

@implementation ImageCacher

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
        
    }
    return self;
}

- (id)initWithFetcher:(id<ImageFetcher>)fetcher {
    self = [super init];
    if (self) {
        [self initialize];
        imageFetcher = fetcher;
    }
    return self;
}

- (void) initialize {
    imageDictionary = [NSMutableDictionary new];
    lock = [[NSLock alloc] init];
}

- (UIImage *)getImageByFileName:(NSString *)fileName {

    id obj = [imageDictionary objectForKey:fileName];

    if (obj) {
        return (UIImage *)obj;
    }
    return nil;
}

- (void)getImageByFileName:(NSString *)fileName completionHandler: (void (^)(BOOL success, UIImage *image))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            id obj = [imageDictionary objectForKey:fileName];
            
            __block UIImage *image;
            
            if (obj) {
                image = (UIImage *)obj;
            }
            else if (imageFetcher) {
                image = [imageFetcher load:fileName];
                if (image) {
                    
                    [imageDictionary setObject:image forKey:fileName];
                    
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                @autoreleasepool {
                    if (completionHandler) {
                        if (image) {
                            completionHandler(YES, image);
                        }
                        else {
                            completionHandler(NO, nil);
                        }
                    }
                    image = nil;
                }
            });
        }
        
    });
}

- (void)getImageByFileNames:(NSArray *)fileNames completionHandler: (void (^)(BOOL success, NSArray *images))completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            __block NSMutableArray *imageArray = [NSMutableArray new];
            for (NSString *fileName in fileNames) {
                @autoreleasepool {
                    id obj = [imageDictionary objectForKey:fileName];
                    
                    UIImage *image;
                    
                    if (obj) {
                        image = (UIImage *)obj;
                    }
                    else if (imageFetcher) {
                        image = [imageFetcher load:fileName];
                        if (image) {
                            
                            [imageDictionary setObject:image forKey:fileName];
                            
                        }
                        
                        [NSThread sleepForTimeInterval:0.1];
                    }
                    
                    if (image) {
                        [imageArray addObject:image];
                    }

                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                @autoreleasepool {
                    if (completionHandler) {
                        if (imageArray.count > 0) {
                            completionHandler(YES, imageArray);
                            imageArray = nil;
                        }
                        else {
                            completionHandler(NO, nil);
                        }
                    }
                }
            });
        }
        
    });
}

- (void)clearCache {
    @autoreleasepool {
        [imageDictionary removeAllObjects];
    }
}


@end
