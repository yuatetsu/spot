//
//  SpotMemoItemView.h
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "ItemViewBase.h"
@class SPOT;

@protocol SpotMemoItemViewDelegate <NSObject>

- (void) didClickVoiceButton: (id)sender;

@end


@interface SpotMemoItemView : ItemViewBase

- (id)initWithText:(NSString *)text andHasMemo:(BOOL)hasMemo;

@property (weak, nonatomic) UIButton *voiceButton;

@property (weak, nonatomic) id <SpotMemoItemViewDelegate> delegate;

@property (nonatomic) SPOT *spot;

@end
