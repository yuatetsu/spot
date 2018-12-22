//
//  SPDropBox.m
//  SPOT
//
//  Created by nguyen hai dang on 8/22/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SPDropBox.h"

#define ERROR_ALERT_NETWORK_NOTAVAILABLE_MESSAGE @"Error Sync Data. Please check your network."
#define ERROR_ALERT_NETWORK_NOTAVAILABLE_TITLE @"Error"

@interface SPDropBox()


@end

@implementation SPDropBox

+ (instancetype)sharedInstance {
    static SPDropBox *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(id)init{
    
    if(self= [super init]){
        
        _isSyncing = NO;
        _stop = NO;
        _alert = [[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commonShudownDropboxSync)name:@"CHBgDropboxSyncshutdown" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleFinishDeleteFiles) name:@"FinishDeletedFilesonDropbox" object:nil];
    }
    
    return self;
}

-(void)commonShudownDropboxSync{
    
    self.isSyncing = NO;
}

- (void)registerDropboxAPI{
    
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:API_KEY
                            appSecret:API_SECRET
                            root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];
}


-(void)startSync{
    
    if(_stop == NO){
        
        [CHBgDropboxSync start];
        _isSyncing = YES;
        [CHBgDropboxSync clearLastSyncData];
    }
}


-(void)forceStopIfRunning{
    
    [CHBgDropboxSync forceStopIfRunning];
    _isSyncing = NO;
}


-(void)sync{
    
    if(_stop == NO){
        
        _isSyncing = YES;
        [self checkReachibilityNetwork];
        
    }
    
}

-(void)checkReachibilityNetwork{
    
    __block BOOL isSyncingBlock = _isSyncing;
    __weak SPDropBox *selfPointer = self;
    __weak UIAlertView *selfAlertView = self.alert;
    
    // Allocate a reachability object
    self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    __weak Reachability *monitorNetSelf =  self.reachability;
    // Set the blocks
    self.reachability.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
            [CHBgDropboxSync start];
            isSyncingBlock = YES;
            [monitorNetSelf stopNotifier];
        });
    };
    
    self.reachability.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [selfPointer forceStopIfRunning];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncDropboxFailed" object:nil];
            
            if(!selfAlertView.visible){
                
                selfAlertView.message = ERROR_ALERT_NETWORK_NOTAVAILABLE_MESSAGE;
                selfAlertView.title = ERROR_ALERT_NETWORK_NOTAVAILABLE_TITLE;
                [selfAlertView show];
                [monitorNetSelf stopNotifier];
            }
        });
        
        
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [self.reachability startNotifier];
    
}



-(void)showDropboxLoginViewInRootVC:(UIViewController*)rootVC{
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:rootVC];
        NSLog(@"OpenFormLoginDropBox");
    }
    else
    {
        NSLog(@"Linked");
    }
}

-(void)logout{
    
    [[DBSession sharedSession]unlinkAll];
    [CHBgDropboxSync clearLastSyncData];
    [CHBgDropboxSync forceStopIfRunning];
    _isSyncing = NO;
}

-(void)deleteFileAtPath:(NSString *)filePath{
    
    [CHBgDropboxSync deleteFileAtPath:filePath];
}

-(void)handleFinishDeleteFiles{
    
    if(_stop == YES){
        
        _stop = NO;
        [self sync];
    }
}

-(void)increaseDeleteCount:(int)count{
    
    _stop = YES;
    [CHBgDropboxSync increaseDeleteCount:count];
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
