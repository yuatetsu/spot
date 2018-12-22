//
//  AssetCell.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetCell.h"
#import "ELCAsset.h"

#define cellImageMax 4


@implementation ELCAssetCell

//Using auto synthesizers

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.imageViewArray = mutableArray;
        
        NSMutableArray *overlayArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.overlayViewArray = overlayArray;
    }
    return self;
}

- (void)setAssets:(NSArray *)assets
{
    self.rowAssets = assets;
    for (UIImageView *view in _imageViewArray) {
        [view removeFromSuperview];
    }
    for (UIImageView *view in _overlayViewArray) {
        [view removeFromSuperview];
    }
    //set up a pointer here so we don't keep calling [UIImage imageNamed:] if creating overlays
    UIImage *overlayImage = nil;
    NSLog(@"%d",_rowAssets.count);
    for (int i = 0; i < [_rowAssets count]; ++i) {
        
        ELCAsset *asset = [_rowAssets objectAtIndex:i];
        
        if (i < [_imageViewArray count]) {
            
            UIImageView *imageView = [_imageViewArray objectAtIndex:i];
            
            if (!asset.isPreSelectedImage) {
                imageView.image = [UIImage imageWithCGImage:asset.asset.thumbnail];
            }else{
                imageView.image = [UIImage imageWithCGImage:asset.preSelectedImage];
                
            }
            
        } else {
            
            UIImageView *imageView ;
            if (!asset.isPreSelectedImage) {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.asset.thumbnail]];
                
            }else{
                NSLog(@"%@",[UIImage imageWithCGImage:asset.preSelectedImage]);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.preSelectedImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
                imageView.contentMode = UIViewContentModeCenter;
                imageView.clipsToBounds = YES;
            }
            
            [_imageViewArray addObject:imageView];
        }
        
        if (i < [_overlayViewArray count]) {
            UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = asset.selected ? NO : YES;
        } else {
            
            if(asset.typeSelected== TypeSelectedPhoto){
                
                if (asset.isTimelineImage) {
                    
                    overlayImage = [UIImage imageNamed:@"image_timeline.png"];
                    
                    if ([_delegate respondsToSelector:@selector(elcAssetCell:preTimeLineImageAtIndex:)]) {
                        
                        self.timeLineIndex = i;
                        [_delegate elcAssetCell:self preTimeLineImageAtIndex:i];
                    }
                }else{
                    
                    overlayImage = [UIImage imageNamed:@"image_nontimeline.png"];
                }
            }else{
                if (asset.isTimelineImage) {
                    
                    overlayImage = [UIImage imageNamed:@"namecard_timeline.png"];
                    
                    if ([_delegate respondsToSelector:@selector(elcAssetCell:preTimeLineImageAtIndex:)]) {
                        
                        self.timeLineIndex = i;
                        [_delegate elcAssetCell:self preTimeLineImageAtIndex:i];
                    }
                }else{
                    
                    overlayImage = [UIImage imageNamed:@"namecard_nontimeline.png"];
                }
            }
            
            UIImageView *overlayView = [[UIImageView alloc] initWithImage:overlayImage];
            [_overlayViewArray addObject:overlayView];
            overlayView.hidden = asset.selected ? NO : YES;
        }
    }
}

- (void)cellTapped:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint point = [tapRecognizer locationInView:self];
    //    CGFloat totalWidth = self.rowAssets.count * 75 + (self.rowAssets.count - 1) * 4;
    //    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
    CGFloat totalWidth = cellImageMax * 75 + (cellImageMax - 1) * cellImageMax;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
    CGRect frame = CGRectMake(startX, 2, 75, 75);
    
    for (int i = 0; i < [_rowAssets count]; ++i) {
        if (CGRectContainsPoint(frame, point)) {
            ELCAsset *asset = [_rowAssets objectAtIndex:i];
            UIImage *overlayImage ;
            
            if(!asset.selected){
                
                if(self.typeCell== TypeImageCellPhoto){
                    overlayImage = [UIImage imageNamed:@"image_nontimeline.png"];
                }else{
                    overlayImage = [UIImage imageNamed:@"namecard_nontimeline.png"];
                }
            }
            
            asset.typeSelected = self.typeCell;
            //case asset selected but not timeline
            if (asset.selected&&!asset.isTimelineImage) {
                
                if (self.typeCell ==TypeImageCellPhoto) {
                    
                    overlayImage = [UIImage imageNamed:@"image_timeline.png"];
                    if ([_delegate respondsToSelector:@selector(elcAssetCell:chooseTimeLineImageAtIndex:)]) {
                        
                        [_delegate elcAssetCell:self chooseTimeLineImageAtIndex:i];
                    }
                    asset.isTimelineImage = YES;
                    self.timeLineIndex = i;
                    
                }else{
                    
                    overlayImage = [UIImage imageNamed:@"namecard_timeline.png"];
                    if ([_delegate respondsToSelector:@selector(elcAssetCell:chooseTimeLineImageAtIndex:)]) {
                        
                        [_delegate elcAssetCell:self chooseTimeLineImageAtIndex:i];
                    }
                    self.timeLineIndex = i;
                    asset.isTimelineImage = YES;
                }
                
                UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
                overlayView.image = overlayImage;
            }
            else
            {
                asset.selected = !asset.selected;
                if (!asset.selected) {
                    //case asset set selected NO
                    asset.isTimelineImage = NO;
                    if(i==self.timeLineIndex){
                        self.timeLineIndex = NON_TIMELINE;
                        if ([_delegate respondsToSelector:@selector(disableTimeLineIndex)]) {
                            
                            [_delegate disableTimeLineIndex];
                        }
                    }
                }
                UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
                overlayView.image = overlayImage;
                overlayView.hidden = !asset.selected;
                break;
            }
        }
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}

- (void)layoutSubviews
{
    CGFloat totalWidth = cellImageMax * 75 + (cellImageMax - 1) * cellImageMax;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
    CGRect frame = CGRectMake(startX, 2, 75, 75);
    
    for (int i = 0; i < [_rowAssets count]; ++i) {
        UIImageView *imageView = [_imageViewArray objectAtIndex:i];
        [imageView setFrame:frame];
        [self addSubview:imageView];
        
        UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
        [overlayView setFrame:frame];
        [self addSubview:overlayView];
        
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}


@end
