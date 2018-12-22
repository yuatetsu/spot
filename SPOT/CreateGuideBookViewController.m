//
//  CreateGuideBookViewController.m
//  SPOT
//
//  Created by framgia on 8/13/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "CreateGuideBookViewController.h"
#import "SPOTListTableViewController.h"
#import "EditGuideBookInfoMemoViewController.h"
#import "GuideBook.h"
#import "GuideBookInfo.h"
#import "SPOT.h"
#import "Foursquare2.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "GuideBookInfoType.h"
#import "StartSpotRegistrationViewController.h"
#import "LocationHelpers.h"
#import "SPOT+Traffic.h"
#import "GuideBookInfoType.h"
#import "SpotDetailsXibViewController.h"


@interface CreateGuideBookViewController () <NSFetchedResultsControllerDelegate, UITextFieldDelegate, StartSpotRegistrationViewControllerDelegate>
{
    NSDateFormatter *dateTimeFormatter;
    SPOT *selectedSpot;
    BOOL isPushingDetailsViewController;
    BOOL shouldExportXml;
}


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

//@property (strong, nonatomic) UITableView *startSpotSearchResultTableView;
//@property (strong, nonatomic) NSArray *startSpotSearchResultsFromDatabase;
//@property (strong, nonatomic) NSArray *startSpotSearchResultsFromFourSquare;
@property (strong, nonatomic) UIDatePicker *datePicker;

//@property (strong, nonatomic) NSOperation *searchOperation;

@end

@implementation CreateGuideBookViewController

AppDelegate *appDelegate;

NSDateFormatter *formatter;
NSCalendar *calendar;
GuideBookInfo *guideBookInfoMemoToEdit;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setupNewGuideBook
{
    self.guideBook.uuid = [[NSUUID UUID] UUIDString];
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    [magicalContext MR_saveOnlySelfAndWait];
    
    __weak GuideBook *guideBook = self.guideBook;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        GuideBook *innerGuideBook = guideBook;
        [appDelegate saveGuideBookToXMLForSync:innerGuideBook];
    });
//    [self.guideBookNameTextField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"create guidebook viewdidload");
//    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self configureDatePicker];
    
    calendar = [NSCalendar currentCalendar];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    dateTimeFormatter = [[NSDateFormatter alloc] init];
    [dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    // Create guide book
    if (!self.guideBook) {
        self.guideBook = [GuideBook MR_createEntity];
        [self setupNewGuideBook];
    }
    else if (!self.guideBook.uuid) {
        [self setupNewGuideBook];
    }
    else {
        self.title = @"Edit GUIDE BOOK";
        self.guideBookNameTextField.text = self.guideBook.guide_book_name;
        if (self.guideBook.start_spot_selected_from_foursquare)
        {
//            self.startSpotTextField.text = self.guideBook.foursquare_spot_name;
            [self.selectStartSpotButton setTitle:self.guideBook.foursquare_spot_name forState:UIControlStateNormal];
            
            NSLog(@"Start Spot: %@", self.guideBook.foursquare_spot_name  );
        }
        else
        {
            if (self.guideBook.start_spot)
            {
                [self.selectStartSpotButton setTitle:self.guideBook.start_spot.spot_name forState:UIControlStateNormal];
                NSLog(@"Start Spot: %@", self.guideBook.start_spot.spot_name );
            }
            else
            {
                // start spot has not been selected yet
            }
        }
        self.startDateTextField.text = [dateTimeFormatter stringFromDate: self.guideBook.start_date];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(guide_book = %@)", self.guideBook.objectID];
    self.fetchedResultsController = [GuideBookInfo MR_fetchAllSortedBy:@"order" ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    
    
    self.guideBookNameTextField.delegate = self;
//    self.startSpotTextField.delegate = self;
    
    
    
    [self setEditing:YES];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    

 
    [FontHelper setFontFamily:FONT_NAME forView:self.view andSubViews:YES];
    
    self.guideBookNameTextField.font = appDelegate.smallFont;
    self.startDateTextField.font = appDelegate.smallFont;
}

- (void)dealloc {
    NSLog(@"Create GuideBook died.");
}


//- (UIStatusBarStyle) preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.guideBook.foursquare_spot_name.length > 0 || self.guideBook.start_spot.spot_name > 0) {
        [self.selectStartSpotButton setImage:nil forState:UIControlStateNormal];
    }
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.toolbar.hidden = NO;
    
    [self.tableView reloadData];
    
    // change status bar
//    appDelegate.statusBar.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
NSLog(@"create guidebook viewDidAppear");
    // Disable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.guideBook.guide_book_name = self.guideBookNameTextField.text;
    
    // Enable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    [self.navigationController setNavigationBarHidden:YES];
    
    
    
    // change status bar
//    appDelegate.statusBar.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    isPushingDetailsViewController = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//-(void)saveGuidebookToXML{
//    
//    [appDelegate saveGuideBookToXMLForSync:self.guideBook];
//}

- (void)configureDatePicker
{
    @autoreleasepool {
        self.datePicker = [[UIDatePicker alloc] init];
        
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        self.datePicker.hidden = NO;
        self.datePicker.date = [NSDate date];
        self.datePicker.backgroundColor = [UIColor whiteColor];
        
        [self.startDateTextField setInputView:self.datePicker];
        
        UIToolbar * inputToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        
        inputToolBar.barStyle = UIBarStyleDefault;
        [inputToolBar setItems: [NSArray arrayWithObjects:
                                 [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(onCancelDatePickerClicked)],
                                 [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                 [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onSelectStartDateButtonClicked)],
                                 nil]];
        
        [self.startDateTextField setInputAccessoryView:inputToolBar];
    }
    
}

- (void)onSelectStartDateButtonClicked
{
    [self.startDateTextField endEditing:YES];
    
    
    self.guideBook.start_date = self.datePicker.date;
    
    self.startDateTextField.text = [dateTimeFormatter stringFromDate:self.guideBook.start_date];
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    
    __weak GuideBook *guideBook = self.guideBook;
    __weak CreateGuideBookViewController *weakSelf = self;
    // save
    [magicalContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
        if (success) {
            GuideBook *innerGuideBook = guideBook;
            CreateGuideBookViewController *innerSelf = weakSelf;
            [innerSelf.tableView reloadData];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                GuideBook *innerGuideBook2 = innerGuideBook;
                [appDelegate saveGuideBookToXMLForSync:innerGuideBook2];
            });
        }
    }];
    
    
}
- (void)onCancelDatePickerClicked
{
    [self.startDateTextField endEditing:YES];
}

-(IBAction)onAddDayButtonClicked:(id)sender
{
    GuideBookInfo *guideBookInfo = [GuideBookInfo MR_createEntity];
    
    // set info_type to day (1)
    guideBookInfo.info_type = [NSNumber numberWithInt:GuideBookInfoTypeDay];
    NSIndexPath *selectedCellIndexPath = [self.tableView indexPathForSelectedRow];
    
    if (selectedCellIndexPath)
    {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(guide_book = %@) AND (order > %d)", self.guideBook.objectID, selectedCellIndexPath.row];
        NSArray *needUpdateGuideBookInfo = [GuideBookInfo MR_findAllWithPredicate:predicate];
        
        
        for (GuideBookInfo *info in needUpdateGuideBookInfo)
        {
            if (info.info_type.intValue == GuideBookInfoTypeDay)
            {
                // is day
                info.day_from_start_day = [NSNumber numberWithInt:info.day_from_start_day.intValue+1];
            }
            info.order = [NSNumber numberWithInt:info.order.intValue + 1];
        }
        
        NSPredicate *countDayPredicate = [NSPredicate predicateWithFormat:@"(guide_book = %@) AND (info_type = 1) AND (order <= %d)", self.guideBook.objectID, selectedCellIndexPath.row];
        guideBookInfo.day_from_start_day = [NSNumber numberWithInteger:[GuideBookInfo MR_countOfEntitiesWithPredicate:countDayPredicate] + 1];
        
        guideBookInfo.order = [NSNumber numberWithInteger:selectedCellIndexPath.row+1];
    }
    else
    {
        // no cell selected
        guideBookInfo.order = [NSNumber numberWithInteger:[self.tableView numberOfRowsInSection:0]];
        
        NSPredicate *countDayPredicate = [NSPredicate predicateWithFormat:@"(guide_book = %@) AND (info_type = 1)", self.guideBook.objectID];
        guideBookInfo.day_from_start_day = [NSNumber numberWithInteger:[GuideBookInfo MR_countOfEntitiesWithPredicate:countDayPredicate] + 1];
        
    }

    guideBookInfo.guide_book = self.guideBook;
    [self.guideBook addGuide_book_infoObject:guideBookInfo];
    
    
    [self saveGuideBookAndExportXml:NO];
    
  
    
}

- (void)scrollToBottom {
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.guideBook.guide_book_info.count-1 inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(IBAction)onAddSPOTButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"PushSPOTListTableViewController" sender:self];
    
}
-(IBAction)onAddMemoButtonClicked:(id)sender
{
    
    GuideBookInfo *guideBookInfo = [GuideBookInfo MR_createEntity];
    
    // set info_type to memo (3)
    guideBookInfo.info_type = [NSNumber numberWithInt:GuideBookInfoTypeMemo];
    
    guideBookInfo.memo = @"";
    NSIndexPath *selectedCellIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedCellIndexPath)
    {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(guide_book = %@) AND (order > %d)", self.guideBook.objectID, selectedCellIndexPath.row];
        NSArray *needUpdateGuideBookInfo = [GuideBookInfo MR_findAllWithPredicate:predicate];
        
        
        for (GuideBookInfo *info in needUpdateGuideBookInfo)
        {
            info.order = [NSNumber numberWithInt:info.order.intValue + 1];
        }
        
        guideBookInfo.order = [NSNumber numberWithInteger:selectedCellIndexPath.row + 1];
    }
    else
    {
        guideBookInfo.order = [NSNumber numberWithInteger:[self.tableView numberOfRowsInSection:0]];
    }
    guideBookInfo.guide_book = self.guideBook;
    [self.guideBook addGuide_book_infoObject:guideBookInfo];
    
    [self saveGuideBookAndExportXml:NO];
    
    guideBookInfoMemoToEdit = guideBookInfo;
    [self performSegueWithIdentifier:@"PushEditGuideBookInfoMemoViewController" sender:self];
    
}


-(IBAction)onDoneButtonClicked:(id)sender
{
    [self saveGuideBookAndExportXml:YES];
    
    if (shouldExportXml) {
        __weak GuideBook *guideBook = self.guideBook;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            GuideBook *innerGuideBook = guideBook;
            [appDelegate saveGuideBookToXMLForSync:innerGuideBook];
        });
    }
    
    // wait to make sure guidebook finish init
    [NSThread sleepForTimeInterval:0.2];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapGestureRecognized:(id)sender {
    NSLog(@"tapGestureRecognized");
    [self.view endEditing:YES];
}

- (IBAction)longPressRecognized:(id)sender {
    
    UILongPressGestureRecognizer *gesture =  (UILongPressGestureRecognizer *)sender;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gesture locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        
        if (indexPath) {
            GuideBookInfo *guideBookInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            if (guideBookInfo && guideBookInfo.info_type.intValue == GuideBookInfoTypeSpot) {
                
                selectedSpot = guideBookInfo.spot;
                if (!isPushingDetailsViewController) {
                    NSLog(@"longPressRecognized");
                    isPushingDetailsViewController = YES;
                    [self performSegueWithIdentifier:@"PushDetailsViewController" sender:self];
                    
                }
                
            }
        }
    }
}

-(void)onMemoEditButtonClicked:(UIButton*)senderButton
{
    CGPoint buttonPosition = [senderButton convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath)
    {
        guideBookInfoMemoToEdit = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"PushEditGuideBookInfoMemoViewController" sender:self];
    }
}

- (UIView *)inputAccessoryView {
    
    NSLog(@"inputAccessoryView");
    UIView *inputAccessoryView;
    
    CGRect accessFrame = CGRectMake(0.0, 0.0, 320, 30.0);
    inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
    inputAccessoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Slice_icon_112"]];
    UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    compButton.frame = CGRectMake(5.0, 0.0, 50, 30.0);
    [compButton setTitle: @"Close" forState:UIControlStateNormal];
    [compButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [compButton.titleLabel setFont:appDelegate.normalFont];
    [compButton addTarget:self action:@selector(closeKeyboard)
         forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:compButton];
    
    
    return inputAccessoryView;
}

- (void)closeKeyboard {
    [self.view endEditing:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView)
    {
        return self.fetchedResultsController.sections.count;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (tableView == self.tableView)
//    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
        return [sectionInfo numberOfObjects];
//    }
//    else
//    {
//        return self.startSpotSearchResultsFromDatabase.count + self.startSpotSearchResultsFromFourSquare.count;
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (tableView == self.tableView)
    {
        GuideBookInfo *guideBookInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (guideBookInfo.info_type.intValue == GuideBookInfoTypeMemo)
        {
            // is memo
            height = 40.0f;
        }
        else if (guideBookInfo.info_type.intValue == GuideBookInfoTypeDay)
        {
            // is day
            height = 40.0f;
        }
        else
        {
            // is spot
            height = 70.0f;
        }
    }
    else
    {
        // start spot search results table
        height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return height;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
//    if (tableView == self.tableView)
//    {
        GuideBookInfo *guideBookInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (guideBookInfo.info_type.intValue == GuideBookInfoTypeMemo)
        {
            // is memo
            UILabel *memoLabel = (UILabel*)[cell viewWithTag:1];
            memoLabel.text = guideBookInfo.memo;
            
            memoLabel.font = appDelegate.smallFont;
            
            UIButton *memoEditButton = (UIButton*)[cell viewWithTag:4];
            [memoEditButton addTarget:self
                             action:@selector(onMemoEditButtonClicked:)
                   forControlEvents:UIControlEventTouchUpInside];
        }
        else if (guideBookInfo.info_type.intValue == GuideBookInfoTypeDay)
        {
            // is day
            UILabel *dayLabel = (UILabel*)[cell viewWithTag:1];
            dayLabel.font = appDelegate.smallFont;
            int dayFromStartDay = [[guideBookInfo day_from_start_day] intValue];
            if (self.guideBook.start_date){
//                NSDateComponents *dayMonthYearComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.guideBook.start_date];
                
                NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                [dateComponents setDay:dayFromStartDay - 1];
                
                NSDate *dayMonthYear = [calendar dateByAddingComponents:dateComponents toDate:self.guideBook.start_date options:0];
                
                dayLabel.text = [formatter stringFromDate:dayMonthYear];
            } else {
                dayLabel.text = [NSString stringWithFormat:@"Day %d", dayFromStartDay];
            }
        }
        else
        {
            // is spot
            UILabel *spotNameLabel = (UILabel*)[cell viewWithTag:1];
            spotNameLabel.text = guideBookInfo.spot.spot_name;
            spotNameLabel.font = appDelegate.smallFont;
            
            UILabel *trafficLabel = (UILabel*)[cell viewWithTag:2];
            trafficLabel.font = appDelegate.smallFont;
            
            trafficLabel.text = [guideBookInfo.spot trafficText];
            NSLog(@"%@", trafficLabel.text);
            
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:3];
            imageView.image = [appDelegate getTrafficIconByType:guideBookInfo.spot.traffic.intValue];
        }

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    NSString *CellIdentifier;
    
//    if (tableView == self.tableView)
//    {
    
        GuideBookInfo *guideBookInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (guideBookInfo.info_type.intValue == GuideBookInfoTypeMemo)
        {
            // is memo
            CellIdentifier = @"Memo Cell";
        }
        else if (guideBookInfo.info_type.intValue == GuideBookInfoTypeDay)
        {
            // is day
            CellIdentifier = @"Day Cell";
        }
        else
        {
            // is spot
            CellIdentifier = @"SPOT Cell";
        }
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    }
//    else
//    {
//        // start spot search results table
//        CellIdentifier = @"SPOT List Cell No Image";
//        UITableViewCell *cell;
//        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    }
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath inTableView:tableView];
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"sourceIndex = %@, toIndex = %@", sourceIndexPath, destinationIndexPath);
    
    // disable update UI
    self.fetchedResultsController.delegate = nil;
    
    NSArray *allObjects =  [self.fetchedResultsController fetchedObjects];
    GuideBookInfo *movedGuideBookInfo = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
    movedGuideBookInfo.order = [NSNumber numberWithInteger:destinationIndexPath.row];
    if (sourceIndexPath.row>=destinationIndexPath.row)
    {
        // moved up
        for (int i = (int)sourceIndexPath.row -1; i >= (int)destinationIndexPath.row; i--)
        {
            GuideBookInfo *guideBookInfo = [allObjects objectAtIndex:i];
            guideBookInfo.order = [NSNumber numberWithInt:guideBookInfo.order.intValue + 1];
            if ((movedGuideBookInfo.info_type.intValue == GuideBookInfoTypeDay) && (guideBookInfo.info_type.intValue == GuideBookInfoTypeDay))
            {
                // movedGuideBookInfo is a day indicator => need update others day indicators
                guideBookInfo.day_from_start_day = [NSNumber numberWithInt:guideBookInfo.day_from_start_day.intValue + 1];
            }
        }
    }
    else
    {
        // moved down
        
        for (int i = (int)sourceIndexPath.row +1; i <= (int)destinationIndexPath.row; i++)
        {
            GuideBookInfo *guideBookInfo = [allObjects objectAtIndex:i];
            guideBookInfo.order = [NSNumber numberWithInt:guideBookInfo.order.intValue - 1];
            if ((movedGuideBookInfo.info_type.intValue == GuideBookInfoTypeDay) && (guideBookInfo.info_type.intValue == GuideBookInfoTypeDay))
            {
                // movedGuideBookInfo is a day indicator => need update others day indicators
                guideBookInfo.day_from_start_day = [NSNumber numberWithInt:guideBookInfo.day_from_start_day.intValue - 1];
            }
        }
    }
    
    if (movedGuideBookInfo.info_type.intValue == GuideBookInfoTypeDay)
    {
        // movedGuideBookInfo is a day indicator
        NSPredicate *countDayPredicate = [NSPredicate predicateWithFormat:@"(guide_book = %@) AND (info_type = 1) AND (order < %d)", self.guideBook.objectID, destinationIndexPath.row];
        movedGuideBookInfo.day_from_start_day = [NSNumber numberWithInteger:[GuideBookInfo MR_countOfEntitiesWithPredicate:countDayPredicate] + 1];
    }
    
    [self saveGuideBookAndExportXml:NO];
    
    // enable UI update
    self.fetchedResultsController.delegate = self;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        if (indexPath)
        {
            
            GuideBookInfo *guideBookInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(guide_book = %@) AND (order > %d)", self.guideBook.objectID, indexPath.row];
            NSArray *needUpdateGuideBookInfo = [GuideBookInfo MR_findAllWithPredicate:predicate];
            for (GuideBookInfo *info in needUpdateGuideBookInfo)
            {
                
                if ((guideBookInfo.info_type.intValue==GuideBookInfoTypeDay) && (info.info_type.intValue == GuideBookInfoTypeDay))
                {
                    // guideBookInfo is day type
                    info.day_from_start_day = [NSNumber numberWithInt:info.day_from_start_day.intValue-1];
                }
                
                info.order = [NSNumber numberWithInt:info.order.intValue - 1];
            }
            
            [guideBookInfo MR_deleteEntity];
            
        }
        
        [self saveGuideBookAndExportXml:NO];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
}

- (void)saveGuideBookAndExportXml: (BOOL)exportXml {
    self.guideBook.guide_book_name = self.guideBookNameTextField.text;
    
    __weak GuideBook *guideBook = self.guideBook;
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    // save
    [magicalContext MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
        GuideBook *innerGuideBook = guideBook;
        if (success) {
            if (exportXml) {
                shouldExportXml = NO;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [NSThread sleepForTimeInterval:1];
                    GuideBook *innerGuideBook2 = innerGuideBook;
                    [appDelegate saveGuideBookToXMLForSync:innerGuideBook2];
                });
            }
            else {
                shouldExportXml = YES;
            }
        }
        
    }];
}

- (void)reloadResultsTable
{
//    [self.startSpotSearchResultTableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"PushSPOTListTableViewController"])
    {
        // Get reference to the destination view controller
        SPOTListTableViewController *spotListTableViewController = [segue destinationViewController];
        
        [spotListTableViewController setGuideBook:self.guideBook];
        [spotListTableViewController setIndexPathForInsertingIntoGuideBook:self.tableView.indexPathForSelectedRow];
    }
    else if ([[segue identifier] isEqualToString:@"PushEditGuideBookInfoMemoViewController"])
    {
        // Get reference to the destination view controller
        EditGuideBookInfoMemoViewController *editGuideBookInfoMemoViewController = [segue destinationViewController];
        
        [editGuideBookInfoMemoViewController setGuideBookInfo:guideBookInfoMemoToEdit];
    }
    else if ([[segue identifier] isEqualToString:@"PushStartSpotRegistrationViewController"]) {
        StartSpotRegistrationViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"PushDetailsViewController"]) {
      
        SpotDetailsXibViewController *controller = [segue destinationViewController];
        controller.spot = selectedSpot;
        
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    NSLog(@"controllerWillChangeContent");
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSLog(@"didChangeObject");
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            NSLog(@"NSFetchedResultsChangeInsert");
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
           
            [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.1];
           
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"NSFetchedResultsChangeDelete");
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"NSFetchedResultsChangeUpdate");
            [self configureCell:(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath inTableView:tableView];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"NSFetchedResultsChangeMove");
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    NSLog(@"didChangeSection");
    UITableView *tableView = self.tableView;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    NSLog(@"controllerDidChangeContent");
    [self.tableView endUpdates];
}

#pragma mark - UITextFieldDelegate

//- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
//{
////    if (textField == self.startSpotTextField)
////    {
//////        [self hideStartSpotSearchResults];
////    }
//    if (textField == self.guideBookNameTextField)
//    {
//        // save guide book name
//        self.guideBook.guide_book_name = self.guideBookNameTextField.text;
//        
////        [self saveGuideBookAndExportXml:NO];
//    }
//    return YES;
//}
//- (BOOL) textFieldShouldReturn:(UITextField *)textField
//{
////    if (textField == self.startSpotTextField)
////    {
////        [self.startSpotTextField endEditing:YES];
////    }
////    else
//        if (textField == self.guideBookNameTextField)
//    {
//        [self.guideBookNameTextField endEditing:YES];
//    }
//    return YES;
//}

- (IBAction)onSelectStartSpotButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"PushStartSpotRegistrationViewController" sender:self];
}

#pragma mark - StartSpotRegistrationViewControllerDelegate

- (void)didSelectStartSpot:(SPOT *)spot {
    self.guideBook.start_spot = spot;
    self.guideBook.start_spot_selected_from_foursquare = 0;
    
    [self.selectStartSpotButton setTitle:spot.spot_name forState:UIControlStateNormal];
    [self saveGuideBookAndExportXml:NO];
}

- (void)didSelectFoursquareVenueWithName:(NSString *)name lat:(double)lat lng:(double)lng {
    self.guideBook.start_spot_selected_from_foursquare = @(1);
    self.guideBook.start_spot = nil;
    self.guideBook.foursquare_spot_name = name;
    self.guideBook.foursquare_spot_lat = @(lat);
    self.guideBook.foursquare_spot_lng = @(lng);
    
    [self.selectStartSpotButton setTitle:name forState:UIControlStateNormal];
    
    [self saveGuideBookAndExportXml:NO];
    
}

@end
