//
//  GuideBookInfoMemoItemView.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/7/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "GuideBookInfoMemoItemView.h"
#import "MMMarkdown.h"

@implementation GuideBookInfoMemoItemView


- (id)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        [self addTextView:text withWidth:300];
        [self setBounds:CGRectMake(0, 0, 320, self.textView.frame.size.height - 10)];
        [self addSeparatorView];
    }
    
    return self;
}


- (void)addTextView: (NSString *)text withWidth:(float)width {
    //    UIFont *font = appDelegate.smallFont;
    @autoreleasepool {
        UITextView *textView = [[UITextView alloc] init];
        //    NSError *error;
        CGRect rect;
        if ([StringHelpers isNilOrWhitespace:text]) {
            rect = CGRectMake(0, 0, 0, 20);
        }
        else {
            NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:text extensions:MMMarkdownExtensionsGitHubFlavored error:NULL];
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            
            rect = [attributedString boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            
            textView.attributedText = attributedString;
        }
        
        int x = width >= 300 ? 8 : 30;
        textView.frame = CGRectMake(x, -1, width, (int)rect.size.height + textView.textContainerInset.bottom + textView.textContainerInset.top + 15);
        textView.opaque = YES;
        //    textView.font = font;
        textView.editable = NO;
        textView.scrollEnabled = NO;
        self.textView = textView;
        [self addSubview:textView];

    }
}

@end
