//
//  SpotCell.h
//  SPOT
//
//  Created by Truong Anh Tuan on 9/27/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "SWTableViewCell.h"

@protocol SpotCellDelegate <SWTableViewCellDelegate>

- (void)longPressGestureRecognizeOnCell:(SWTableViewCell *)cell;

@end

@interface SpotCell : SWTableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *detailsImageView;


@property (weak, nonatomic) IBOutlet UILabel *spotNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) id <SpotCellDelegate> delegate;


-(void)addUtilityButton;

@end
