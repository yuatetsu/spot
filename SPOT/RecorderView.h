//
//  RecorderView.h
//  SPOT
//
//  Created by nguyen hai dang on 9/24/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecorderView : UIView  <AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioRecorder  *recorder;

@property (weak, nonatomic) IBOutlet UILabel *minuteLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@property (assign, nonatomic) int time;

@property (strong, nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIImageView *startImageView;

@property (weak, nonatomic) IBOutlet UIImageView *stopImageView;


@end
