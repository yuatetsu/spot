//
//  iCloud+spotiCloudAddition.m
//  iCloudTest
//
//  Created by nguyen hai dang on 8/27/14.
//  Copyright (c) 2014 nguyen hai dang. All rights reserved.
//

#import "iCloud+spotiCloudAddition.h"
#import "ConciseKit.h"
#import "AppDelegate.h"

#define ERROR_ALERT_NETWORK_NOTAVAILABLE_MESSAGE @"Error Sync Data. Please check your network."
#define ERROR_ALERT_NETWORK_NOTAVAILABLE_TITLE @"Error"

#define ERROR_ALERT_ACCOUNT_NOTAVAILABLE_MESSAGE @"Please signin your iCloud account"
#define ERROR_ALERT_ACCOUNT_NOTAVAILABLE_TITLE @"Warning"

#define DELAY_SYNC dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC)


@implementation iCloud (spotiCloudAddition)


#pragma mark - Showing and hiding the syncing indicator

- (void)showWorking {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    if (workingLabel) return; // Already visible
    //
    //    UIWindow* w = [[[UIApplication sharedApplication] delegate] window];
    //    workingLabel = [[UILabel alloc] init];
    //    workingLabel.textAlignment = UITextAlignmentRight;
    //    workingLabel.text = @"Syncing... ";
    //    workingLabel.textColor = [UIColor whiteColor];
    //    int ht = 30;
    //    workingLabel.frame = CGRectMake(-120, 431-ht, 120, ht);
    //    workingLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    //    workingLabel.layer.cornerRadius = 10;
    //
    //    // Spinner
    //    UIActivityIndicatorView *s = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //    int gap = (workingLabel.frame.size.height - s.frame.size.height) / 2;
    //    s.frame = CGRectOffset(s.frame, 10+gap, gap);
    //    [s startAnimating];
    //    [workingLabel addSubview:s];
    //
    //    // Swoosh it in
    //    [w addSubview:workingLabel];
    //    [UIView animateWithDuration:0.3 animations:^{
    //        workingLabel.frame = CGRectOffset(workingLabel.frame, 110, 0);
    //    }];
}

- (void)hideWorking {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //    if (!workingLabel) return; // Already hidden
    //    [UIView animateWithDuration:0.3 animations:^{
    //        workingLabel.frame = CGRectMake(-workingLabel.frame.size.width, workingLabel.frame.origin.y, workingLabel.frame.size.width, workingLabel.frame.size.height);
    //    } completion:^(BOOL finished) {
    //        [workingLabel removeFromSuperview];
    //        workingLabel = nil;
    //    }];
}


#pragma mark - For keeping track of the last synced status of a file in the nsuserdefaults

// This 'last sync status' is used to justify deletions - that is all it is used for.
// Some thoughts on this 'last sync status' method of keeping track of deletions:
// What happens if we update the 'last sync' for B after updating A?
// Eg we overwrite the last sync state for B after we update A
// Then we've lost track of whether we should do a deletion, and will start mistakenly doing downloads/uploads
// Maybe only remove the last-sync status for each file one at a time as each file attempts deletion
// And at sync completion, grab and update all of them one more time in case something ever slips through the net

// Did the file exist locally at the end of the last sync?
- (BOOL)lastSyncExists:(NSString*)file {
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:LAST_SYNC_DEFAULTS_KEY] containsObject:file];
}

// Clear all last sync data on pairing change
- (void)lastSyncClear {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_SYNC_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Do a full scan of the files and stores them all in the defaults. Only to be used when the sync is totally complete
- (void)lastSyncCompletionRescan {
    [[NSUserDefaults standardUserDefaults] setObject:self.getLocalStatus.allKeys forKey:LAST_SYNC_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Before you attempt to delete a file locally or remotely, call this so that it'll never try to delete that file again.
// Do it before 'attempt delete' instead of 'confirm delete' just in case the delete fails, then we'll fall back to a 'download it again' state for the next sync, which is better than accidentally deleting it erroneously again later
- (void)lastSyncRemove:(NSString*)file {
    NSMutableArray* arr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:LAST_SYNC_DEFAULTS_KEY]];
    [arr removeObject:file];
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:LAST_SYNC_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Startup

- (void)startup {
    
    self.fileExitOnLocal = NO;
    [self checkReachibilityNetwork];
}

-(void)checkReachibilityNetwork{
    
    __weak UIAlertView *selfAlertView = self.alert;
    __weak iCloud *selfPointer = self;
    // Allocate a reachability object
    self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    __weak Reachability *monitorNetSelf =  self.reachability;
     [iCloud sharedCloud].isSyncing=YES;
    // Set the blocks
    self.reachability.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"REACHABLE!");
            
            selfPointer.stopRunning = NO;
            
            selfPointer.suspendedWhileSyncing = NO;
            
            selfPointer.verboseLogging = YES;
            
            [selfPointer showWorking];
            
            [[NSNotificationCenter defaultCenter]addObserver:selfPointer selector:@selector(handleSyncError) name:@"SyncIcloudError" object:nil];
            
            [selfPointer handleSync];
            
            [monitorNetSelf stopNotifier];
        });
    };
    
    self.reachability.unreachableBlock = ^(Reachability*reach)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"UNREACHABLE!");
            
            [selfPointer forceStopifRunning];
            
            NSLog(@"iCloudFailed");
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SynciCloudFailed" object:nil];
            
            if(!selfAlertView.visible){
                
                selfAlertView.message = ERROR_ALERT_NETWORK_NOTAVAILABLE_MESSAGE;
                selfAlertView.title = ERROR_ALERT_NETWORK_NOTAVAILABLE_TITLE;
                [selfAlertView show];
            }
            [monitorNetSelf stopNotifier];
        });
        
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [self.reachability startNotifier];
    
}



-(void)handleSync{
    
    self.remoteFiles = [NSMutableDictionary new];
    
    for(NSMetadataItem *item in self.query.results){
        
        [self.remoteFiles setObject:[item valueForAttribute:NSMetadataItemFSContentChangeDateKey] forKey:[item valueForAttribute:NSMetadataItemFSNameKey]];
    }
    
    self.localFiles = [self getLocalStatus];
    [self syncStepWithRemoteFiles:self.remoteFiles];
}


- (NSMutableDictionary*)getLocalStatus {
    NSMutableDictionary* localFiles = [NSMutableDictionary new];
    NSString* root = $.documentPath; // Where are we going to sync to
    NSMutableArray *pathsFolder = [NSMutableArray new];

    
    [pathsFolder addObject:IMAGE_PATH];
    [pathsFolder addObject:MEMO_VOICE_DATA_PATH];
    [pathsFolder addObject:SPOT_DATA_PATH];
    [pathsFolder addObject:GUIDE_BOOK_DATA_PATH];
    
    for (NSString *pathFiles in pathsFolder){
        
        
        for (NSString* item in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",root,pathFiles] error:nil]) {
            // Skip hidden/system files - you may want to change this if your files start with ., however dropbox errors on many 'ignored' files such as .DS_Store which you'll want to skip
            if ([item hasPrefix:@"."]) continue;
            
            // Get the full path and attribs
            NSString* itemPath = [[NSString stringWithFormat:@"%@/%@",root,pathFiles] stringByAppendingPathComponent:item];
            NSDictionary* attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:itemPath error:nil];
            
            BOOL isFile = $eql(attribs.fileType, NSFileTypeRegular);
            
            if (isFile) {
                [localFiles setObject:@[attribs.fileModificationDate ,pathFiles] forKey:item];
            }
        }
    }
    return localFiles;
}

-(NSMutableArray *)sortAllRemoteAndLocalFileResults:(NSMutableArray *)all{
    
    __block NSMutableArray *imageArr = [NSMutableArray new];
    __block NSMutableArray *voiceArr = [NSMutableArray new];
    __block NSMutableArray *spotArr = [NSMutableArray new];
    __block NSMutableArray *guideBookArr = [NSMutableArray new];
    __block  NSMutableArray *sortedArr = [NSMutableArray new];
    
    [all enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([((NSString*)obj).pathExtension isEqualToString:EXTENSION_RECORD]) {
            
            [voiceArr addObject:obj];
        }
        else if ([((NSString*)obj).pathExtension isEqualToString:@"spotData"]) {
            
            [spotArr addObject:obj];
        }
        else if ([((NSString*)obj).pathExtension isEqualToString:@"spotGuidebookData"]) {
            
            [guideBookArr addObject:obj];
        }
        else{
            
            [imageArr addObject:obj];
        }
    }];
    
    [sortedArr addObjectsFromArray:imageArr];
    [sortedArr addObjectsFromArray:voiceArr];
    [sortedArr addObjectsFromArray:spotArr];
    [sortedArr addObjectsFromArray:guideBookArr];
    
    return sortedArr;
}


- (BOOL)syncStepWithRemoteFiles:(NSMutableDictionary*)remoteFiles {
    
    if(self.stopRunning==NO){
    
        NSMutableArray *all = [NSMutableArray new]; // Get a complete list of all files both local and remote
        
        [all addObjectsFromArray:self.localFiles.allKeys];
        [all addObjectsFromArray:remoteFiles.allKeys];
        
        all = [self sortAllRemoteAndLocalFileResults:all];
        if (all.count) {
            for (NSString* file in all) {
                
                //                BOOL lastSyncExists = [self lastSyncExists:file];
                NSDate* local = [[self.localFiles objectForKey:file]objectAtIndex:0];
                NSString *localPath = [[self.localFiles objectForKey:file]objectAtIndex:1];
                NSDate* remote = [self.remoteFiles objectForKey:file];
                
                if (local && remote) {
                    
                    double delta = local.timeIntervalSinceReferenceDate - remote.timeIntervalSinceReferenceDate;
                    BOOL same = ABS(delta)<2;
                    if (!same) {
                        
                        if (local.timeIntervalSinceReferenceDate > remote.timeIntervalSinceReferenceDate) {
                            
                            [self startTaskUpload:file localPath:localPath];
                            self.syncingPath = $str(@"%@/%@",localPath,file);
                            return NO;
                            
                        } else {
                            
                            [self startTaskDownload:file];
                            self.fileExitOnLocal = YES;
                            self.syncingPath = $str(@"%@/%@",localPath,file);
                            return NO;
                        }
                        
                    }
                    else{
                        
                        [self.remoteFiles removeObjectForKey:file];
                        [self.localFiles removeObjectForKey:file];
                    }
                } else {
                    
                    if (remote && !local) {
                        
                        [self startTaskDownload:file];
                        return NO;
                        
                        //                        if (lastSyncExists) {
                        //
                        //                            [self lastSyncRemove:file];
                        //                            [self deleteDocumentWithName:file completion:^(NSError *error) {
                        //
                        //                            }];
                        //                            return NO;
                        //                        } else {
                        //                            // Download it
                        //                            [self startTaskDownload:file];
                        //                            self.syncingFile = [file copy];
                        //                            return NO;
                        //                        }
                    }
                    if (local && !remote) {
                        
                        //                        if (lastSyncExists) {
                        //
                        //                            [self lastSyncRemove:file];
                        //                            [self deleteDocumentWithName:file completion:^(NSError *error) {
                        //
                        //                            }]; // Delete locally
                        //                            return NO;
                        //                        } else {
                        //                            // Upload it. 'rev' should be nil here anyway.
                        //                            [self startTaskUpload:file];
                        //                            self.syncingFile = [file copy];
                        //                            return NO;
                        //                        }
                        
                        [self startTaskUpload:file localPath:localPath];
                        self.syncingPath = $str(@"%@/%@",localPath,file);
                        NSLog(@"SaveSpotToXML::MainThread:%@ CurrentThread:%@",[NSThread mainThread],[NSThread currentThread]);
                        return NO;
                    }
                    
                }
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CompleteSynciCloud" object:self];
    });
    
    [self handleSyncComplete];
    return YES; // Nothing needs doing
}



-(void)startTaskDownload:(NSString*)file{
    
    
        if(self.stopRunning == NO){
            
            [self retrieveCloudDocumentWithName:file completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
                
                dispatch_after(DELAY_SYNC, self.syncQueue, ^{
                    
            
                    NSLog(@"-------iCloud---download");
                    
                    if(self.stopRunning ==NO){
                        
                        NSString *fileType = [cloudDocument.fileURL.path pathExtension];
                        
                        NSLog(@"fileType:%@",fileType);
                        
                        __weak iCloud *iCloud_self = self;
                        
                        if (error) {
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"ErrorDownloadExistFile" object:nil];
                            if (error.code==516) {
                                
                                NSError *reWriteFileLocalError;
                                [self.remoteFiles removeObjectForKey:file];
                                [self.localFiles removeObjectForKey:file];
                                
                                NSString *pathOfFile;
                                
                                if ([fileType isEqualToString:@"spotData"]) {
                                    
                                    pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SPOT_DATA_PATH];
                                }
                                
                                else if ([fileType isEqualToString:EXTENSION_RECORD]){
                                    
                                    pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:MEMO_VOICE_DATA_PATH];
                                    
                                }
                                
                                else if ([fileType isEqualToString:@"spotGuidebookData"]){
                                    
                                    pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:GUIDE_BOOK_DATA_PATH];
                                    
                                }else{
                                    
                                    pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:IMAGE_PATH];
                                }
                                
                                [[NSFileManager defaultManager]removeItemAtPath:[pathOfFile stringByAppendingPathComponent:file] error:&reWriteFileLocalError];
                                
                                [iCloud_self retrieveCloudDocumentWithName:file completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
                                    
                                    if( [[NSFileManager defaultManager]createFileAtPath:[pathOfFile stringByAppendingPathComponent:file] contents:documentData attributes:@{NSFileModificationDate: cloudDocument.fileModificationDate}]){
                                        
                                        if(self.stopRunning == NO){
                                            
                                            if([self.remoteFiles objectForKey:file]||[self.localFiles objectForKey:file]){
                                                
                                                cloudDocument = nil;
                                                
                                                if ([fileType isEqualToString:@"spotData"]) {
                                                    
                                                    [(AppDelegate*)[UIApplication sharedApplication].delegate parseXMLSyncDataToSpotObject:[[NSURL alloc]initFileURLWithPath:[pathOfFile stringByAppendingPathComponent:file]] newEntity:!self.fileExitOnLocal];
                                                    
                                                    NSLog(@"---------------ParseSpot---------------------------");
                                                    
                                                }
                                                else if ([fileType isEqualToString:@"spotGuidebookData"]){
                                                    
                                                    [(AppDelegate*)[UIApplication sharedApplication].delegate parseXMLSyncDataToGuideBookObject:[[NSURL alloc]initFileURLWithPath:[pathOfFile stringByAppendingPathComponent:file]] newEntity:!self.fileExitOnLocal];
                                                    
                                                }
                                            }
                                            else{
                                                
                                                //    cloudDocument = nil;
                                                
                                                self.syncingPath = nil;
                                                [iCloud_self handleContinueDownloadFile];
                                                
                                            }
                                        }
                                    }
                                    
                                    self.syncingPath = nil;
                                    [self handleContinueDownloadFile];
                                }];
                            }
                            else{
                                
                                //                                [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Error Sync Data. Please check your network. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                                
                                [self.remoteFiles removeObjectForKey:file];
                                [self.localFiles removeObjectForKey:file];
                                
                                self.syncingPath = nil;
                                 [iCloud_self handleContinueDownloadFile];
                            }
                        }
                        else{
                            if(self.stopRunning ==NO){
                                
                                if([self.remoteFiles objectForKey:file]||[self.localFiles objectForKey:file]){
                                    
                                    NSString *pathOfFile;
                                    
                                    if ([fileType isEqualToString:@"spotData"]) {
                                        
                                        pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SPOT_DATA_PATH];
                                    }
                                    
                                    else if ([fileType isEqualToString:EXTENSION_RECORD]){
                                        
                                        pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:MEMO_VOICE_DATA_PATH];
                                        
                                    }
                                    else if ([fileType isEqualToString:@"spotGuidebookData"]){
                                        
                                        pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:GUIDE_BOOK_DATA_PATH];
                                        
                                    }else{
                                        
                                        pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:IMAGE_PATH];
                                    }
                                    
                                    if(![[NSFileManager defaultManager]createFileAtPath:[pathOfFile stringByAppendingPathComponent:file] contents:documentData attributes:@{NSFileModificationDate: cloudDocument.fileModificationDate}]){
                                        
                                        [[NSNotificationCenter defaultCenter]postNotificationName:@"SyncIcloudErrorWriteFileToLocal" object:nil];
                                    }
                                    
                                    if ([fileType isEqualToString:@"spotData"]) {
                                        
                                        [(AppDelegate*)[UIApplication sharedApplication].delegate parseXMLSyncDataToSpotObject:[[NSURL alloc]initFileURLWithPath:[pathOfFile stringByAppendingPathComponent:file]] newEntity:!self.fileExitOnLocal];
                                    }
                                    else if ([fileType isEqualToString:@"spotGuidebookData"]){
                                        
                                        [(AppDelegate*)[UIApplication sharedApplication].delegate parseXMLSyncDataToGuideBookObject:[[NSURL alloc]initFileURLWithPath:[pathOfFile stringByAppendingPathComponent:file]] newEntity:!self.fileExitOnLocal];
                                        
                                    }
                                    
                                    
                                    [self.remoteFiles removeObjectForKey:file];
                                    [self.localFiles removeObjectForKey:file];
                                    
                                    //     cloudDocument = nil;
                                    
                                    self.syncingPath = nil;
                                     [iCloud_self handleContinueDownloadFile];
                                }
                                else{
                                    //Do opensource bi loi nen phai fix
                                    
                                    //                            NSString *pathOfFile;
                                    //
                                    //                            if ([fileType isEqualToString:@"spotData"]) {
                                    //
                                    //                                pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SPOT_DATA_PATH];
                                    //                            }
                                    //                            else if ([fileType isEqualToString:@"spotGuidebookData"]){
                                    //
                                    //                                pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:GUIDE_BOOK_DATA_PATH];
                                    //
                                    //                            }else{
                                    //
                                    //                                pathOfFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:IMAGE_PATH];
                                    //                            }
                                    //
                                    //                            if(![[NSFileManager defaultManager]createFileAtPath:[pathOfFile stringByAppendingPathComponent:file] contents:documentData attributes:@{NSFileModificationDate: cloudDocument.fileModificationDate}]){
                                    //
                                    //                                [[NSNotificationCenter defaultCenter]postNotificationName:@"SyncIcloudErrorWriteFileToLocal" object:nil];
                                    //                            }
                                    
                                    //    cloudDocument = nil;
                                    
                                    self.syncingPath = nil;
                                    [iCloud_self handleContinueDownloadFile];
                                    
                                }
                            }
                        }
                        
                    }
                } );
            }];
        }
}



-(void)startTaskUpload:(NSString*)file localPath:(NSString*)localPath{
    
        
        if(self.stopRunning ==NO){
            
            __weak iCloud *iCloud_self = self;
            
            [self uploadLocalDocumentToCloudWithName:file localPath:localPath completion:^(NSError *error) {
                
                dispatch_after(DELAY_SYNC, self.syncQueue, ^{
                    
                    NSLog(@"-------iCloud---upload");
                    
                    if(self.stopRunning ==NO){
                        //Error file exists
                        if (error) {
                            
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"ErrorUploadExistFile" object:nil];
                            
                            if (error.code==516) {
                                
                                [iCloud_self deleteDocumentWithName:file completion:^(NSError *error) {
                                    
                                    [iCloud_self uploadLocalDocumentToCloudWithName:file localPath:localPath completion:^(NSError *error) {
                                        
                                        NSLog(@"%@",error.description);
                                        NSLog(@"Rewrite local to icloud");
                                        self.syncingPath = nil;
                                        
                                        if(!error){
                                            
                                            [self.remoteFiles removeObjectForKey:file];
                                            [self.localFiles removeObjectForKey:file];
                                        }
                                        
                                         [iCloud_self handleContinueUploadFile];
                                        
                                    }];
                                }];
                            }
                            else {
                                
                                NSLog(@"%@",error);
                                //
                                //                        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Error Sync Data. Please check your network. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                                
                                [self.remoteFiles removeObjectForKey:file];
                                [self.localFiles removeObjectForKey:file];
                                
                                self.syncingPath = nil;
                                [iCloud_self handleContinueUploadFile];
                            }
                        }
                        else{
                            
                            [self.remoteFiles removeObjectForKey:file];
                            [self.localFiles removeObjectForKey:file];
                            
                            self.syncingPath = nil;
                             [iCloud_self handleContinueUploadFile];
                            
                        }
                    }
                });
            }];
        }
}



- (void)internalShutdownForced {
    [self hideWorking];
}


// For clean shutdowns on sync success
- (void)internalShutdownSuccess {
    workingLabel.text = @"Done ";
    [self performSelector:@selector(hideWorking) withObject:nil afterDelay:0.5];
    
}


// For failed shutdowns
- (void)internalShutdownFailed {
    workingLabel.text = @"Failed ";
    [self performSelector:@selector(hideWorking) withObject:nil afterDelay:0.5];
    [self handleSyncError];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncIcloudError" object:nil];
    
}



#pragma mark - handle Sync



-(void)handleSyncComplete{
    
    [self hideWorking];
    [self lastSyncCompletionRescan];
    self.isSyncing = NO;
}



-(void)handleContinueUploadFile{
    
    [self syncStepWithRemoteFiles:self.remoteFiles];
    
}



-(void)handleContinueDownloadFile{
    
    [self syncStepWithRemoteFiles:self.remoteFiles];
    
    NSLog(@"download.....");
}



-(void)handleSyncError{
    
    NSLog(@"SyncError");
    [self internalShutdownFailed];
    
}


-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}


-(void)forceStopifRunning{
    
    self.isSyncing=NO;
    self.stopRunning = YES;
    [self hideWorking];
    self.remoteFiles = nil;
    self.localFiles = nil;
    [self.reachability stopNotifier];
}

@end
