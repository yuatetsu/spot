//
//  KeyboardToolbarView.m
//  SPOT
//
//  Created by framgia on 7/17/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "KeyboardToolbarView.h"
#import "AppDelegate.h"
#import "Image.h"
#import "MBProgressHUD.h"
#import "SPOT+Image.h"

@interface KeyboardToolbarView(){
    
}

@end

@implementation KeyboardToolbarView


AppDelegate *appDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        appDelegate = [UIApplication sharedApplication].delegate;
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        appDelegate = [UIApplication sharedApplication].delegate;
    }
    return self;
    
    
}

-(void)awakeFromNib{
    
    [self creatIconsForView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleReloadCameraItemImage) name:@"ReloadImageCameraBarItemInKeyboardToolbar" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateCameraItemImage) name:@"UpdateImageCameraBarItemInKeyboardToolbar" object:nil];
    
    _touch = NO;
}


-(void)handleReloadCameraItemImage{
    
    [MBProgressHUD showHUDAddedTo:self.thumbnail animated:YES];
}



-(void)updateCameraItemImage{
    
    [MBProgressHUD hideHUDForView:self.thumbnail animated:YES];
    [self willMoveToSuperview:self.superview];
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    
    _touch = NO;
    
    if(appDelegate.createSPOTViewController.spot){
        
        if (appDelegate.createSPOTViewController.spot.date) {
            
            _selectedCalendarView.hidden = NO;
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:appDelegate.createSPOTViewController.spot.date];
            
            _pointSelectCalendar.image = [UIImage imageNamed:@"Slice_icon_39"];
            
            [_btnCalendar setSelectedStatus:YES];
            _monthlabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)components.day,(long)components.month];
            _yearlabel.text = [NSString stringWithFormat:@"%ld",(long)components.year];
            _monthlabel.textColor = [UIColor colorWithRed:83.0f/255.0f green:180.0f/255.0 blue:239.0f/255.0f alpha:1.0]  ;
            _yearlabel.textColor = [UIColor colorWithRed:83.0f/255.0f green:180.0f/255.0 blue:239.0f/255.0f alpha:1.0]  ;
            
        }
        else{
            
            _pointSelectCalendar.image = [UIImage imageNamed:@"Slice_icon_37"];
            _selectedCalendarView.hidden = YES;
            [_btnCalendar setSelectedStatus:NO];
        }
        if (appDelegate.createSPOTViewController.spot.traffic.intValue>0) {
            
            [_btnTraffic setSelectedStatus:YES];
            _pointSelectTraffic.image = [UIImage imageNamed:@"Slice_icon_39"];
        }
        else{
            
            [_btnTraffic setSelectedStatus:NO];
            _pointSelectTraffic.image = [UIImage imageNamed:@"Slice_icon_37"];
        }
        
        if (appDelegate.createSPOTViewController.spot.image.count) {
            
//            UIImage *thumnailImage;
//            
//            @autoreleasepool {
//                
////                Image *imageObject = [appDelegate.createSPOTViewController.spot allObjects];
//                
//                UIImage *image = [UIImage imageWithContentsOfFile:[[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:spot]];
//                
//                thumnailImage = [ImageUtility resizeToSmallerImage:image withNewSize:_btnPhoto.frame.size isCut:YES];
//                
//                
//            }
            
            UIImage *image = [UIImage imageWithContentsOfFile:[[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:[appDelegate.createSPOTViewController.spot firstImageFileName]]];
            
            UIImage *thumnailImage = [ImageUtility centerModeImageFrom:image withFrameWidth:_btnPhoto.frame.size.width andFrameHeight:_btnPhoto.frame.size.height];
            
            _thumbnail.image = thumnailImage;
            _thumbnail.contentMode = UIViewContentModeCenter;
            _thumbnail.clipsToBounds = YES;
            [_btnPhoto setSelectedStatus:YES];
            _pointSelectPhoto.image = [UIImage imageNamed:@"Slice_icon_39"];
            
        }else{
            
            _pointSelectPhoto.image = [UIImage imageNamed:@"Slice_icon_37"];
            [_btnPhoto setSelectedStatus:NO];
            _thumbnail.image = nil;
        }
        
        
        if (appDelegate.createSPOTViewController.spot.address.length) {
            
            [_btnAdress setSelectedStatus:YES];
            _pointSelectAddress.image = [UIImage imageNamed:@"Slice_icon_39"];
        }
        else{
            
            [_btnAdress setSelectedStatus:NO];
            _pointSelectAddress.image = [UIImage imageNamed:@"Slice_icon_37"];
        }
        
        
        if (appDelegate.createSPOTViewController.spot.tag.count) {
            
            _selectedTagsView.hidden = NO;
            _nonSelectTagsView.hidden = YES;
            _tagLbl.text = [NSString stringWithFormat:@"%d",appDelegate.createSPOTViewController.spot.tag.count];
            _pointselectTag.image = [UIImage imageNamed:@"Slice_icon_39"];
        }
        else{
            
            _selectedTagsView.hidden = YES;
            _nonSelectTagsView.hidden = NO;
            _pointselectTag.image = [UIImage imageNamed:@"Slice_icon_37"];
        }
        
    }
}

-(void)creatIconsForView{
    _pointSelectAddress.image = [UIImage imageNamed:@"Slice_icon_37"];
    _pointSelectCalendar.image = [UIImage imageNamed:@"Slice_icon_37"];
    _pointSelectPhoto.image = [UIImage imageNamed:@"Slice_icon_37"];
    _pointselectTag.image = [UIImage imageNamed:@"Slice_icon_37"];
    _pointSelectTraffic.image = [UIImage imageNamed:@"Slice_icon_37"];
    
    _selectedCalendarView.hidden = YES;
    _btnCalendar.nonSelectImage = [UIImage imageNamed:@"Slice_icon_25"];
    _monthlabel.font = appDelegate.smallFont;
    _yearlabel.font = appDelegate.smallFont;
    
    
    _btnTraffic.selectedImage = [UIImage imageNamed:@"Slice_icon_62"];
    _btnTraffic.nonSelectImage =  [UIImage imageNamed:@"Slice_icon_22"];
    
    _btnPhoto.nonSelectImage  =  [UIImage imageNamed:@"Slice_icon_34"];
    _btnPhoto.selectedImage  =  [UIImage imageNamed:@"Slice_icon_31"];
    
    _btnAdress.selectedImage = [UIImage imageNamed:@"Slice_icon_19"];
    _btnAdress.nonSelectImage = [UIImage imageNamed:@"Slice_icon_28"];
    
    
    _selectedTagsView.hidden = YES;
    _tagLbl.font = appDelegate.smallFont;
    
}





-(IBAction)onDateButtonClicked:(id)sender
{
    [self.delegate onCalendarButtonClicked:self];
//    if (_touch ==NO) {
//        NSLog(@"onDateButtonClicked");
//        [self.delegate keyboardButtonClicked:self];
//        //[appDelegate.createSPOTViewController dismissKeyboard];
//        [appDelegate.createSPOTViewController performSegueWithIdentifier:@"PushDateRegisterationViewController" sender:self];
//        _touch = YES;
//    }
    
}
-(IBAction)onTrafficButtonClicked:(id)sender
{
    [self.delegate onTrafficButtonClicked:self];
//    if (_touch ==NO) {
//        [self.delegate keyboardButtonClicked:self];
//        _touch = YES;
//        NSLog(@"onTrafficButtonClicked");
//        //[appDelegate.createSPOTViewController dismissKeyboard];
//        [appDelegate.createSPOTViewController performSegueWithIdentifier:@"PushTrafficRegisterationViewController" sender:self];
//        
//    }
    
}
-(IBAction)onPhotoButtonClicked:(id)sender
{
    [self.delegate onCameraButtonClicked:self];
//    if (_touch ==NO) {
//        [self.delegate keyboardButtonClicked:self];
//        _touch = YES;
//        
//        NSLog(@"onPhotoButtonClicked");
//        [appDelegate.createSPOTViewController dismissKeyboard];
//        [appDelegate showActionSheetSimulationViewForSpot:appDelegate.createSPOTViewController.spot];
//    }
}
-(IBAction)onAddressButtonClicked:(id)sender
{
    [self.delegate onAddressButtonClicked:self];
//    if (_touch ==NO) {
//        [self.delegate keyboardButtonClicked:self];
//        _touch = YES;
//        
//        NSLog(@"onAddressButtonClicked");
//        //[appDelegate.createSPOTViewController dismissKeyboard];
//        [appDelegate.createSPOTViewController performSegueWithIdentifier:@"PushAddressRegisterationViewController" sender:self];
//    }
}
-(IBAction)onTagButtonClicked:(id)sender
{
    [self.delegate onTagButtonClicked:self];

//    if (_touch ==NO) {
//        [self.delegate keyboardButtonClicked:self];
//        _touch = YES;
//        
//        NSLog(@"onDateButtonClicked");
//        //[appDelegate.createSPOTViewController dismissKeyboard];
//        [appDelegate.createSPOTViewController performSegueWithIdentifier:@"PushTagRegisterationViewController" sender:self];
//    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
