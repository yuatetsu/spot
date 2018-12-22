//
//  TagCell.h
//  SPOT
//
//  Created by Truong Anh Tuan on 8/28/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "Tag.h"

@class TagCell;

@protocol TagCellDelegate <NSObject, SWTableViewCellDelegate>

- (void)tagCellDidEndEditing:(TagCell *)tagCell;

@end

@interface TagCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UITextField *tagTextField;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UILabel *spotCountLabel;

@property (weak, nonatomic) id <TagCellDelegate> delegate;


- (IBAction)onDoneButtonClicked:(id)sender;
- (void)beginEditing;
- (void)addUtilityButton;


@end
