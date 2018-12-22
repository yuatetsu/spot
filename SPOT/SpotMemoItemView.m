//
//  SpotMemoItemView.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SpotMemoItemView.h"
#import "AppDelegate.h"
#import "MMMarkdown.h"
#import <CoreText/CoreText.h>

@implementation SpotMemoItemView

AppDelegate *appDelegate;

- (id)initWithText:(NSString *)text andHasMemo:(BOOL)hasMemo {
    
//    self = [super initWithText:text andImage:[appDelegate getImageWithName:@"Memo"]];
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        [self addImageView:[appDelegate getImageWithName:@"Memo"]];
        
        [self addTextView:text withWidth:280];
        
        [self setBounds:CGRectMake(0, 0, 320, self.textView.frame.size.height - 10)];
        [self addSeparatorView];
        
        self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, 35, 35)];
        UIImage *voiceImage = hasMemo ? [appDelegate getImageWithName:@"VoiceBlue"] : [appDelegate getImageWithName:@"Voice"];
        [button setImage:voiceImage forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onVoiceButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        self.voiceButton = button;
        
        CGRect rect = self.bounds;
        if (rect.size.height < 80) {
            rect.size.height = 80;
            self.bounds = rect;
            
            [self updateLayout];
        }
      
    }
    return self;
}

- (void)onVoiceButtonClicked {
    [self.delegate didClickVoiceButton:self];
}

- (void)addTextView: (NSString *)text withWidth:(float)width {
//    UIFont *font = appDelegate.smallFont;
    
    UITextView *textView = [[UITextView alloc] init];
//    NSError *error;
    CGRect rect;
    if ([StringHelpers isNilOrWhitespace:text]) {
        rect = CGRectMake(0, 0, 0, 20);
    }
    else {
//        NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:text error:&error];
        
        NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:text extensions:MMMarkdownExtensionsGitHubFlavored error:NULL];
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        
        NSLog(@"%@", attributedString);
        
        rect = [attributedString boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        
//        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
//        CGSize targetSize = CGSizeMake(320, CGFLOAT_MAX);
//        CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedString length]), NULL, targetSize, NULL);
//        CFRelease(framesetter);
//        
//        rect = CGRectMake(0, 0, fitSize.width, fitSize.height);
        
        textView.attributedText = attributedString;
    }
    
    int x = width >= 300 ? 8 : 30;
    textView.frame = CGRectMake(x, -1, width, (int)rect.size.height + textView.textContainerInset.bottom + textView.textContainerInset.top + 15);
    textView.opaque = YES;
//    textView.backgroundColor = [UIColor yellowColor];
    //    textView.font = font;
    textView.editable = NO;
    textView.scrollEnabled = NO;
//    textView.textColor = [UIColor darkGrayColor];
    self.textView = textView;
    [self addSubview:textView];
}



@end
