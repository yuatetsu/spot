//
//  PdfViewController.m
//  SPOT
//
//  Created by framgia on 8/5/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "PdfViewController.h"
#import "HtmlGenerateHelper.h"
#import "AppDelegate.h"
#import "Image.h"
#import "Tag.h"
#import "BlackActivityIndicatorView.h"
#import "StringHelpers.h"
#import "TTOpenInAppActivity.h"


@interface PdfViewController () <UIDocumentInteractionControllerDelegate, UIWebViewDelegate>
{
}

@property (nonatomic) BlackActivityIndicatorView *activityIndicator;

@property (nonatomic) NSData *pdfData;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractiveController;

@property (strong, nonatomic) NSURL* currentPDFFileUrl;

@end

@implementation PdfViewController

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
    BlackActivityIndicatorView *activityIndicator = [[BlackActivityIndicatorView alloc] initWithTopDistance:150];
    self.activityIndicator = activityIndicator;
    
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    self.pdfWebView.delegate = self;
    self.pdfWebView.dataDetectorTypes = UIDataDetectorTypeNone;
   
    
    @autoreleasepool {
        if (self.spot)
        {
            NSString *fileName =  [StringHelpers validFileNameFromString:self.spot.spot_name];
            
            NSString *fullHtmlString = [HtmlGenerateHelper generateHtmlStringForSpot:self.spot];
            [self generatePDFFromHtmlUsingBlocks:fullHtmlString saveToPath:[[appDelegate applicationTempDirectory] stringByAppendingPathComponent:[(fileName ? fileName : @"noname")stringByAppendingPathExtension:@"pdf"]]];
            
        }
        else if (self.guideBook)
        {
            NSString *fileName =  [StringHelpers validFileNameFromString:self.guideBook.guide_book_name];
            NSString *fullHtmlString = [HtmlGenerateHelper generateHtmlStringForGuideBook:self.guideBook];
            [self generatePDFFromHtmlUsingBlocks:fullHtmlString saveToPath:[[appDelegate applicationTempDirectory] stringByAppendingPathComponent:[(fileName ? fileName : @"noname") stringByAppendingPathExtension:@"pdf"]]];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.pdfWebView loadHTMLString: @"" baseURL: nil];
    [self.pdfWebView stopLoading];
    [self.pdfWebView setDelegate:nil];
    [self.pdfWebView removeFromSuperview];
    [self setPdfWebView:nil];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    self.pdfWebView.delegate = nil;
}

- (void)dealloc {
    
    NSLog(@"PDF died.");
}

- (void) generatePDFFromHtmlUsingBlocks:(NSString*)html saveToPath:(NSString*)filePath
{
    @autoreleasepool {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"layout_for_spot_pdf/guidebook" withExtension:@"html"];
        
        //self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:url pathForPDF:filePath pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(0, 0, 0, 0) successBlock:^(NDHTMLtoPDF *htmlToPDF) {
        
        __weak PdfViewController *weakSelf = self;
        
        self.PDFCreator = [NDHTMLtoPDF createPDFWithHTML:html baseURL:url pathForPDF:filePath pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 0, 10, 0) successBlock:^(NDHTMLtoPDF *htmlToPDF) {
            
            PdfViewController *innerSelf = weakSelf;
            
            [innerSelf.activityIndicator stopAnimating];
            //        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
            NSURL * url=[NSURL fileURLWithPath:htmlToPDF.PDFpath];
            NSURLRequest * request=[[NSURLRequest alloc] initWithURL:url];
            [innerSelf.pdfWebView loadRequest:request];
            self.currentPDFFileUrl = url;
            
            
        } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
            
            PdfViewController *innerSelf = weakSelf;
            
            [innerSelf.activityIndicator stopAnimating];
            innerSelf.currentPDFFileUrl = nil;
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onActionButtonClicked:(id)sender
{
    if (!self.currentPDFFileUrl) return;
   
    //Build a collection of activity items to share, in this case a url
    NSArray *activityItems = @[ self.currentPDFFileUrl ];
    
    TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:self.view andBarButtonItem:sender];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[openInAppActivity]];
    openInAppActivity.superViewController = activityViewController;
    // Show UIActivityViewController
    [self presentViewController:activityViewController animated:YES completion:NULL];
    
    return;
}
- (IBAction)onBackButtonClicked:(id)sender
{
    [[NSFileManager defaultManager]removeItemAtPath:self.currentPDFFileUrl.path error:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

// UIWebViewDelegate Methods
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

@end
