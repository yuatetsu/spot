//
//  SettingsViewController.m
//  SPOT
//
//  Created by Truong Anh Tuan on 8/18/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "LTHPasscodeViewController.h"
#import "iCloud+spotiCloudAddition.h"
#import "SPDropBox.h"
#import "FoursquareUser.h"
#import "Tag.h"
#import "Image.h"
#import "Country.h"
#import "Region.h"

//#define MAX_RESULTS_COUNT (250)
#define YOUR_APP_STORE_ID 454638411 //Change this one to your ID

static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";
static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d";

@interface SettingsViewController () <LTHPasscodeViewControllerDelegate,AppDelegateEventDropboxAndiCloud,UITableViewDataSource,UITableViewDelegate,iCloudDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *syncDropBoxCell;

@property (weak, nonatomic) IBOutlet UISwitch *dropBoxSwitch;

@property (weak, nonatomic) IBOutlet UIButton *syncDropboxBtn;

@property (strong, nonatomic) IBOutlet UITableView *tableSetting;
@property (weak, nonatomic) IBOutlet UIButton *syncFoursquareButton;

@property (weak, nonatomic) IBOutlet UITableViewCell *synciCloudCell;

@property (weak, nonatomic) IBOutlet UISwitch *iCloudSwitch;

@property (weak, nonatomic) IBOutlet UIButton *synciCloudBtn;

@property (nonatomic, weak) AppDelegate *appDelegate;

@property (strong, nonatomic) FoursquareUser *foursquareUser;

@property (strong, nonatomic) SPOT *spot;

@property (weak, nonatomic) IBOutlet UITableViewCell *syncFoursquareButtonCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *changePasswordButtonCell;
@property (weak, nonatomic) IBOutlet UIButton *playsenseBtn;

@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UILabel *aboutTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *producerNameButton;

// query from db to increase performmance
//@property (strong, nonatomic) NSMutableDictionary *queryCountryDictionary;
//@property (strong, nonatomic) NSMutableDictionary *queryRegionDictionary;
//@property (strong, nonatomic) NSMutableDictionary *queryTagDictionary;

//@property (strong, nonatomic) NSManagedObjectContext *foursquareLocalContext;

//@property (strong, nonatomic) NSDictionary *foursquareCategories;
//
//@property (strong, nonatomic) NSDictionary *foursquareAllCategories;
//
//@property (strong, nonatomic) NSDictionary *userChosenCategories;
//
//@property (strong, nonatomic) NSArray *userChosenAllCategories;


@end

@implementation SettingsViewController

AppDelegate *appDelegate;

- (void)refreshUI {
	if ([LTHPasscodeViewController doesPasscodeExist]) {
        [self.passcodeSwitch setOn:YES animated:NO];
//        [self.changePasscodeButton setEnabled:YES];
	}
	else {
		[self.passcodeSwitch setOn:NO animated:NO];
//        [self.changePasscodeButton setEnabled:NO];
	}
    BOOL namecardPriority = [AppSettings namecardPriority];
    [self.prioritySwitch setOn:!namecardPriority];
    if (namecardPriority) {
        self.priorityLabel.text = @"Name Card";
    }
    else {
        self.priorityLabel.text = @"Photo";
    }
    
    if (appDelegate.isSyncingFoursquare) {
        [self.syncFoursquareButton setTitle:@"Syncing..." forState:UIControlStateNormal];
        [self.syncFoursquareButton setEnabled:NO];
    }
    
    [_tableSetting beginUpdates];
    [_tableSetting endUpdates];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    [self refreshUI];
    [super viewWillAppear:animated];
    [self checkSyncingWhenAppear];
}


-(void)checkSyncingWhenAppear{
    
    if([SPDropBox sharedInstance].isSyncing){
        [_syncDropboxBtn setTitle:@"Syncing..." forState:UIControlStateNormal];
        [_syncDropboxBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        [_syncDropboxBtn setTitle:@"Sync now" forState:UIControlStateNormal];
        [_syncDropboxBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    }
    
    if([iCloud sharedCloud].isSyncing){
        [_synciCloudBtn setTitle:@"Syncing..." forState:UIControlStateNormal];
        [_synciCloudBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        [_synciCloudBtn setTitle:@"Sync now" forState:UIControlStateNormal];
        [_synciCloudBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    }
    
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureSetting];
    [self refreshUI];

    self.playsenseBtn.titleLabel.attributedText = [self textTransformToUnderline:@"PLAYSENSE"];
    self.aboutTextLabel.text = @"Bring you to emotional moments.\nProvide Web service with\"OMOTENASHI\" spirit.";
    self.facebookBtn.titleLabel.attributedText = [self textTransformToUnderline:@"SPOT Facebook"];
    self.producerNameButton.titleLabel.attributedText = [self textTransformToUnderline:@"Tetsunori Yuasa"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"Settings died.");
}

- (NSMutableAttributedString *)textTransformToUnderline: (NSString *)stringToTransform
{
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:stringToTransform];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:(NSRange){0, [attrStr length]}];
    return attrStr;
}

-(void)configureSetting{
    
    [iCloud sharedCloud].delegate = self;
    
    _appDelegate=(AppDelegate*) [UIApplication sharedApplication].delegate;
    _appDelegate.delegate_dropbox_icloud = self;
    _dropBoxSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:@"syncDropbox"];
    _iCloudSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:@"synciCloud"];
    
    [self.foursquareSwitch setOn: [AppSettings isAuthorizedFoursquare]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCompleteSyncDropbox) name:@"CompleteSyncDropbox" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleFailedSyncDropbox) name:@"SyncDropboxFailed" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCompleteSynciCloud) name:@"CompleteSynciCloud" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleFailedSynciCloud) name:@"SynciCloudFailed" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSyncingDropbox) name:@"CHBgDropboxSyncing" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCompleteSyncFoursquare) name:@"completeSyncFoursquare" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleFailSyncFoursquare) name:@"failSyncFoursquare" object:nil];
    
    [_syncDropBoxCell setClipsToBounds:YES];
    [_synciCloudCell setClipsToBounds:YES];
    
    [self.syncFoursquareButtonCell setClipsToBounds:YES];
    [self.changePasswordButtonCell setClipsToBounds:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onChangePasscodeButtonClicked:(id)sender {
    [self showLockViewForChangingPasscode];
}

- (void)onPasscodeSwitchValueChanged:(id)sender {
    UISwitch *s = (UISwitch *)sender;
    if ([s isOn]) {
        [self showLockViewForEnablingPasscode];
    }
    else {
        [self showLockViewForTurningPasscodeOff];
    }
}

- (void)onBackButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)onPrioritySwitchValueChanged:(id)sender {
    BOOL namecardPriority = ![self.prioritySwitch isOn];
    [AppSettings setNamecardPriority:namecardPriority];
    if (namecardPriority) {
        self.priorityLabel.text = @"Name Card";
    }
    else {
        self.priorityLabel.text = @"Photo";
    }
}


# pragma mark - LTHPasscodeViewController Delegates

- (void)passcodeViewControllerWillClose {
	[self refreshUI];
}

- (void)showLockViewForEnablingPasscode {
    LTHPasscodeViewController *controller = [LTHPasscodeViewController sharedUser];
//    [controller.navigationController setNavigationBarHidden:NO];
	[controller showForEnablingPasscodeInViewController:self asModal:NO];
    
}


- (void)showLockViewForChangingPasscode {
    LTHPasscodeViewController *controller = [LTHPasscodeViewController sharedUser];
//    [controller.navigationController setNavigationBarHidden:NO];
	[controller showForChangingPasscodeInViewController:self asModal:NO];
    
}


- (void)showLockViewForTurningPasscodeOff {
    LTHPasscodeViewController *controller = [LTHPasscodeViewController sharedUser];
//    [controller.navigationController setNavigationBarHidden:NO];
	[controller showForDisablingPasscodeInViewController:self asModal:NO];
    
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - dropbox


- (IBAction)syncDropbox:(UIButton*)sender {
    
    if(![SPDropBox sharedInstance].isSyncing){
        
        [[SPDropBox sharedInstance] sync];
        [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}


- (IBAction)dropBoxEnable:(UISwitch *)sender {
    
    if(sender.on){
        
        if (!_iCloudSwitch.on && ![self.foursquareSwitch isOn]) {
            
            [[SPDropBox sharedInstance] showDropboxLoginViewInRootVC:self.navigationController];
            
            UIBarButtonItem *topNavButton = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
            
            [topNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  appDelegate.largeFont, NSFontAttributeName,
                                                  [UIColor colorWithRed:0.0f green:128.0f/255.0f blue:1.0f alpha:1.0f], NSForegroundColorAttributeName,
                                                  nil]
                                        forState:UIControlStateNormal];
        }
        else{
            NSString *alertMessage = [NSString stringWithFormat:@"Please turn off %@ sync before use Dropbox sync", [self.iCloudSwitch isOn]?@"iCloud": @"Foursquare"];
            [[[UIAlertView alloc]initWithTitle:@"Warning" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
            
            sender.on = NO;
        }
        
    }
    else
    {
        [[SPDropBox sharedInstance] logout];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"syncDropbox"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [_tableSetting beginUpdates];
        [_tableSetting endUpdates];
        [[SPDropBox sharedInstance] forceStopIfRunning];
        [self stopAutoSyncDropbox];
    }
}


-(void)stopAutoSyncDropbox{
    
    [_appDelegate.timerSyncDropbox invalidate];
    [[SPDropBox sharedInstance]forceStopIfRunning];
}


-(void)handleCompleteSyncDropbox{
    [_syncDropboxBtn setTitle:@"Sync now" forState:UIControlStateNormal];
    [_syncDropboxBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    
}


-(void)handleFailedSyncDropbox{
    [_syncDropboxBtn setTitle:@"Sync now" forState:UIControlStateNormal];
    [_syncDropboxBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    
}

-(void)handleSyncingDropbox{
    [_syncDropboxBtn setTitle:@"Syncing..." forState:UIControlStateNormal];
    [_syncDropboxBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

}


#pragma mark - iCloud


-(void)handleCompleteSynciCloud{
    [_synciCloudBtn setTitle:@"Sync now" forState:UIControlStateNormal];
    [_synciCloudBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    
      NSLog(@"---------End=========");
}


-(void)handleFailedSynciCloud{
    [_synciCloudBtn setTitle:@"Sync now" forState:UIControlStateNormal];
    [_synciCloudBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
}


- (IBAction)iCloudEnable:(UISwitch *)sender {
    
    if(sender.on){
        
        if (!_dropBoxSwitch.on && ![self.foursquareSwitch isOn]) {
            
            [self animateSwitchiCloud:YES];
            
            if ([[iCloud sharedCloud]checkCloudAvailability]) {
                
                [_appDelegate creatTimerForSync];
            }
            else{
                
                [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please signin your iCloud account" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
            }
        }
        else {
            NSString *alertMessage = [NSString stringWithFormat:@"Please turn off %@ sync before use iCloud sync", [self.dropBoxSwitch isOn]? @"Dropbox": @"Foursquare"];
            [[[UIAlertView alloc]initWithTitle:@"Warning" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
            
            sender.on = NO;
        }
    }
    else
    {
        
        [self animateSwitchiCloud:NO];
        [[iCloud sharedCloud] forceStopifRunning];
        [_synciCloudBtn setTitle:@"Sync now" forState:UIControlStateNormal];
        [_synciCloudBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self stopAutoSynciCloud];
    }
}

-(void)stopAutoSynciCloud{
    
    [_appDelegate.timerSynciCloud invalidate];
    [[iCloud sharedCloud]forceStopifRunning];
}



-(void)animateSwitchiCloud:(BOOL)icloudEnable{
    
    [[NSUserDefaults standardUserDefaults]setBool:icloudEnable forKey:@"synciCloud"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [_tableSetting beginUpdates];
    [_tableSetting endUpdates];
}



- (IBAction)synciCloud:(id)sender {
    
    if ([[iCloud sharedCloud]checkCloudAvailability]) {
        
        if(![iCloud sharedCloud].isSyncing){
            [_synciCloudBtn setTitle:@"Syncing..." forState:UIControlStateNormal];
            [_synciCloudBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
            NSLog(@"---------Start=========");
            
            [[iCloud sharedCloud]startup];
        }
    }
    else{
        
        [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please signin your iCloud account" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}



-(void)iCloudFileConflictBetweenCloudFile:(NSDictionary *)cloudFile andLocalFile:(NSDictionary *)localFile{
    
    [[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"SyncingError appear conflict between local files:%@ and icloud files:%@ ",localFile,cloudFile] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    [[iCloud sharedCloud]internalShutdownFailed];
}


#pragma mark - App delegate

-(void)handleEventLoginFromDropbox:(BOOL)sucess{
    
    [_dropBoxSwitch setOn:sucess];
    
    [[NSUserDefaults standardUserDefaults]setBool:sucess forKey:@"syncDropbox"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if(sucess){
        
        [_tableSetting beginUpdates];
        [_tableSetting endUpdates];
        [_appDelegate creatTimerForSync];
    }
    
    UIBarButtonItem *topNavButton = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    
    [topNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          appDelegate.largeFont, NSFontAttributeName,
                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                          nil]
                                forState:UIControlStateNormal];
}

-(void)handleAutoSyncDropbox{
    [_syncDropboxBtn setTitle:@"Syncing..." forState:UIControlStateNormal];
    [_syncDropboxBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
}


-(void)handleAutoSynciCloud{
    [_synciCloudBtn setTitle:@"Syncing..." forState:UIControlStateNormal];
    [_synciCloudBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

#pragma mark - TableView Setting

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 64.0f;
    }
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableView.frame.size.width, 44.0)];
    sectionHeaderView.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    float headerYposition = 10.0;
    if (section == 0) {
        headerYposition = 30.0;
    }
    UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(7, headerYposition, sectionHeaderView.frame.size.width, 24.0)];
    headerLabel.font = appDelegate.normalFont;
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    
//    headerLabel.textAlignment = NSTextAlignmentCenter;
    [sectionHeaderView addSubview:headerLabel];
    
    switch (section) {
        case 0:
            headerLabel.text = @"Sync";
            return sectionHeaderView;
            break;
        case 1:
            headerLabel.text = @"About";
            return sectionHeaderView;
            break;
        case 2:
            headerLabel.text = @"Credits";
            return sectionHeaderView;
            break;
        default:
            break;
    }
    
    return sectionHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 3&&indexPath.section == 0) {
        
        if (![[NSUserDefaults standardUserDefaults]boolForKey:@"syncDropbox"]) {
            return 0.0f;
        }
        
    }
    else if (indexPath.row ==1&&indexPath.section ==0){
        
        if (![[NSUserDefaults standardUserDefaults]boolForKey:@"synciCloud"]) {
            return 0.0f;
        }
    }
    else if (indexPath.row==5 && indexPath.section==0) {
        if (![AppSettings isAuthorizedFoursquare]) {
            return 0.0f;
        }
    }
    else if (indexPath.row==7 && indexPath.section==0) {
        if (![LTHPasscodeViewController doesPasscodeExist]) {
            return 0.0f;
        }
    }
    else if (indexPath.row==0 && indexPath.section==1) {
        return 110.0f;
    }
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *normalLeftFontLabel = (UILabel *) [cell viewWithTag:12];
    UILabel *normalRightFontLabel = (UILabel *) [cell viewWithTag:14];
    
    UILabel *smallLeftFontLabel = (UILabel *) [cell viewWithTag:10];
    UILabel *smallRightFontLabel = (UILabel *) [cell viewWithTag:9];
    UIButton *normalFontButton = (UIButton *) [cell viewWithTag:13];
    UIButton *rateAppFontButton = (UIButton *) [cell viewWithTag:16];
    UIButton *smallLeftFontButton = (UIButton *) [cell viewWithTag:11];
    UIButton *smallRightFontButton = (UIButton *) [cell viewWithTag:8];
    normalLeftFontLabel.font = appDelegate.normalFont;
    normalRightFontLabel.font = appDelegate.normalFont;
    normalFontButton.titleLabel.font = appDelegate.normalFont;
    rateAppFontButton.titleLabel.font = appDelegate.normalFont;
    smallLeftFontLabel.font = appDelegate.smallFont;
    smallRightFontLabel.font = appDelegate.smallFont;
    smallLeftFontButton.titleLabel.font = appDelegate.smallFont;
    smallRightFontButton.titleLabel.font = appDelegate.smallFont;
    return cell;
}


//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
//}

- (IBAction)foursquareButtonSync:(UIButton *)sender {
    if ([AppSettings isAuthorizedFoursquare]) {
        [self.syncFoursquareButton setTitle:@"Syncing..." forState:UIControlStateNormal];
        self.syncFoursquareButton.enabled = NO;
        [appDelegate startSyncFoursquare];
        //        [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(handleCompleteSyncFoursquare) userInfo:nil repeats:NO];
    }
}

- (IBAction)foursquareSwitchValueChanged:(id)sender {
    UISwitch *foursquareSwitch = (UISwitch *)sender;
//    [foursquareSwitch setEnabled:NO];
    if ([appDelegate isSyncingFoursquare]) {
//        if ([AppSettings isAuthorizedFoursquare]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"System message" message:@"SPOT is getting data from Foursquare, please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [foursquareSwitch isOn]?[foursquareSwitch setOn:NO]:[foursquareSwitch setOn:YES];
            return;
//        }
//        else {
//            [foursquareSwitch setEnabled:NO];
////            appDelegate.isSyncingFoursquare = NO;
//            return;
//        }
    }
    if([foursquareSwitch isOn]) {
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        
        if (networkStatus == NotReachable) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"System message" message:@"Can not login to Foursquare \nPlease check your internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [foursquareSwitch setOn:NO];
            return;
        }
        if ([self.dropBoxSwitch isOn] || [self.iCloudSwitch isOn]) {
            NSString *alertMessage = [NSString stringWithFormat:@"Please turn off %@ sync before use Foursquare sync", [self.dropBoxSwitch isOn]?@"Dropbox":@"iCloud"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [self.foursquareSwitch setOn:NO];
        } else {
            UIBarButtonItem *topNavButton = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
            
            [topNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:appDelegate.largeFont, NSFontAttributeName,
                                                  [UIColor colorWithRed:0.0f green:128.0f/255.0f blue:1.0f alpha:1.0f], NSForegroundColorAttributeName,
                                                  nil]
                                        forState:UIControlStateNormal];
            __weak SettingsViewController *blockSaveSelf = self;
            // login to Foursquare
            
            @try {
                
                [self.foursquareSwitch setOn:NO];
                
                @autoreleasepool {
                    [Foursquare2 authorizeWithCallback:^(BOOL success, id result) {
                        UIBarButtonItem *topNavButton = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
                        
                        [topNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              appDelegate.largeFont, NSFontAttributeName,
                                                              [UIColor whiteColor], NSForegroundColorAttributeName,
                                                              nil]
                                                    forState:UIControlStateNormal];
                        SettingsViewController *innerSelf = blockSaveSelf;
                        
                        if (success) {
                            NSLog(@"login success");
                            
                            [AppSettings setIsAuthorizedFoursquare:YES];
                            [innerSelf.foursquareSwitch setOn:YES];
                            [innerSelf.tableSetting beginUpdates];
                            [innerSelf.tableSetting endUpdates];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"System message" message:@"Do you want to download checkin data from your Foursquare account?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"Download", nil];
                            [alert show];
                        } else {
                            NSLog(@"login fail");
                            [innerSelf.foursquareSwitch setOn:NO];
                            appDelegate.isSyncingFoursquare = NO;
                        }
                    }];
                }
            }
            @catch (NSException *exception) {
                SettingsViewController *innerSelf = blockSaveSelf;
                
                NSLog(@"login fail. Exception: %@", exception);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"System message" message:@"System cannot login Foursquare now, please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [innerSelf.foursquareSwitch setOn:NO];
                appDelegate.isSyncingFoursquare = NO;
                
            }
            @finally {
                
            }
            
        }
    } else {
        NSLog(@"Foursquare logout");
        [Foursquare2 removeAccessToken];
        
        [AppSettings setIsAuthorizedFoursquare:NO];
        [AppSettings setFoursquareUser:nil];
        
        [_tableSetting beginUpdates];
        [_tableSetting endUpdates];
    }
}

- (void)handleCompleteSyncFoursquare
{
    NSLog(@"handleCompleteSyncFoursquare");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.syncFoursquareButton setTitle:@"Sync now" forState:UIControlStateNormal];
        [self.syncFoursquareButton setEnabled:YES];
    });
}

- (void)handleFailSyncFoursquare
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"System message" message:@"Fail to sync from Foursquare, please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.syncFoursquareButton setTitle:@"Sync now" forState:UIControlStateNormal];
        [self.syncFoursquareButton setEnabled:YES];
    });
}



- (IBAction)playsenseButtonClick:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://playsense.me"];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (IBAction)facebookButtonClick:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/SPOT.voyage?ref=bookmarks"];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (IBAction)onProducerNameButtonClicked:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://yuatetsu.in/blog/"];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (IBAction)appStoreRate:(id)sender {
    NSLog(@"rate app");
    
    static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/app/spot-create-guidebook-easily/id936453516";
    
    NSURL *url = [NSURL URLWithString:iOSAppStoreURLFormat];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)  // Cancel Button
    {
        [self.syncFoursquareButton setTitle:@"Sync now" forState:UIControlStateNormal];
        self.syncFoursquareButton.enabled = YES;
    }
    else {
        [self.syncFoursquareButton setTitle:@"Syncing..." forState:UIControlStateNormal];
        self.syncFoursquareButton.enabled = NO;
        [appDelegate startSyncFoursquare];
    }
}

@end
