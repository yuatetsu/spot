//
//  ELCAssetTablePicker.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCAsset.h"
#import "ELCAssetSelectionDelegate.h"
#import "ELCAssetPickerFilterDelegate.h"

typedef NS_ENUM(NSUInteger, TypeTablePicker) {
    
    TypeTablePickerPhoto,
    TypeTablePickerNameCard,
};

@protocol ELCAssetTablePickerProtocol;

@interface ELCAssetTablePicker : UITableViewController <ELCAssetDelegate>

@property (nonatomic, weak) id <ELCAssetTablePickerProtocol> pickerTimeLineDelegate;

@property (nonatomic, weak) id <ELCAssetSelectionDelegate> parent;
@property (nonatomic, strong) ALAssetsGroup *assetGroup;
@property (nonatomic, strong) NSMutableArray *preselectedImageFileNameArray;

//Edit by nguyen hai dang for spot project

@property (nonatomic, strong) NSMutableArray *elcNonPreselectedAssets;

@property (nonatomic, strong) NSMutableArray *preSelectedPhotoArray;
@property (nonatomic, strong) NSMutableArray *preSelectedNameCardArray;
@property (nonatomic, assign) TypeTablePicker typeTable;

//----

@property (nonatomic, strong) NSMutableArray *elcAssets;
@property (nonatomic, strong) IBOutlet UILabel *selectedAssetsLabel;
@property (nonatomic, assign) BOOL singleSelection;
@property (nonatomic, assign) BOOL immediateReturn;


//----

// optional, can be used to filter the assets displayed
@property(nonatomic, weak) id<ELCAssetPickerFilterDelegate> assetPickerFilterDelegate;

- (int)totalSelectedAssets;
- (void)preparePhotos;

- (void)doneAction:(id)sender;

@end

@protocol ELCAssetTablePickerProtocol <NSObject>

-(void)chooseTimeLineImageName:(NSString *)name;

@end