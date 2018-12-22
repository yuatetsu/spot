//
//  DetailsImageFetcher.h
//  SPOT
//
//  Created by Truong Anh Tuan on 9/30/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageFetcher.h"

@interface CenterModeImageFetcher : NSObject <ImageFetcher>
- (id)initWithFrameWidth: (float)frameWidth andFrameHeight: (float)frameHeight;
@end
