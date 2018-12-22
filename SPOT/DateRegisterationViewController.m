//
//  DateRegisterationViewController.m
//  SPOT
//
//  Created by framgia on 7/21/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "DateRegisterationViewController.h"
#import "AppDelegate.h"
@interface DateRegisterationViewController ()

@end

@implementation DateRegisterationViewController

NSDateFormatter *formatter;
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
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    [self.currentDateLabel setText:[formatter stringFromDate:[NSDate date]]];
    self.currentDateLabel.font = appDelegate.largeFont;
    [self.datePicker setDate:self.spot.date];
   
}

- (void)dealloc {
    self.spot = nil;
    NSLog(@"Date died.");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) onDatePickerValueChanged:(id)sender
{
    // save spot here -> low performance
}

- (void)saveSpot {
    NSLog(@"saveSpot");
    NSLog(@"selected date:%@",[self.datePicker date]);
    self.spot.date = [self.datePicker date];
    // save
    
    __weak SPOT *spot = self.spot;
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    [magicalContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            SPOT *innerSpot = spot;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [appDelegate saveSpotToXMLForSync:innerSpot];
            });
        }
    }];
}

- (IBAction) onDoneButtonClicked:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = false;
    NSLog(@"CALENDAR onDoneButtonClicked");
    //save then quit
    [self saveSpot];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
