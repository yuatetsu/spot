//
//  LargeImagePagerViewController.m
//  SPOT
//
//  Created by framgia on 7/28/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "LargeImagePagerViewController.h"
#import "PhotoViewController.h"
#import "ImageScrollView.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface LargeImagePagerViewController () <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIButton *doneButton;


@end

@implementation LargeImagePagerViewController

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Slice_icon_82" ] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    // Do any additional setup after loading the view.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    compButton.frame = CGRectMake(240.0, 40.0, 60, 30.0);
    [compButton setTitle: @"Close" forState:UIControlStateNormal];
    [compButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [compButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [compButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    compButton.layer.cornerRadius = 6;
    compButton.layer.borderWidth=1.0f;
    compButton.layer.borderColor=[[UIColor colorWithRed:255 green:255 blue:255 alpha:0.3] CGColor];
    compButton.layer.masksToBounds = YES;
    [compButton.titleLabel setFont:appDelegate.normalFont];
    [compButton addTarget:self action:@selector(doClose)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:compButton];
    
    
}

- (void)doClose {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    
    
//    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.toolbar.hidden = YES;
    
    [ImageScrollView setImageFileNameArray:self.imageFileNameArray];
    PhotoViewController *pageZero = [PhotoViewController photoViewControllerForPageIndex:self.currentPageIndex];
    if (pageZero != nil)
    {
        self.dataSource = self;
        [self setViewControllers:@[pageZero]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
    }
    
    UISwipeGestureRecognizer* swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownFrom:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFrom:)];
//    [doubleTap setNumberOfTapsRequired:2];
//    [self.view addGestureRecognizer:doubleTap];
    
    
    
    // change status bar
    appDelegate.statusBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
}

/*- (void)handleDoubleTapFrom:(id)sender {
    NSLog(@"double tap");
    
//    
//    if(pageZero > pageZero.view.minimumZoomScale)
//        [pageZero.view setZoomScale:pageZero.view.minimumZoomScale animated:YES];
//    else
//        [self.view setZoomScale:self.view.maximumZoomScale animated:YES];
}*/

- (void)handleSwipeDownFrom:(id)sender {
    [self doClose];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    self.navigationController.toolbar.hidden = NO;
    
    // change status bar
    appDelegate.statusBar.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
 
    /*self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.doneButton addTarget:self
               action:@selector(onDoneButtonClicked)
     forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setTitle:@"done" forState:UIControlStateNormal];
    self.doneButton.frame = CGRectMake(260.0f, 20.0f, 40.0f, 40.0f);
    
    [self.view.window addSubview:self.doneButton];*/
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


/*- (void) onDoneButtonClicked
{
    [self.doneButton removeFromSuperview];
    [self dismissViewControllerAnimated:NO completion:nil];
}*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    return [PhotoViewController photoViewControllerForPageIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    return [PhotoViewController photoViewControllerForPageIndex:(index + 1)];
}
@end
