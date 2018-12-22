//
//  StackPanel.h
//  SPOT
//
//  Created by Truong Anh Tuan on 10/10/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StackPanelDelegate <NSObject>

- (void)didAddView:(UIView *)view;


@end

@interface StackPanel : UIView

@property (weak, nonatomic) id <StackPanelDelegate> delegate;
//@property (nonatomic, copy) NSMutableArray *children;
@property (nonatomic) float minHeight;


- (void)addView:(UIView *)view;
- (void)updateLayout;
- (void)updateLayoutOfView:(UIView *)view;

@end
