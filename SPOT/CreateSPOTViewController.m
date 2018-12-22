//
//  CreateSPOTViewController.m
//  SPOT
//
//  Created by framgia on 7/17/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "CreateSPOTViewController.h"
#import "AppDelegate.h"
#import "SPOT.h"
#import "Image.h"
#import "Tag.h"
#import "Country.h"
#import "Region.h"
#import "DateRegisterationViewController.h"
#import "TrafficRegisterationViewController.h"
#import "AddressRegisterationViewController.h"
#import "TagRegisterationViewController.h"
#import "PlaceHolderTextView.h"
#import "Foursquare2.h"
#import "MemoVoiceSpotViewController.h"
#import "KeyboardToolbarView.h"
#import "Reachability.h"

@interface CreateSPOTViewController () <AddressRegisterationViewControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate, KeyboardToolbarViewDelegate>
{
}

@property (strong, nonatomic) NSString *venueID;
@property (assign, nonatomic) BOOL isCheckinFoursquare;
@property (strong, nonatomic) NSMutableArray *initiateSearchResultArray;
@property (assign, nonatomic) BOOL needSave;
@property (weak, nonatomic) IBOutlet UIButton *voiceMemoButton;

@property (nonatomic) KeyboardToolbarView *inputAccessoryView;
@property (nonatomic) BOOL isAllowClick;
@property (nonatomic) BOOL shouldExportXml;
@property (nonatomic) UIBarButtonItem *defaultFoursquareButton;
@property (nonatomic) UIView *currentControl;
@property (nonatomic) BOOL isCreateNewSpot;

@end

@implementation CreateSPOTViewController

AppDelegate* appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.needSave = NO;
    
    appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.createSPOTViewController = self;
    
    
    PlaceHolderTextView *memoTextField = (PlaceHolderTextView *)self.memoTextView;
    memoTextField.placeholder = @"Memo";
    
    if (!self.spot){
        self.spot = [SPOT MR_createEntity];
        [self setupNewSpot];
    }
    else if (!self.spot.uuid) {
        [self setupNewSpot];
    }
    else {
        self.title = @"Edit SPOT";
        self.isCreateNewSpot = NO;
    }
    
    
    if ([self.spotNameTextField.text isEqualToString:@""] && self.spot.spot_name)
    {
        self.spotNameTextField.text = self.spot.spot_name;
    }
    if ([self.telTextField.text isEqualToString:@""] && self.spot.phone)
    {
        self.telTextField.text = self.spot.phone;
    }
    if ([self.urlTextField.text isEqualToString:@""] && self.spot.url)
    {
        self.urlTextField.text = self.spot.url;
    }
    if ([self.memoTextView.text isEqualToString:@""] && self.spot.memo)
    {
        self.memoTextView.text = self.spot.memo;
    }
    
    self.isCheckinFoursquare = NO;
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardDidHide:)
    //                                                 name:UIKeyboardDidHideNotification
    //                                               object:nil];
    self.initiateSearchResultArray = [NSMutableArray new];
    
    self.defaultFoursquareButton  = self.navigationItem.leftBarButtonItem;
    
    [FontHelper setFontFamily:FONT_NAME forView:self.view andSubViews:YES];
    self.spotNameTextField.font = appDelegate.smallFont;
    self.urlTextField.font =appDelegate.smallFont;
    self.telTextField.font =appDelegate.smallFont;
    self.memoTextView.font = appDelegate.smallFont;
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setResponder) name:@"passcodeViewControllerWillClose" object:nil];
    self.isAllowClick = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHideKeyboard) name:UIKeyboardDidHideNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    self.delegate = nil;

    self.inputAccessoryView = nil;

    NSLog(@"Create Spot died.");
}

- (void) handleHideKeyboard
{
    self.isAllowClick = YES;
}

- (void)setupNewSpot {
    self.spot.uuid = [[NSUUID UUID] UUIDString];
    self.spot.date = [NSDate date];
    [self saveSpotAndExportToXml:YES];
    self.isCreateNewSpot = YES;
}

//- (void)keyboardDidHide:(id)sender
//{
////    [self selectResponder];
//}

- (void)setResponder {
    
    NSLog(@"selectResponder");
    if (self.currentControl != nil) {
        [self.currentControl becomeFirstResponder];
        NSLog(@"%@", self.currentControl);
    }
    else {
        if ([StringHelpers isNilOrWhitespace:self.spotNameTextField.text]) {
            [self.spotNameTextField becomeFirstResponder];
        }
        else if ([StringHelpers isNilOrWhitespace:self.telTextField.text]) {
            [self.telTextField becomeFirstResponder];        }
        else if ([StringHelpers isNilOrWhitespace:self.urlTextField.text]){
            [self.urlTextField becomeFirstResponder];        }
//        else if ([StringHelpers isNilOrWhitespace:self.memoTextView.text]) {
//            [self.memoTextView becomeFirstResponder];
//            //            [self scrollTextViewToBottom:self.memoTextView];
//        }
        else {
            [self.spotNameTextField becomeFirstResponder];
        }
    }
    
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isAllowClick = YES;
//    self.extendKeyboard.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    
    [self setResponder];
    // Disable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.toolbar.hidden = YES;
    
    if ([self.spot.voice count] > 0) {
        UIImage *voiceMemoBlueImage = [UIImage imageNamed:@"Voicememo_slice_10_blue"];
        [self.voiceMemoButton setImage:voiceMemoBlueImage forState:UIControlStateNormal];
    } else {
        UIImage *voiceMemoGrayImage = [UIImage imageNamed:@"Voicememo_slice_10"];
        [self.voiceMemoButton setImage:voiceMemoGrayImage forState:UIControlStateNormal];
    }
    // set focus on textfield to show keyboard
    [self setResponder];
    
    [self toggleFoursquareButton];
    
    
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self saveSpotInfo];
    
    //dismiss keyboard
    [self.view endEditing:YES];
    
    // Enable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)saveSpotInfo {
    self.spot.spot_name = self.spotNameTextField.text;
    self.spot.phone = self.telTextField.text;
    self.spot.url = self.urlTextField.text;
    self.spot.memo = self.memoTextView.text;
}

- (void)saveSpotAndExportToXml:(BOOL)exportToXml {
    [self saveSpotInfo];
    
    // prevent strong reference
    __weak SPOT *spot = self.spot;
    __weak CreateSPOTViewController *weakSelf = self;
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    
    [magicalContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
        SPOT *innerSpot = spot;
        CreateSPOTViewController *innerSelf = weakSelf;
        
        if (success) {
            if (exportToXml) {
                innerSelf.shouldExportXml = NO;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    SPOT *innerSpot2 = innerSpot;
                    [NSThread sleepForTimeInterval:1];
                    [appDelegate saveSpotToXMLForSync:innerSpot2];
                });
            }
            else {
                innerSelf.shouldExportXml = YES;
            }
            
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    // show spot details
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) resignFirstResponder:(id)sender
{
    NSLog(@"resignFirstResponder");
    [sender resignFirstResponder];
}

- (IBAction) onDoneButtonClicked:(id)sender
{
    if (self.isAllowClick) {
        NSLog(@"onDoneButtonClicked");
        self.view.userInteractionEnabled = false;
        self.isAllowClick = NO;
        if (self.venueID.length > 0 && self.isCheckinFoursquare) {
            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            if (networkStatus == NotReachable) {
                NSLog(@"lost internet connection");
            } else {
                [self foursquareCheckinAtVenue:self.venueID];
            }
        }
        [self saveSpotAndExportToXml:YES];
        
        // because of choose picture bug
        self.shouldExportXml = YES;
        
        if (self.shouldExportXml) {
            __weak SPOT *spot = self.spot;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                SPOT *innerSpot = spot;
                [appDelegate saveSpotToXMLForSync:innerSpot];
            });
        }
        
        // wait to make sure spot finish init
        [NSThread sleepForTimeInterval:0.2];
        
        appDelegate.createSPOTViewController = nil;
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else {
        self.isAllowClick = YES;
    }
}

- createInputAccessoryView {
    if (self.inputAccessoryView == nil) {
        self.inputAccessoryView = [[UINib nibWithNibName:@"KeyboardToolbarView" bundle:nil] instantiateWithOwner:self options:nil][0];
        //        self.inputAccessoryView = inputAccessoryView;
        self.inputAccessoryView.delegate = self;
        
        /*
         CGRect accessFrame = CGRectMake(0.0, 0.0, 768.0, 77.0);
         inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
         inputAccessoryView.backgroundColor = [UIColor blueColor];
         UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
         compButton.frame = CGRectMake(313.0, 20.0, 158.0, 37.0);
         [compButton setTitle: @"Word Completions" forState:UIControlStateNormal];
         [compButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         [compButton addTarget:self action:@selector(completeCurrentWord:)
         forControlEvents:UIControlEventTouchUpInside];
         [inputAccessoryView addSubview:compButton];
         */
    }
    return self.inputAccessoryView;
}


//- (UIView *)inputAccessoryView {
//    if (inputAccessoryView == nil) {
//        inputAccessoryView = [[UINib nibWithNibName:@"KeyboardToolbarView" bundle:nil] instantiateWithOwner:self options:nil][0];
////        self.inputAccessoryView = inputAccessoryView;
//        inputAccessoryView.delegate = self;
//    
//        /*
//         CGRect accessFrame = CGRectMake(0.0, 0.0, 768.0, 77.0);
//         inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
//         inputAccessoryView.backgroundColor = [UIColor blueColor];
//         UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//         compButton.frame = CGRectMake(313.0, 20.0, 158.0, 37.0);
//         [compButton setTitle: @"Word Completions" forState:UIControlStateNormal];
//         [compButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//         [compButton addTarget:self action:@selector(completeCurrentWord:)
//         forControlEvents:UIControlEventTouchUpInside];
//         [inputAccessoryView addSubview:compButton];
//         */
//    }
//    return inputAccessoryView;
//}


- (void) dismissKeyboard
{
    NSLog(@"dismissKeyboard");
    [self.view endEditing:YES];
}
- (IBAction)onVoiceMemoButtonClicked:(id)sender {
    if (self.isAllowClick) {
        NSLog(@"onVoiceMemoButtonClicked");
        self.isAllowClick = NO;
        [self performSegueWithIdentifier:@"PushMemoVoiceSpotViewController" sender:self];
    }
    else {
        self.isAllowClick = YES;
    }
}

- (IBAction)onFoursquareButtonClicked:(id)sender {
    NSLog(@"onFoursquareButtonClicked");
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"System message" message:@"Can not checkin\nPlease check your internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if ([AppSettings isAuthorizedFoursquare]) {
        self.isCheckinFoursquare = !self.isCheckinFoursquare;
        [self toggleFoursquareButton];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"System message" message:@"Please login to checkin Foursquare" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)toggleFoursquareButton {
    
    
    if (self.venueID != nil && self.isCreateNewSpot && [AppSettings isAuthorizedFoursquare]) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
        if (self.isCheckinFoursquare) {
            //            self.navigationItem.leftBarButtonItem.tintColor = [UIColor greenColor];
            //        self.foursquareButton.imageView.image = [UIImage imageNamed:@"Slice_icon_79"];
            
            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Check_in_active"]];
        }
        else {
            
            //            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.5];
            
            //            self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
            
            //        self.foursquareButton.imageView.image = [UIImage imageNamed:@"Slice_icon_88"];
            
            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Check_in"]];
            
        }
        
    }
    else {
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0];
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
}

- (UIBarButtonItem *)colorFoursquareButton
{
    UIImage *image = [UIImage imageNamed:@"Slide_icon_79"];
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size. height);
    
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button setImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *item= [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return item;
}

#pragma mark - KeyboardToolbarViewDelegate

- (void)onAddressButtonClicked:(id)sender
{    if (self.isAllowClick) {
    NSLog(@"onAddressButtonClicked");
    self.isAllowClick = NO;
//    self.extendKeyboard.userInteractionEnabled = NO;
    self.view.userInteractionEnabled = NO;
    [self performSegueWithIdentifier:@"PushAddressRegisterationViewController" sender:self];
}
else {
    self.isAllowClick = YES;
}
}

- (void)onCalendarButtonClicked:(id)sender
{
    if (self.isAllowClick) {
        NSLog(@"onCalendarButtonClicked");
        self.isAllowClick = NO;
//        self.extendKeyboard.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
        [self performSegueWithIdentifier:@"PushDateRegisterationViewController" sender:self];
    }
    else {
        self.isAllowClick = YES;
    }
}

- (void)onCameraButtonClicked:(id)sender
{
    
    if (self.isAllowClick) {
        self.isAllowClick = NO;
        NSLog(@"onCameraButtonClicked");
        [self dismissKeyboard];
        [appDelegate showActionSheetSimulationViewForSpot:self.spot completetion:^{
            self.isAllowClick = YES;
        }];
    }
    else {
        self.isAllowClick = YES;
    }
}

- (void)onTagButtonClicked:(id)sender
{
    if (self.isAllowClick) {
        NSLog(@"onTagButtonClicked");
        self.isAllowClick = NO;
//        self.extendKeyboard.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
        [self performSegueWithIdentifier:@"PushTagRegisterationViewController" sender:self];
    }
    else {
        self.isAllowClick = YES;
    }
}

- (void)onTrafficButtonClicked:(id)sender
{
    if (self.isAllowClick) {
        NSLog(@"onTrafficButtonClicked");
        self.isAllowClick = NO;
//        self.extendKeyboard.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
        [self performSegueWithIdentifier:@"PushTrafficRegisterationViewController" sender:self];
    }
    else {
        self.isAllowClick = YES;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"PushDateRegisterationViewController"])
    {
        // Get reference to the destination view controller
        DateRegisterationViewController *dateRegisterationViewController = [segue destinationViewController];
        
        [dateRegisterationViewController setSpot:self.spot];
        
    }
    else if ([[segue identifier] isEqualToString:@"PushTrafficRegisterationViewController"])
    {
        // Get reference to the destination view controller
        TrafficRegisterationViewController *trafficRegisterationViewController = [segue destinationViewController];
        
        [trafficRegisterationViewController setSpot:self.spot];
        [trafficRegisterationViewController setInitiateSearchResultArray:self.initiateSearchResultArray];
    }
    else if ([[segue identifier] isEqualToString:@"PushAddressRegisterationViewController"])
    {
        // Get reference to the destination view controller
        AddressRegisterationViewController *addressRegisterationViewController = [segue destinationViewController];
        addressRegisterationViewController.delegate = self;
        [addressRegisterationViewController setSpot:self.spot];
        [addressRegisterationViewController setInitiateSearchResultArray:self.initiateSearchResultArray];
    }
    else if ([[segue identifier] isEqualToString:@"PushTagRegisterationViewController"])
    {
        // Get reference to the destination view controller
        TagRegisterationViewController *tagRegisterationViewController = [segue destinationViewController];
        
        [tagRegisterationViewController setSpot:self.spot];
    }
    else if([[segue identifier] isEqualToString:@"PushMemoVoiceSpotViewController"])
    {
        MemoVoiceSpotViewController *memoVoiceViewController = [segue destinationViewController];
        
        [memoVoiceViewController setSpot:self.spot];
    }
}

#pragma mark - AddressRegisterationViewControllerDelegate

- (void)didSelectAddress: (NSString *)venueID {
    self.venueID = venueID;
    NSLog(@"venue id %@", self.venueID);
    self.spotNameTextField.text = self.spot.spot_name;
    self.telTextField.text = self.spot.phone;
    self.urlTextField.text = self.spot.url;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[self onDoneButtonClicked:nil];
    if (textField == self.spotNameTextField) {
        [self.telTextField becomeFirstResponder];
    }
    else if (textField == self.telTextField) {
        [self.urlTextField becomeFirstResponder];
    }
    else {
        [self.memoTextView becomeFirstResponder];
        [self scrollTextViewToBottom:self.memoTextView];
    }
    
    return NO;
}

-(void)scrollTextViewToBottom:(UITextView *)textView {
    if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length -1, 1);
        [textView scrollRangeToVisible:bottom];
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentControl = textField;
    [self createInputAccessoryView];
    [textField setInputAccessoryView:self.inputAccessoryView];
}

#pragma mark - UITextViewDelegate


- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.currentControl = textView;
    [self createInputAccessoryView];
    [textView setInputAccessoryView:self.inputAccessoryView];
}

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidEndScrollingAnimation");
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidScroll");
//
//}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"scrollViewDidEndDragging");
    //    [self setResponder];
    
}

#pragma mark - foursquare checkin

- (void)foursquareCheckinAtVenue: (NSString *)venueId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Foursquare2 checkinAddAtVenue:venueId shout:@"Check in from SPOT!" callback:^(BOOL success, id result) {
            if (success) {
                NSLog(@"checkin successfully");
            }
        }];
    });
}

- (IBAction)onCheckinFoursquareSwitchValueChanged:(id)sender {
    UISwitch *foursquareSwitch = (UISwitch *)sender;
    if ([foursquareSwitch isOn]) {
        self.isCheckinFoursquare = YES;
    }else {
        self.isCheckinFoursquare = NO;
    }
}


@end
