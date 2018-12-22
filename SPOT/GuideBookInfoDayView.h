//
//  GuideBookInfoDayView.h
//  SPOT
//
//  Created by Truong Anh Tuan on 10/6/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GuideBookInfoDayViewDelegate <NSObject>

- (void)dayButtonClicked : (int)day sender:(id)sender;

@end

@interface GuideBookInfoDayView : UIView

@property (nonatomic) int dayFromStartDay;
@property (nonatomic) int dayCount;

@property (weak, nonatomic) id <GuideBookInfoDayViewDelegate> delegate;

- (id)initWithDayFromStartDay:(int)dayFromStartDay andDayCount:(int)dayCount;

@end
