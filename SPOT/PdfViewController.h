//
//  PdfViewController.h
//  SPOT
//
//  Created by framgia on 8/5/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDHTMLtoPDF.h"
#import "SPOT.h"
#import "GuideBook.h"

@interface PdfViewController : UIViewController

@property (strong, nonatomic) SPOT* spot;
@property (strong, nonatomic) GuideBook* guideBook;
@property (strong, nonatomic) NDHTMLtoPDF* PDFCreator;

@property (weak, nonatomic) IBOutlet UIWebView* pdfWebView;

- (IBAction)onActionButtonClicked:(id)sender;
- (IBAction)onBackButtonClicked:(id)sender;
@end
