//
//  AssetCell.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TypeImageCellPicker) {
    
    TypeImageCellPhoto,
    TypeImageCellNameCard,
};

#define NON_TIMELINE 9999

@protocol ELCAssetCellTimeLineDelegate;

@interface ELCAssetCell : UITableViewCell

@property (nonatomic, assign) TypeImageCellPicker typeCell;

@property (nonatomic, weak) id <ELCAssetCellTimeLineDelegate> delegate;

@property (nonatomic, strong) NSArray *rowAssets;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *overlayViewArray;
@property (nonatomic, assign) NSUInteger timeLineIndex;

- (void)setAssets:(NSArray *)assets;

@end

@protocol ELCAssetCellTimeLineDelegate <NSObject>

- (void) elcAssetCell:(ELCAssetCell *)cell chooseTimeLineImageAtIndex:(NSUInteger) index;
- (void) disableTimeLineIndex ;
- (void) elcAssetCell:(ELCAssetCell *)cell preTimeLineImageAtIndex:(NSUInteger) index;

@end