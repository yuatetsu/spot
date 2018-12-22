//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"
#import <CoreLocation/CoreLocation.h>

@implementation ELCImagePickerController

//Using auto synthesizers

- (id)initImagePickerWithPreselectedImageFileNameArray:(NSMutableArray*)preselectedImageFileNameArray
{
    ELCAlbumPickerController *albumPicker = [[ELCAlbumPickerController alloc] initWithStyle:UITableViewStylePlain];
    
    self = [super initWithRootViewController:albumPicker];
    if (self) {
        self.maximumImagesCount = 4;
        [albumPicker setParent:self];
        [albumPicker setPreselectedImageFileNameArray:preselectedImageFileNameArray];
    }
    return self;
}

- (id)initImagePickerWithPreselectedPhotoAndNameCardFileNameArray:(NSMutableArray*)preselectedPhotoFileNameArray NameCard:(NSMutableArray *)preselectedNameCardFileNameArray WithType:(TypeImageTablePicker)type{
    
    ELCAlbumPickerController *albumPicker = [[ELCAlbumPickerController alloc] initWithStyle:UITableViewStylePlain];
    
    
    self = [super initWithRootViewController:albumPicker];
    if (self) {
        self.maximumImagesCount = 4;
        [albumPicker setParent:self];
        [albumPicker setPreselectedNameCardArray:preselectedNameCardFileNameArray];
        [albumPicker setPreselectedPhotoArray:preselectedPhotoFileNameArray];
        albumPicker.typeTable = type;
    }
    return self;
    
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.maximumImagesCount = 4;
    }
    return self;
}



- (void)cancelImagePicker
{
    if ([_imagePickerDelegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
        [_imagePickerDelegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
    }
}

- (BOOL)shouldSelectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
    BOOL shouldSelect = previousCount < self.maximumImagesCount;
    if (!shouldSelect) {
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Only %d photos please!", nil), self.maximumImagesCount];
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"You can only send %d photos at a time.", nil), self.maximumImagesCount];
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"Okay", nil), nil] show];
    }
    return shouldSelect;
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)selectedAssets:(NSArray *)elcAssets
{
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for(ELCAsset *elcAasset in elcAssets) {
        
        NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
        
        if (!elcAasset.isPreSelectedImage) {
            
            ALAsset *asset = elcAasset.asset;
            id obj = [asset valueForProperty:ALAssetPropertyType];
            if (!obj) {
                continue;
            }
        
            CLLocation* wgs84Location = [asset valueForProperty:ALAssetPropertyLocation];
            if (wgs84Location) {
                [workingDictionary setObject:wgs84Location forKey:ALAssetPropertyLocation];
            }
            
            [workingDictionary setObject:obj forKey:UIImagePickerControllerMediaType];
            
            //This method returns nil for assets from a shared photo stream that are not yet available locally. If the asset becomes available in the future, an ALAssetsLibraryChangedNotification notification is posted.
            ALAssetRepresentation *assetRep = [asset defaultRepresentation];
            
            if(assetRep != nil) {
                CGImageRef imgRef = nil;
                //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
                //so use UIImageOrientationUp when creating our image below.
                UIImageOrientation orientation = UIImageOrientationUp;
                
                if (_returnsOriginalImage) {
                    imgRef = [assetRep fullResolutionImage];
                    orientation = [assetRep orientation];
                } else {
                    imgRef = [assetRep fullScreenImage];
                }
                UIImage *img = [UIImage imageWithCGImage:imgRef
                                                   scale:1.0f
                                             orientation:orientation];
                [workingDictionary setObject:img forKey:UIImagePickerControllerOriginalImage];
                [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
                [workingDictionary setObject:[NSNumber numberWithInt:elcAasset.typeSelected] forKey:IMAGE_TYPE];
                [workingDictionary setObject:[NSNumber numberWithBool:elcAasset.isTimelineImage] forKey:TIME_LINE_KEY];
                [returnArray addObject:workingDictionary];
            }
        }else{
            
            [workingDictionary setObject:elcAasset forKey:IMAGE_PRESELECT_RETURNED];
            [returnArray addObject:workingDictionary];
        }
        
    }
    if (_imagePickerDelegate != nil && [_imagePickerDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
        [_imagePickerDelegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:returnArray];
    } else {
        [self popToRootViewControllerAnimated:NO];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

@end
