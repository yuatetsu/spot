//
//  DetailMemoVoiceViewController.m
//  SPOT
//
//  Created by nguyen hai dang on 9/24/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "DetailMemoVoiceViewController.h"
#import "Voice.h"
#import "customButton.h"
#import "AppDelegate.h"

@interface DetailMemoVoiceViewController ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, strong) customButton *playBtn;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation DetailMemoVoiceViewController

AppDelegate *appDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
//- (IBAction)onBackButtonClick:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(spot = %@)", self.spot.objectID];
    self.fetchController = [Voice MR_fetchAllSortedBy:@"date" ascending:YES withPredicate:predicate groupBy:nil delegate:nil];
    
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//    titleLabel.text = [NSString stringWithFormat:@"Voice Memo"];
//    titleLabel.textColor = [UIColor whiteColor];
//    
//    titleLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_LARGE_SIZE];
//    
//    self.navigationItem.titleView= titleLabel;
//    [titleLabel sizeToFit];
//    
//    UIImage *backImage = [UIImage imageNamed:@"Slice_icon_82"];
//    UIBarButtonItem *navigationBackButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStyleBordered target:self action:@selector(onBackButtonClick:)];
////                                   initWithTitle:@"Flip"
////                                   style:UIBarButtonItemStyleBordered
////                                   target:self
////                                   action:@selector(onBackButtonClick:)];
//    self.navigationItem.leftBarButtonItem = navigationBackButton;
}

- (void)dealloc {
    
    NSLog(@"Memo details died.");
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.navigationController.toolbarHidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    self.navigationController.toolbarHidden = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"VoiceCount====%d",self.spot.voice.count);
    return self.spot.voice.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VOICE CELL"];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VOICE CELL"];
    }
    
    cell.selected = YES;
    
    Voice *voice = [self.fetchController objectAtIndexPath:indexPath];
    
    NSLog(@"%@",voice.uuid);
    
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
    timeLabel.font = appDelegate.normalFont;
    
    customButton *btn = (customButton*)[cell viewWithTag:3];
    [btn setSelectedImage:[UIImage imageNamed:@"Voicememo_slice_16_play_16"]];
    [btn setNonSelectImage:[UIImage imageNamed:@"Voicememo_slice_16"]];
    [btn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;

}


-(void)play:(customButton *)btn{
    
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
        
        NSLog(@"%@",self.fetchController.fetchedObjects);
        
        Voice *voice = [self.fetchController objectAtIndexPath:indexPath];
        
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        NSLog(@"%@",voice.uuid);
        
        
        NSURL *fileURL =[[NSURL alloc] initFileURLWithPath: [[appDelegate applicationDocumentsDirectoryForMemoVoice] stringByAppendingPathComponent:[voice.uuid stringByAppendingPathExtension:EXTENSION_RECORD]] ];
        
        _audioPlayer =
        [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                               error: nil];
        
        [_audioPlayer prepareToPlay];
        
        _audioPlayer.delegate = self;
        
        [_audioPlayer play];
        
    }
}

#pragma mark - AudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    _audioPlayer = nil;
    [_playBtn setSelectedStatus:NO];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player{
    
    _audioPlayer = nil;
    [_playBtn setSelectedStatus:NO];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    
    _audioPlayer = nil;
    [_playBtn setSelectedStatus:NO];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    
    _audioPlayer = nil;
    [_playBtn setSelectedStatus:NO];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
