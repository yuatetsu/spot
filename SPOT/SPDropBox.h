//
//  SPDropBox.h
//  SPOT
//
//  Created by nguyen hai dang on 8/22/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHBgDropboxSync.h"
#import "Reachability.h"

@interface SPDropBox : NSObject

@property (nonatomic, strong) Reachability *reachability;

@property (nonatomic, assign) BOOL isSyncing;
@property (nonatomic, assign) BOOL suspendedWhileSyncing;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, assign) BOOL stop;

+ (instancetype)sharedInstance;

- (void)registerDropboxAPI;
- (void)showDropboxLoginViewInRootVC:(UIViewController*)rootVC;
- (void)logout;

- (void)startSync;
- (void)sync;
- (void)forceStopIfRunning;

-(void)increaseDeleteCount:(int)count;

-(void)deleteFileAtPath:(NSString*)filePath;

@end


