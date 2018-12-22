//
//  ActionSheetSimulationView.h
//  SPOT
//
//  Created by framgia on 7/16/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPOT.h"

typedef NS_ENUM(NSUInteger, TypeSelect) {
    
    TypeSelectPhoto,
    TypeSelectNameCard,
};

@interface ActionSheetSimulationView : UIView

@property (strong, nonatomic) SPOT* spot;

- (IBAction) onCancelButtonInActionSheetClicked: (id) sender;
- (IBAction) onTakePhotoButtonInActionSheetClicked: (id) sender;
- (IBAction) onTakePhotoOfNameCardButtonInActionSheetClicked: (id) sender;
- (IBAction) onChooseFromLibraryButtonInActionSheetClicked: (id) sender;
- (IBAction) onChooseFromLibraryForNameCardButtonInActionSheetClicked: (id) sender;
@end
