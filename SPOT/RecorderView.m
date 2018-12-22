//
//  RecorderView.m
//  SPOT
//
//  Created by nguyen hai dang on 9/24/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "RecorderView.h"
#import "AppDelegate.h"

@implementation RecorderView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)awakeFromNib{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _time = 0;
    
    NSString *tempDir = appDelegate.applicationDocumentsDirectoryForMemoVoice;
    NSString *soundFilePath =
    [tempDir stringByAppendingFormat: @"/%@.%@",[[NSUUID UUID] UUIDString],EXTENSION_RECORD];
    
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
 
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    
    NSDictionary *recordSettings =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
     [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
     [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
     [NSNumber numberWithInt: AVAudioQualityMax],
     AVEncoderAudioQualityKey,
     nil];
    NSError *error = nil;
    self.recorder =
    [[AVAudioRecorder alloc] initWithURL: newURL
                                settings: recordSettings
                                   error: &error];
    
    self.recorder.delegate = self;
    
    if (error)
    {
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Cannot record please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        
    } else {
        [self.recorder prepareToRecord];
    }
    
}

- (IBAction)recordAction:(id)sender {
    
    if (self.recorder.isRecording) {
        
        NSLog(@"FinishRecord");
        [ self.recorder stop];
        [_timer invalidate];
        _timer = nil;
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:FINISH_RECORD_NOTIFICATION object:nil];
    }
    else{
        
        NSLog(@"StartRecord");
        _startImageView.hidden = YES;
      [UIView animateWithDuration:0.4 animations:^{
          
          _stopImageView.alpha  = 1;
      }];
        [self.recorder record];
       _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleRecording:) userInfo:nil repeats:YES];
    }
    
}


-(void)handleRecording:(NSTimer *)timer{
    
    if (_time<60) {
        
        _time = _time + 1;
        
        int secondRemain = 60-_time;
        
        int minuteRemain = 0;
        
        _secondLabel.text = [NSString stringWithFormat:@"%02d", secondRemain];
        _minuteLabel.text = [NSString stringWithFormat:@"%02d", minuteRemain];
        
    }
    else{
        
        [_recorder stop];
        [timer invalidate];
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:FINISH_RECORD_NOTIFICATION object:nil];
    }
}




- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    
    [_recorder stop];
    [_timer invalidate];
    [_recorder deleteRecording];
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:RECORD_FAILED_NOTIFICATION object:nil];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    
    [_recorder stop];
    [_timer invalidate];
    [_recorder deleteRecording];
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:RECORD_FAILED_NOTIFICATION object:nil];
    
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags NS_AVAILABLE_IOS(6_0){
    
    [_recorder stop];
    [_timer invalidate];
    [_recorder deleteRecording];
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:RECORD_FAILED_NOTIFICATION object:nil];
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags NS_DEPRECATED_IOS(4_0, 6_0){
    
    [_recorder stop];
    [_timer invalidate];
    [_recorder deleteRecording];
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:RECORD_FAILED_NOTIFICATION object:nil];
}


- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder NS_DEPRECATED_IOS(2_2, 6_0){
    
    [_recorder stop];
    [_timer invalidate];
    [_recorder deleteRecording];
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:RECORD_FAILED_NOTIFICATION object:nil];;
    
}



@end
