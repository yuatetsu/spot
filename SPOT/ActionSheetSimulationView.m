//
//  ActionSheetSimulationView.m
//  SPOT
//
//  Created by framgia on 7/16/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "ActionSheetSimulationView.h"
#import "ELCImagePickerController.h"
#import "AppDelegate.h"
#import "Image.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SPDropBox.h"
#import "iCloud+spotiCloudAddition.h"
#import "ELCAsset.h"
#import "MBProgressHUD.h"
#import "UIAlertView+Blocks.h"
#import "BlackActivityIndicatorView.h"

#define SIZE_THUMBNAIL CGSizeMake(75,75)

@interface ActionSheetSimulationView() <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ELCImagePickerControllerDelegate>

{
    BOOL isAddingPhoto;
    NSMutableDictionary *oldImageInfoDictionary;
    BlackActivityIndicatorView *activityIndicator;
    BOOL randomTimeLine;
    
}

// property for design
@property (weak, nonatomic) IBOutlet UIView *cameraActionsView;
@property (weak, nonatomic) IBOutlet UIView *cameraActionCancerView;
@property (weak, nonatomic) IBOutlet UILabel *takephotoLabel;
@property (weak, nonatomic) IBOutlet UILabel *chooseFromLibraryLabel;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *takeNamecardButton;
@property (weak, nonatomic) IBOutlet UIButton *choosePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseNamecardButton;
@property (strong, nonatomic) UIImagePickerController *picker;

@end
@implementation ActionSheetSimulationView

AppDelegate *appDelegate;
bool isTakingPhoto = false;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Action sheet died.");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)layoutSubviews
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleChoosedTimeLineImage:) name:@"ChoosedTimeLineImage" object:nil];
    
    self.cameraActionsView.layer.cornerRadius = 5;
    self.cameraActionsView.layer.masksToBounds = YES;
    self.cameraActionCancerView.layer.cornerRadius = 5;
    self.cameraActionCancerView.layer.masksToBounds = YES;
    self.takephotoLabel.font = self.chooseFromLibraryLabel.font = self.takePhotoButton.titleLabel.font = self.takeNamecardButton.titleLabel.font = self.chooseNamecardButton.titleLabel.font = self.choosePhotoButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_NORMAL_SIZE];
    activityIndicator = [[BlackActivityIndicatorView alloc] initWithTopDistance:150];
    
    [super layoutSubviews];
    
    randomTimeLine = YES;
    
}
- (IBAction) onCancelButtonInActionSheetClicked: (id) sender
{
    NSLog(@"onCancelButtonInActionSheetClicked");
    [appDelegate hideActionSheetSimulationView];
    if ((appDelegate.window.rootViewController==appDelegate.createSPOTViewController.parentViewController))
    {
        [appDelegate.createSPOTViewController.memoTextView becomeFirstResponder];
    }
}

- (IBAction) onTakePhotoButtonInActionSheetClicked: (id) sender
{
    NSLog(@"onTakePhotoButtonInActionSheetClicked");
    [appDelegate hideActionSheetSimulationView];
    isAddingPhoto = YES;
    [self takePhoto];
}
- (IBAction) onTakePhotoOfNameCardButtonInActionSheetClicked: (id) sender
{
    NSLog(@"onTakePhotoOfNameCardButtonInActionSheetClicked");
    [appDelegate hideActionSheetSimulationView];
    isAddingPhoto = NO;
    [self takePhoto];
}
- (IBAction) onChooseFromLibraryButtonInActionSheetClicked: (id) sender
{
    NSLog(@"onChooseFromLibraryButtonInActionSheetClicked");
    [appDelegate hideActionSheetSimulationView];
    isAddingPhoto = YES;
    [self selectPhoto : TypeSelectPhoto];
}
- (IBAction) onChooseFromLibraryForNameCardButtonInActionSheetClicked: (id) sender
{
    NSLog(@"onChooseFromLibraryForNameCardButtonInActionSheetClicked");
    [appDelegate hideActionSheetSimulationView];
    isAddingPhoto = NO;
    [self selectPhoto :TypeSelectNameCard];
}


- (void) takePhoto
{
    if (self.spot.image.count < 10) {
        isTakingPhoto=true;
        NSLog(@"take photo");
        if(!self.picker){
            self.picker = [[UIImagePickerController alloc] init];
            self.picker.delegate = self;
            self.picker.allowsEditing = YES;
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [appDelegate.window.rootViewController presentViewController:self.picker animated:YES completion:NULL];
    }
    else {
        RIButtonItem *okAlertBtn = [RIButtonItem new];
        okAlertBtn.label = @"OK";
        okAlertBtn.action = ^{
            if ((appDelegate.window.rootViewController==appDelegate.createSPOTViewController.parentViewController))
            {
                [appDelegate.createSPOTViewController.memoTextView becomeFirstResponder];
            }
        };
        
        [[[UIAlertView alloc]initWithTitle:@"Only 10 photos please!"
                                   message:@"You can only send 10 photos at a time." cancelButtonItem:okAlertBtn otherButtonItems:nil, nil]show];

    }
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak UIImagePickerController *selfPicker = picker;
    __weak ActionSheetSimulationView *weakSelf = self;
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        
        UIImage *originalImage = [UIImage imageWithData:UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.1)];
        
        if (!originalImage)
            return;
        
        __block UIImage *image = originalImage;
        
        [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
        [picker.view addSubview:activityIndicator];
        
        // Optionally set a placeholder image here while resizing happens in background
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
                if (error) {
                    NSLog(@"error");
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle: @"Save failed"
                                          message: @"Failed to save image"
                                          delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                    [alert show];
                } else {
                    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
                    {
                        ALAssetRepresentation *rep = [myasset defaultRepresentation];
                        __block NSString *fileName = [rep filename];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @autoreleasepool {
                                randomTimeLine = NO;
                                
                                ActionSheetSimulationView *innerSelf = weakSelf;
                                UIImagePickerController *innerPicker = selfPicker;
                                
                                if (!innerSelf.spot){
                                    innerSelf.spot = [SPOT MR_createEntity];
                                    innerSelf.spot.date = [NSDate date];
                                }
                                
                                if (!innerSelf.spot.time_line_image.length) {
                                    
                                    randomTimeLine = YES;
                                }
                                
                                
                                [innerSelf saveImageToDocumentDirectory:image withFilename:fileName type:isAddingPhoto isTimeLine:NO];
                                image = nil;
                                fileName = nil;
                                
                                if (!(appDelegate.window.rootViewController==appDelegate.createSPOTViewController.parentViewController))
                                {
                                    //  only push createSPOTViewController from topScreenViewController
                                    
                                    [MBProgressHUD hideHUDForView:innerPicker.view animated:YES];
                                    
                                    [innerPicker dismissViewControllerAnimated:YES completion:^{
                                        [appDelegate.topScreenViewController performSegueWithIdentifier:@"PushDetailsViewControllerNoAnimationWithImageSelected" sender:innerSelf];
                                        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                                            [appDelegate.topScreenViewController performSegueWithIdentifier:@"PushCreateSPOTViewControllerWithImageSelected" sender:innerSelf];
                                        }
                                    }];
                                    
                                }
                                else{
                                    
                                    [MBProgressHUD hideHUDForView:innerPicker.view animated:YES];
                                    [innerPicker dismissViewControllerAnimated:YES completion:nil];
                                }
                            }
                            
                        });
                        
                        
                    };
                    
                    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
                    {
                        NSLog(@"Can't get image - %@",[myerror localizedDescription]);
                    };
                    
                    [library assetForURL:assetURL
                             resultBlock:resultblock
                            failureBlock:failureblock];
                }
                
            }];
            
        });
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
    
    
}

- (void)saveImageToDocumentDirectory:(UIImage*)image withFilename:(NSString*)filename type:(BOOL)isPhoto isTimeLine:(BOOL)isTimeLine {
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    NSString *UUID = [[NSUUID UUID] UUIDString];
    NSString *guidFileName = [UUID stringByAppendingPathExtension:[filename pathExtension]];
    
    if (isTimeLine) {
        
        self.spot.time_line_image = guidFileName;
        randomTimeLine = NO;
    }
    
    if(randomTimeLine){
        
        self.spot.time_line_image = guidFileName;
        randomTimeLine = NO;
    }
    
    NSString *savedImagePath = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:guidFileName];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    // save image success ?
    if ([imageData writeToFile:savedImagePath atomically:NO])
    {
        Image *imageMagicalRecord = [Image MR_createInContext:context];
        imageMagicalRecord.image_file_name = guidFileName;
        imageMagicalRecord.origin_image_file_name = filename;
        imageMagicalRecord.image_size = [NSNumber numberWithUnsignedInteger:imageData.length];
        
        BOOL isNameCard = !isPhoto;
        imageMagicalRecord.is_name_card = [NSNumber numberWithBool:isNameCard];
        [self.spot addImageObject:imageMagicalRecord];
        
        // save
        
    }
    
    [context MR_saveOnlySelfAndWait];
}

- (void) selectPhoto :(int)type
{
    isTakingPhoto = false;
    NSLog(@"select photo");
    /*
     UIImagePickerController *picker = [[UIImagePickerController alloc] init];
     picker.delegate = self;
     picker.allowsEditing = YES;
     picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
     
     [self presentViewController:picker animated:YES completion:NULL];
     */
    
    NSMutableArray *selectedPhotoFileNameArray = [[NSMutableArray alloc] init];
    NSMutableArray *selectedNameCardFileNameArray = [[NSMutableArray alloc] init];
    for (Image *image in self.spot.image.allObjects)
    {
        NSLog(@"%@",image.origin_image_file_name);
        NSLog(@"%@",image.image_file_name);
        if(![image.is_name_card boolValue]){
            
            NSMutableArray *imageChoose = [NSMutableArray new];
            
            [imageChoose addObject:image.image_file_name];
            
            if (image.origin_image_file_name &&image.origin_image_file_name.length) {
                
                NSLog(@"%@",image.origin_image_file_name);
                [imageChoose addObject:image.origin_image_file_name];
            }
            else{
                
                [imageChoose addObject:@""];
            }
            
            [imageChoose addObject:image.image_size];
            
            if([self.spot.time_line_image isEqualToString:image.image_file_name]){
                
                [imageChoose addObject:[NSNumber numberWithBool:YES]];
            }
            else{
                
                [imageChoose addObject:[NSNumber numberWithBool:NO]];
            }
            
            [imageChoose addObject:[self resizeImageInDirectoryForSelect:image.image_file_name]];
            
            [selectedPhotoFileNameArray addObject:imageChoose];
        }
        else
        {
            NSMutableArray *imageChoose = [NSMutableArray new];
            
            [imageChoose addObject:image.image_file_name];
            
            if (image.origin_image_file_name &&image.origin_image_file_name.length) {
                
                [imageChoose addObject:image.origin_image_file_name];
            }
            else{
                
                [imageChoose addObject:@""];
            }
            
            [imageChoose addObject:image.image_size];
            
            if([self.spot.time_line_image isEqualToString:image.image_file_name]){
                
                [imageChoose addObject:[NSNumber numberWithBool:YES]];
            }
            else{
                
                [imageChoose addObject:[NSNumber numberWithBool:NO]];
            }
            [imageChoose addObject:[self resizeImageInDirectoryForSelect:image.image_file_name]];
            [selectedNameCardFileNameArray addObject:imageChoose];
            
        }
    }
    ELCImagePickerController *imagePicker = [ELCImagePickerController alloc];
    
    //    imagePicker = [imagePicker initImagePickerWithPreselectedImageFileNameArray:selectedImageFileNameArray];
    imagePicker = [imagePicker initImagePickerWithPreselectedPhotoAndNameCardFileNameArray:selectedPhotoFileNameArray  NameCard:selectedNameCardFileNameArray WithType:type];
    
    imagePicker.maximumImagesCount = 10; //Set the maximum number of images to select, defaults to 4
    imagePicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
    imagePicker.imagePickerDelegate = self;
    
    //Present modally
    [appDelegate.window.rootViewController presentViewController:imagePicker animated:YES completion:NULL];
    NSLog(@"dissmiss--------ActionSheet");
}


-(UIImage *)resizeImageInDirectoryForSelect:(NSString *)image_file_name{
    
    UIImage *reSizeImage;
    
    
    @autoreleasepool {
        
        UIImage *image = [UIImage imageWithContentsOfFile:[[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:image_file_name]];
        
        reSizeImage = [ImageUtility centerModeImageFrom:image withFrameWidth:75.0f andFrameHeight:75.0f];
    }
    
    NSLog(@"%@",reSizeImage);
    
    return reSizeImage;
}



- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    //    [picker.view addSubview:activityIndicator];
    //        [activityIndicator startAnimating];
    [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
    if (!(!info.count &&!(appDelegate.window.rootViewController==appDelegate.createSPOTViewController.parentViewController))) {
        
        
        if (!self.spot){
            self.spot = [SPOT MR_createEntity];
            //            self.spot.uuid = [[NSUUID UUID] UUIDString];
            self.spot.date = [NSDate date];
            
            //        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
            //        // save
            //        [magicalContext MR_saveOnlySelfAndWait];
            
        }
        
        if(appDelegate.window.rootViewController==appDelegate.createSPOTViewController.parentViewController){
            
            [picker dismissViewControllerAnimated:YES completion:NULL];
        }
        
        //    if (!oldImageInfoDictionary) {
        //        oldImageInfoDictionary = [NSMutableDictionary new];
        //    }
        
        // delete spot's images
        
        //if
        
        if([[NSUserDefaults standardUserDefaults]boolForKey:@"syncDropbox"]){
            
            if(self.spot.image.count>0){
                
                [[SPDropBox sharedInstance]forceStopIfRunning];
                
                [[SPDropBox sharedInstance]increaseDeleteCount:self.spot.image.count];
                
            }
        }
        
        for(NSMutableDictionary *imageItem in info)
        {
            //        [oldImageInfoDictionary setValue:image.is_name_card forKey:image.origin_image_file_name];
            ELCAsset *asset  = [imageItem objectForKey:IMAGE_PRESELECT_RETURNED];
            if (asset) {
                
                NSString *filename = asset.preSelectedImageFileName;
                NSString *savedImagePath = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:filename];
                
                if (!asset.selected) {
                    
                    NSError *error;
                    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:savedImagePath error:&error];
                    if (success) {
                    }
                    else
                    {
                        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                    }
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"image_file_name like %@ ",asset.preSelectedImageFileName];
                    NSArray *result =  [Image MR_findAllWithPredicate:predicate];
                    if (result.count>0) {
                        Image *image = result.firstObject;
                        [image MR_deleteEntity];
                    }
                    
                    if([[NSUserDefaults standardUserDefaults]boolForKey:@"syncDropbox"]){
                        
                        [[SPDropBox sharedInstance]deleteFileAtPath:[NSString stringWithFormat:@"/%@",[IMAGE_PATH stringByAppendingPathComponent:asset.preSelectedImageFileName]]];
                        
                    }
                    
                    else if([[NSUserDefaults standardUserDefaults]boolForKey:@"synciCloud"]){
                        
                        [[iCloud sharedCloud].remoteFiles removeObjectForKey:asset.preSelectedImageFileName];
                        
                        [[iCloud sharedCloud].localFiles removeObjectForKey:asset.preSelectedImageFileName];
                        
                        [[iCloud sharedCloud]deleteDocumentWithName:asset.preSelectedImageFileName completion:^(NSError *error) {
                            
                            if(error){
                                
                                NSLog(@"Could not delete file oniCloud -:%@ ",[error localizedDescription]);
                            }
                        }];
                    }
                    
                }else{
                    
                    // When change preselect type image to namecard or reverse
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"image_file_name like %@ ",asset.preSelectedImageFileName];
                    NSArray *result =  [Image MR_findAllWithPredicate:predicate];
                    
                    if (result.count>0) {
                        
                        Image *image = result.firstObject;
                        
                        if(!asset.typeSelected){
                            image.is_name_card = [NSNumber numberWithBool:NO];
                        }else{
                            image.is_name_card = [NSNumber numberWithBool:YES];
                        }
                        
                        if (randomTimeLine) {
                            
                            self.spot.time_line_image = image.image_file_name;
                        }
                    }
                    
                }
            }
        }
        
        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
        // save
        [magicalContext MR_saveOnlySelfAndWait];
        
        if (info.count>0) {
            
            for (int i = 0;i<info.count;i++)
            {
                
                NSObject *object = info[i];
                
                if(![object valueForKey:IMAGE_PRESELECT_RETURNED]){
                    
                    UIImage *image=[object valueForKey:@"UIImagePickerControllerOriginalImage"];
                    NSURL *assetURL=[object valueForKey:@"UIImagePickerControllerReferenceURL"];
                    __weak ActionSheetSimulationView *selfPointer = self;
                    
                    __block BOOL isTimeLine = [[object valueForKey:TIME_LINE_KEY]boolValue];
                    
                    NSLog(@"%@",image);
                    NSLog(@"%@",assetURL);
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    
//                    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
//                        ALAssetRepresentation *rep = [asset defaultRepresentation];
//                        
//                        // some time rep = nil (os 8.1 bug)
//                        if (rep) {
//                            if([[object valueForKey:IMAGE_TYPE]intValue]==TypeSelectPhoto){
//                                
//                                [selfPointer saveImageToDocumentDirectory:image withFilename:[rep filename] type:YES isTimeLine:isTimeLine];
//                            }
//                            else{
//                                [selfPointer saveImageToDocumentDirectory:image withFilename:[rep filename] type:NO isTimeLine:isTimeLine];
//                            }
//                        }
//                    } failureBlock:^(NSError *error) {
//                        NSLog(@"Can't get image - %@",[error localizedDescription]);
//                    }];
                    
                    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
                    {
                        ALAssetRepresentation *rep = [myasset defaultRepresentation];
                        
                        NSString *fileName = [rep filename];
                        // some time rep = nil (os 8.1 bug)
                        if (!fileName) {
                            fileName = [assetURL path];
                        }
                        if (fileName) {
                            if([[object valueForKey:IMAGE_TYPE]intValue]==TypeSelectPhoto){
                                
                                [selfPointer saveImageToDocumentDirectory:image withFilename:fileName type:YES isTimeLine:isTimeLine];
                            }
                            else{
                                [selfPointer saveImageToDocumentDirectory:image withFilename:fileName type:NO isTimeLine:isTimeLine];
                            }
                        }
                    };
                    
                    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
                    {
                        NSLog(@"Can't get image - %@",[myerror localizedDescription]);
                    };
                    
                    if (i==info.count-1) {
                        
                        if (!(appDelegate.window.rootViewController==appDelegate.createSPOTViewController.parentViewController))
                        {
                            //only push createSPOTViewController from topScreenViewController
                            
                            [appDelegate.topScreenViewController performSegueWithIdentifier:@"PushDetailsViewControllerNoAnimationWithImageSelected" sender:self];
                            if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                                [appDelegate.topScreenViewController performSegueWithIdentifier:@"PushCreateSPOTViewControllerWithImageSelected" sender:self];
                            }
                            
                            [appDelegate.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
                                
                            }];
                        }
                        
                    }
                    
                    [library assetForURL:assetURL
                             resultBlock:resultblock
                            failureBlock:failureblock];
                    //[appDelegate.selectedImageArray addObject:image];
                    //[appDelegate.selectedImageURLArray addObject:url];
                }
                else{
                    
                    if (i==info.count-1) {
                        
                        if (!(appDelegate.window.rootViewController==appDelegate.createSPOTViewController.parentViewController))
                        {
                            //only push createSPOTViewController from topScreenViewController
                            
                            [appDelegate.topScreenViewController performSegueWithIdentifier:@"PushDetailsViewControllerNoAnimationWithImageSelected" sender:self];
                            if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                                [appDelegate.topScreenViewController performSegueWithIdentifier:@"PushCreateSPOTViewControllerWithImageSelected" sender:self];
                            }
                            
                            [appDelegate.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
                                
                            }];
                        }
                    }
                }
            }
        }else{
            
            if (!(appDelegate.window.rootViewController==appDelegate.createSPOTViewController.parentViewController))
            {
                //only push createSPOTViewController from topScreenViewController
                
                [appDelegate.topScreenViewController performSegueWithIdentifier:@"PushDetailsViewControllerNoAnimationWithImageSelected" sender:self];
                if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                    [appDelegate.topScreenViewController performSegueWithIdentifier:@"PushCreateSPOTViewControllerWithImageSelected" sender:self];
                }
                
                [appDelegate.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
                    
                }];
            }
        }
    }else{
        
        [appDelegate.window.rootViewController.presentedViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


-(void)handleChoosedTimeLineImage: (NSNotification *)notification{
    
    NSString *imageName = [notification.userInfo objectForKey:@"time_line_image"];
    
    if(![imageName isEqualToString:@"random_image"]&&![imageName isEqualToString:@"not_random_image"]){
        
        randomTimeLine = NO;
        
        self.spot.time_line_image = imageName;
    }
    else if([imageName isEqualToString:@"not_random_image"]){
        
        randomTimeLine = NO;
    }
    else{
        
        randomTimeLine = YES;
    }
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
