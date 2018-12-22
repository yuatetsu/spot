//
//  CalendarViewController.m
//  SPOT
//
//  Created by framgia on 8/11/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "CalendarViewController.h"
#import "RSDFDatePickerView.h"
#import "SPOT.h"
#import "SPOTListTableViewController.h"
#import "Banner.h"
#import "AppDelegate.h"

@interface CalendarViewController ()<RSDFDatePickerViewDataSource, RSDFDatePickerViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *markedDates;
@property (strong, nonatomic) RSDFDatePickerView *datePickerView;
@property NSInteger currentYear;
@property NSInteger currentMonth;
@property NSInteger currentDay;
@property (strong, nonatomic) NSDate *pickedDate;
@end

@implementation CalendarViewController

AppDelegate *appDelegate;

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
    
    NSArray* allSpot = [SPOT MR_findAll];
    self.markedDates = [[NSMutableDictionary alloc] initWithCapacity:allSpot.count];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    for (SPOT* spot in allSpot)
    {
        NSDateComponents *dayMonthYearComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:spot.date];
        NSDate *dayMonthYear = [calendar dateFromComponents:dayMonthYearComponents];
        self.markedDates[dayMonthYear] = @YES;
    }
    
    NSDateComponents *currentYearComponents = [calendar components:(NSYearCalendarUnit) fromDate:[NSDate date]];
    NSDateComponents *currentMonthComponents = [calendar components:(NSMonthCalendarUnit) fromDate:[NSDate date]];
    NSDateComponents *currentDayComponents = [calendar components:(NSDayCalendarUnit) fromDate:[NSDate date]];
    self.currentYear = currentYearComponents.year;
    self.currentMonth = currentMonthComponents.month;
    self.currentDay = currentDayComponents.day;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.text = [NSString stringWithFormat:@"%d",(int)self.currentYear];
    titleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Slice_icon_112"]];

    titleLabel.font = appDelegate.largeFont;
    
    self.navigationItem.titleView= titleLabel;
    [titleLabel sizeToFit];
    
//    self.datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.calendarView.bounds forYear:self.currentYear];
    self.datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.calendarView.bounds forYear:self.currentYear];
    self.datePickerView.delegate = self;
    self.datePickerView.dataSource = self;
    [self.calendarView addSubview:self.datePickerView];
    
    UILabel *bottomLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    bottomLabel.text = @"CALENDAR";
    bottomLabel.font = appDelegate.largeFont;
    bottomLabel.textColor = [UIColor whiteColor];
    
    _titleCendarItem.customView = bottomLabel;
    
    [bottomLabel sizeToFit];
    
    //
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Slice_icon_112"]];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Slice_icon_112"]];
    
   
}

- (void)dealloc {
    NSLog(@"Calendar died.");
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    // set white nav bar
    [self.navigationController.navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    
 
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    if ([[Banner shared] shouldShowAds]) {
         [[Banner shared]showSmallBannerAboveToolbar];
    }
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   
    NSLog(@"viewWilldisapper calendar");
    // set blue nav bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Slice_icon_112"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    [self.navigationController setNavigationBarHidden:YES];
    [[Banner shared]hideSmallBannerAboveToolbar];
}

//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    [self.navigationController setNavigationBarHidden:YES];
//}

//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//    [self.navigationController setNavigationBarHidden:NO];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLeftButtonClicked:(id)sender
{
    [self.datePickerView removeFromSuperview];
    --self.currentYear;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.text = [NSString stringWithFormat:@"%d",(int)self.currentYear];
    titleLabel.font =  appDelegate.largeFont;
    titleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Slice_icon_112"]];
    
    self.navigationItem.titleView= titleLabel;
    [titleLabel sizeToFit];
//    self.datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.calendarView.bounds forYear:self.currentYear];
    self.datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.calendarView.bounds forYear:self.currentYear month:self.currentMonth day:self.currentDay];
    self.datePickerView.delegate = self;
    self.datePickerView.dataSource = self;
    [self.calendarView addSubview:self.datePickerView];

}
- (IBAction)onRightButtonClicked:(id)sender
{
    [self.datePickerView removeFromSuperview];
    ++self.currentYear;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.text = [NSString stringWithFormat:@"%d",(int)self.currentYear];
    titleLabel.font = appDelegate.largeFont;
    titleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Slice_icon_112"]];
    
    self.navigationItem.titleView= titleLabel;
    [titleLabel sizeToFit];

    self.datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.calendarView.bounds forYear:self.currentYear month:self.currentMonth day:self.currentDay] ;
    self.datePickerView.delegate = self;
    self.datePickerView.dataSource = self;
    [self.calendarView addSubview:self.datePickerView];
}

- (IBAction)onBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
        
        [spotListTableViewController setFilterDate:self.pickedDate];
    }
}


#pragma mark - RSDFDatePickerViewDelegate
- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date
{
    self.pickedDate = date;
    if ([self.markedDates[date] isEqual: @YES]) {
        [self performSegueWithIdentifier:@"PushSPOTListTableViewController" sender:self];
    }
    
}

#pragma mark - RSDFDatePickerViewDataSource
- (NSDictionary *)datePickerViewMarkedDates:(RSDFDatePickerView *)view
{
    NSLog(@"datePickerViewMarkedDates");
    return self.markedDates;
}

@end
