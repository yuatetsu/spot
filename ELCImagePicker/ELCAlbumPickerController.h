//
//  AlbumPickerController.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCAssetSelectionDelegate.h"
#import "ELCAssetPickerFilterDelegate.h"

typedef NS_ENUM(NSUInteger, TypeAlbumTablePicker) {
    
    TypeAlbumTablePickerPhoto,
    TypeAlbumTablePickerNameCard,
};



@interface ELCAlbumPickerController : UITableViewController <ELCAssetSelectionDelegate>

@property (nonatomic, weak) id<ELCAssetSelectionDelegate> parent;
@property (nonatomic, strong) NSMutableArray *assetGroups;
@property (nonatomic, strong) NSMutableArray *preselectedImageFileNameArray;



//Edit by nguyen hai dang for project spot

@property (nonatomic, strong) NSMutableArray *preselectedPhotoArray;
@property (nonatomic, strong) NSMutableArray *preselectedNameCardArray;
@property (nonatomic, assign) TypeAlbumTablePicker typeTable;

// optional, can be used to filter the assets displayed
@property (nonatomic, weak) id<ELCAssetPickerFilterDelegate> assetPickerFilterDelegate;

@end

