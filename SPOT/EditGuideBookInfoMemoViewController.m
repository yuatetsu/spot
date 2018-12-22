//
//  EditGuideBookInfoMemoViewController.m
//  SPOT
//
//  Created by framgia on 8/21/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "EditGuideBookInfoMemoViewController.h"
#import "AppDelegate.h"
@interface EditGuideBookInfoMemoViewController ()

@end

@implementation EditGuideBookInfoMemoViewController
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
    self.textView.text = self.guideBookInfo.memo;
    
    self.textView.font = appDelegate.normalFont;
}

- (void)dealloc {
    NSLog(@"GuideBook memo died.");
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.toolbar.hidden = YES;
    
    [self.textView becomeFirstResponder];
}

- (IBAction)onBackButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onDoneButtonClicked:(id)sender {
    self.guideBookInfo.memo = self.textView.text;
    
    __weak GuideBook *guideBook = self.guideBookInfo.guide_book;
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    // save
    [magicalContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            GuideBook *innerGuideBook = guideBook;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                AppDelegate *delegateApp = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [delegateApp saveGuideBookToXMLForSync:innerGuideBook];
            });
        }
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    self.guideBookInfo.memo = self.textView.text;
//    
//    __weak GuideBook *guideBook = self.guideBookInfo.guide_book;
//    
//    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
//    // save
//    [magicalContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
//        if (success) {
//            GuideBook *innerGuideBook = guideBook;
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//                AppDelegate *delegateApp = (AppDelegate*)[UIApplication sharedApplication].delegate;
//                [delegateApp saveGuideBookToXMLForSync:innerGuideBook];
//            });
//        }
//    }];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
