//
//  GuideBookCell.h
//  SPOT
//
//  Created by Truong Anh Tuan on 8/14/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface GuideBookCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *pdfFilenameLabel;


@property (weak, nonatomic) IBOutlet UIImageView *spotImageView;


@property (weak, nonatomic) IBOutlet UIView *contentView;


-(void)addUtilityButton;

@end
