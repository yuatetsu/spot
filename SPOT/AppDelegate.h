//
//  AppDelegate.h
//  SPOT
//
//  Created by framgia on 7/4/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopScreenViewController.h"
#import "CreateSPOTViewController.h"
#import "ActionSheetSimulationView.h"
#import "SPOT.h"
#import "LTHPasscodeViewController.h"
#import "TrafficType.h"
#import "ImageCacher.h"



@protocol AppDelegateEventDropboxAndiCloud;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
//    LTHPasscodeViewController *_passcodeController;
}

@property (nonatomic,weak)id<AppDelegateEventDropboxAndiCloud>delegate_dropbox_icloud;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *darkView;
@property (strong, nonatomic) ActionSheetSimulationView *actionSheetSimulationView;
@property (strong, nonatomic) TopScreenViewController *topScreenViewController;
@property (strong, nonatomic) CreateSPOTViewController *createSPOTViewController;
@property (strong, nonatomic) UIAlertView *alertView;

@property (strong, nonatomic) NSArray *transportationList;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong)NSTimer *timerSyncDropbox;
@property (nonatomic, strong)NSTimer *timerSynciCloud;

@property (strong, nonatomic) NSString *applicationDocumentsDirectory;
@property (strong, nonatomic) NSString *applicationDocumentsDirectoryForImage;
@property (strong, nonatomic) NSString *applicationDocumentsDirectoryForSpotData;
@property (strong, nonatomic) NSString *applicationDocumentsDirectoryForGuideBookData;
@property (strong, nonatomic) NSString *applicationDocumentsDirectoryForMemoVoice;
@property (strong, nonatomic) NSString *applicationTempDirectory;

@property (nonatomic) UIView *statusBar;

@property (assign, nonatomic) BOOL isSyncingFoursquare;

@property (strong, nonatomic) SPOT *spot;

@property (strong, nonatomic) UIImage *cellBackgroundImage;
@property (strong, nonatomic) UIFont *smallFont;
@property (strong, nonatomic) UIFont *normalFont;
@property (strong, nonatomic) UIFont *largeFont;

// cache image

@property (nonatomic) ImageCacher *detailsImageCacher;

@property (nonatomic) ImageCacher *spotSlideImageCacher;

@property (nonatomic) ImageCacher *guideBookSlideImageCacher;

@property (strong, nonatomic) NSFetchedResultsController *spotFetchedResultsController;

- (void) showActionSheetSimulationViewForSpot:(SPOT*)spot completetion:(void (^)())complete;
- (void) hideActionSheetSimulationView;

- (void)saveContext;

- (NSString*)saveSpotToXML:(SPOT *)spot;
- (void)parseXMLToSpotObject:(NSURL*)xmlString;

- (NSString*)saveGuideBookToXML:(GuideBook *)guideBook;
- (void)parseXMLToGuideBookObject:(NSURL*)xmlString;



- (void)saveGuideBookToXMLForSync:(GuideBook *)guideBook;
- (GuideBook *) parseXMLSyncDataToGuideBookObject:(NSURL*)xmlFileUrl newEntity:(BOOL)newEntity;

- (void)saveSpotToXMLForSync:(SPOT *)spot;
- (SPOT*) parseXMLSyncDataToSpotObject:(NSURL*)xmlFileUrl newEntity:(BOOL)newEntity;

- (void)creatTimerForSync;

-(NSMutableDictionary*)getModifiedDateDropboxFromFilename:(NSString*)filename;
-(void)updateDropboxModifiedDateDataDatabaseforNewEntity:(BOOL)isNewEntity data:(NSMutableDictionary*)data;

- (UIImage *)getTrafficIconByType:(int)type;

- (void) startSyncFoursquare;

- (UIImage *)getImageWithName:(NSString *)name;

@end

@protocol AppDelegateEventDropboxAndiCloud <NSObject>

-(void)handleEventLoginFromDropbox:(BOOL)success;

-(void)handleAutoSyncDropbox;

-(void)handleAutoSynciCloud;

@end
