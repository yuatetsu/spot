//
//  BlackActivityIndicatorView.h
//  SPOT
//
//  Created by Bui Van Hung on 10/2/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlackActivityIndicatorView : UIActivityIndicatorView

- (id) initWithTopDistance : (float)top;
- (id) initWithTopDistance : (float)top andColor: (UIColor *)color;
- (id) initWithColor : (UIColor *)color;
@end
