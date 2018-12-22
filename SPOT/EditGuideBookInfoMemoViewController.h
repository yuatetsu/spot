//
//  EditGuideBookInfoMemoViewController.h
//  SPOT
//
//  Created by framgia on 8/21/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideBookInfo.h"

@interface EditGuideBookInfoMemoViewController : UIViewController

@property (strong, nonatomic) GuideBookInfo* guideBookInfo;

@property (strong, nonatomic) IBOutlet UITextView* textView;

@end
