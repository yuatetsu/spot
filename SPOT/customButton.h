//
//  customButton.h
//  SPOT
//
//  Created by nguyen hai dang on 9/16/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customButton : UIButton


@property (nonatomic, assign)BOOL selected;

@property (nonatomic, strong)UIImage *selectedImage;

@property (nonatomic, strong)UIImage *nonSelectImage;

-(void)setSelectedStatus:(BOOL)selected;

@end
