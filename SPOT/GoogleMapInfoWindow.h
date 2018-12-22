//
//  GoogleMapInfoWindow.h
//  SPOT
//
//  Created by framgia on 9/12/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoogleMapInfoWindow : UIView

@property (strong, nonatomic) UIView *infoWindowView;
@property (strong, nonatomic) IBOutlet UITextView *spotNameLabel;
@property (strong, nonatomic) UILabel *addressLabel;

@end
