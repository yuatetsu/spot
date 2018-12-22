//
//  MemoVoiceSpotViewController.m
//  SPOT
//
//  Created by nguyen hai dang on 9/23/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "MemoVoiceSpotViewController.h"
#import "RecorderView.h"
#import "Voice.h"
#import "AppDelegate.h"
#import "SPDropBox.h"
#import "iCloud+spotiCloudAddition.h"
#import "customButton.h"

@interface MemoVoiceSpotViewController ()<NSFetchedResultsControllerDelegate,AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) RecorderView *recorderView;
@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, strong) customButton *playBtn;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, assign) BOOL isRecording;

@end

@implementation MemoVoiceSpotViewController

AppDelegate *appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    _playBtn = nil;
    // Do any additional setup after loading the view.
    //    audioSession.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCompleteRecord) name:FINISH_RECORD_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleFailedRecord) name:RECORD_FAILED_NOTIFICATION object:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(spot = %@)", self.spot.objectID];
    self.fetchController = [Voice MR_fetchAllSortedBy:@"date" ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    
    self.navigationItem.hidesBackButton = YES;
    
    [self setEditing:YES];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.text = [NSString stringWithFormat:@"Voice Memo"];
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.font = appDelegate.largeFont;
    
    self.navigationItem.titleView= titleLabel;
    [titleLabel sizeToFit];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = doneBtn;
    
    _isRecording = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleAcceptUseMicrophone) name:@"AcceptMicrophoneValidNotification" object:nil];
}

- (void)dealloc {
    NSLog(@"MemoVoice died.");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)back:(UIBarButtonItem *)btn{
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)handleAcceptUseMicrophone {
    
    [self showRecorderView];
    self.isRecording = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addVoice:(id)sender {
    
    __weak MemoVoiceSpotViewController *selfPointer =  self;
    __block UIAlertView *alertView = _alertView;
    
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]){
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            
            if (!granted) {
                
                alertView =  [[UIAlertView alloc]initWithTitle:@"Start using Spot voice memo" message:@"Open Settings > Privacy > Microphone > Spot and turn on the microphone." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alertView show];
                
            }
            else{
                
                //Stop play when recorder
                
                if (selfPointer.audioPlayer) {
                    [selfPointer.audioPlayer stop];
                    selfPointer.audioPlayer = nil;
                }
                
                if (selfPointer.playBtn) {
                    [selfPointer.playBtn setSelectedStatus:NO];
                }
                
                if (selfPointer.spot.voice.count<5) {
                    if (!selfPointer.recorderView) {
                        
                        //Write code show record view in this block the recorderview is transparent in first accept use microphone use Notification to trick
                        
                        if([AppSettings usedMicrophone]){
                            
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"AcceptMicrophoneValidNotification" object:nil];
                        }else{
                            
                            [AppSettings setUsedMicrophone:YES];
                        }
                    }
                }
                else{
                    
                    if (alertView||!alertView.visible) {
                        
                        alertView =  [[UIAlertView alloc]initWithTitle:@"Just only 5 voice memos!" message:@"You can save max 5 voice memos in a time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        
                        [alertView show];
                    }
                }
            }
            
        }];
    }
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.tableView reloadData];
    
}


- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    if(_recorderView){
        
        if(_recorderView.recorder.isRecording){
            
            [_recorderView.timer invalidate];
            
            _recorderView.timer = nil;
            
            [self handleCompleteRecord];
        }
        else{
            
            [self dismissRecorderView];
            
            _isRecording = NO;
        }
        
    }
}


- (void)showRecorderView {
    
    NSLog(@"ShowRecordView");
    
    _recorderView = [[UINib nibWithNibName:@"RecorderView" bundle:nil] instantiateWithOwner:self options:nil][0];
    
    [self.view.window addSubview:_recorderView];
    
    _recorderView.frame = CGRectMake(_recorderView.frame.origin.x, _recorderView.frame.size
                                     .height+[UIScreen mainScreen].bounds.size.height, _recorderView.frame.size.width, _recorderView.frame.size.height);
    
    //    [self.window addSubview:self.actionSheetSimulationView];
    
    [UIView animateWithDuration:0.35 animations:^{
        
        _recorderView.frame = CGRectMake(_recorderView.frame.origin.x,[UIScreen mainScreen].bounds.size.height- _recorderView.frame.size
                                         .height        , _recorderView.frame.size.width, _recorderView.frame.size.height);
        
    }];
}

- (void)dismissRecorderView {
    
    __weak MemoVoiceSpotViewController *weakSelf = self;
    
    [UIView animateWithDuration:0.35
                     animations:^{
                         
                         weakSelf.recorderView.frame = CGRectMake(weakSelf.recorderView.frame.origin.x, weakSelf.recorderView.frame.size
                                                                  .height+[UIScreen mainScreen].bounds.size.height, weakSelf.recorderView.frame.size.width, weakSelf.recorderView.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         
                         [weakSelf.recorderView removeFromSuperview];
                         weakSelf.recorderView = nil;
                         
                     }];
    
}


- (void)handleCompleteRecord{
    
    Voice *voice  = [Voice MR_createEntity];
    voice.spot = self.spot;
    voice.uuid = [_recorderView.recorder.url.path.lastPathComponent stringByDeletingPathExtension];
    voice.time = [NSNumber  numberWithInt:_recorderView.time];
    voice.date = [NSDate date];
    [self.spot addVoiceObject:voice];
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    [magicalContext MR_saveOnlySelfAndWait];
    
    AppDelegate *delegateApp = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegateApp saveSpotToXMLForSync:self.spot];
    
    //    });
    
    [self.tableView reloadData];
    
    [self dismissRecorderView];
    
    _isRecording = NO;
}

-(void)handleFailedRecord{
    
    _isRecording = NO;
    [self dismissRecorderView];
}


#pragma mark - tableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSLog(@"voiceCount---%d",self.spot.voice.count);
    return self.spot.voice.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VOICE CELL"];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VOICE CELL"];
    }
    
    cell.selected = YES;
    
    Voice *voice = [self.fetchController objectAtIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *dateString = [dateFormatter stringFromDate:voice.date];
    
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:1];
    dateLabel.text = [dateString componentsSeparatedByString:@" "].firstObject;
    
    dateLabel.font = appDelegate.normalFont;
    
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d",voice.time.intValue/60,voice.time.intValue%60];
    
    UILabel *timeLabel = (UILabel*)[cell viewWithTag:2];
    timeLabel.text = timeString;
    timeLabel.font =appDelegate.normalFont;
    
    customButton *btn = (customButton*)[cell viewWithTag:3];
    [btn setSelectedImage:[UIImage imageNamed:@"Voicememo_slice_16_play_16"]];
    [btn setNonSelectImage:[UIImage imageNamed:@"Voicememo_slice_16"]];
    [btn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


- (void)play:(customButton*)btn{
    
    if (!_isRecording) {
        
        if([_playBtn isEqual:btn]){
            
            if (!_audioPlayer) {
                
                [btn setSelectedStatus:YES];
                
                UITableViewCell *cell;
                
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    
                    cell = (UITableViewCell *) btn.superview.superview;
                }
                else{
                    
                    cell = (UITableViewCell *) btn.superview.superview.superview;
                }
                
                NSIndexPath *indexPath  = [self.tableView indexPathForCell:cell];
                
                Voice *voice = [self.fetchController objectAtIndexPath:indexPath];
                
                AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                
                NSURL *fileURL =[[NSURL alloc] initFileURLWithPath: [[appDelegate applicationDocumentsDirectoryForMemoVoice] stringByAppendingPathComponent:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD]] ];
                
                _audioPlayer =
                [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                       error: nil];
                
                [_audioPlayer prepareToPlay];
                
                _audioPlayer.delegate = self;
                
                [_audioPlayer play];
                
            }else{
                
                [_audioPlayer stop];
                
                [btn setSelectedStatus:NO];
                
                _audioPlayer = nil;
            }
        }else{
            
            if (_playBtn) {
                [_playBtn setSelectedStatus:NO];
            }
            
            _playBtn = btn;
            
            [btn setSelectedStatus:YES];
            
            UITableViewCell *cell;
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                
                cell = (UITableViewCell *) btn.superview.superview;
            }
            else{
                
                cell = (UITableViewCell *) btn.superview.superview.superview;
            }
            
            NSIndexPath *indexPath  = [self.tableView indexPathForCell:cell];
            
            Voice *voice = [self.fetchController objectAtIndexPath:indexPath];
            
            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            
            NSURL *fileURL =[[NSURL alloc] initFileURLWithPath: [[appDelegate applicationDocumentsDirectoryForMemoVoice] stringByAppendingPathComponent:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD]] ];
            
            _audioPlayer =
            [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                   error: nil];
            
            [_audioPlayer prepareToPlay];
            
            _audioPlayer.delegate = self;
            
            [_audioPlayer play];
            
        }
    }
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        Voice *voice = [self.fetchController objectAtIndexPath:indexPath];
        
        if (_audioPlayer) {
            
            if ([voice.uuid isEqualToString:[_audioPlayer.url.path.lastPathComponent stringByDeletingPathExtension]] ) {
                
                [_audioPlayer stop];
                _audioPlayer = nil;
                
                if (_playBtn) {
                    
                    [_playBtn setSelectedStatus:NO];
                }
            }
        }
        
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSError *errorDeleteLocal;
        
        if([[NSUserDefaults standardUserDefaults]boolForKey:@"syncDropbox"]){
            
            [[SPDropBox sharedInstance]deleteFileAtPath:[NSString stringWithFormat:@"/%@",[MEMO_VOICE_DATA_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",voice.uuid,EXTENSION_RECORD]]]];
            
        }
        else if([[NSUserDefaults standardUserDefaults]boolForKey:@"synciCloud"]){
            
            [[iCloud sharedCloud].remoteFiles removeObjectForKey:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD]];
            
            [[iCloud sharedCloud].localFiles removeObjectForKey:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD]];
            
            [[iCloud sharedCloud]deleteDocumentWithName:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD] completion:^(NSError *error) {
                
                if(error){
                    
                    NSLog(@"Could not delete file oniCloud -:%@ ",[error localizedDescription]);
                }
            }];
            
        }
        
        [[NSFileManager defaultManager]removeItemAtPath:[[appDelegate applicationDocumentsDirectoryForMemoVoice] stringByAppendingPathComponent:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD]] error:&errorDeleteLocal];
        
        
        if (errorDeleteLocal) {
            
            NSLog(@"Could not delete file onLocal -:%@ ",[errorDeleteLocal localizedDescription]);
        }
        
        [voice MR_deleteEntity];
        
        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
        // save
        [magicalContext MR_saveOnlySelfAndWait];
        
        AppDelegate *delegateApp = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [delegateApp saveSpotToXMLForSync:self.spot];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    NSLog(@"controllerWillChangeContent");
    //    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSLog(@"didChangeObject");
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            //            NSLog(@"NSFetchedResultsChangeInsert");
            //            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"NSFetchedResultsChangeDelete");
            [self.tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"NSFetchedResultsChangeUpdate");
            //            [self configureCell:(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath inTableView:tableView];
            break;
            
        case NSFetchedResultsChangeMove:
            //            NSLog(@"NSFetchedResultsChangeMove");
            //            [tableView deleteRowsAtIndexPaths:[NSArray
            //                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //            [tableView insertRowsAtIndexPaths:[NSArray
            //                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    NSLog(@"didChangeSection");
    UITableView *tableView = self.tableView;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            //            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    NSLog(@"controllerDidChangeContent");
    //  [self.tableView endUpdates];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - AudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_audioPlayer stop];
    _audioPlayer = nil;
    [_playBtn setSelectedStatus:NO];
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player{
    
    [_audioPlayer stop];
    _audioPlayer = nil;
    [_playBtn setSelectedStatus:NO];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    
    [_audioPlayer stop];
    _audioPlayer = nil;
    [_playBtn setSelectedStatus:NO];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    
    [_audioPlayer stop];
    _audioPlayer = nil;
    [_playBtn setSelectedStatus:NO];
}


@end
