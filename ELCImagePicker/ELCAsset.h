//
//  Asset.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

//Add by nguyen hai dang for project spot

typedef NS_ENUM(NSUInteger, TypeSelected) {

    TypeSelectedPhoto,
    TypeSelectedNameCard,
};

@class ELCAsset;

@protocol ELCAssetDelegate <NSObject>

@optional
- (void)assetSelected:(ELCAsset *)asset;
- (BOOL)shouldSelectAsset:(ELCAsset *)asset;
@end


@interface ELCAsset : NSObject

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, weak) id<ELCAssetDelegate> parent;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) TypeSelected typeSelected;
@property (nonatomic, assign) BOOL isPreSelectedImage;
@property (nonatomic, assign) CGImageRef preSelectedImage;
@property (nonatomic, strong) NSString * preSelectedImageFileName;
@property (nonatomic, assign) BOOL isTimelineImage;

- (id)initWithAsset:(ALAsset *)asset;

@end