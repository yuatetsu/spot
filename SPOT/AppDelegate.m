//
//  AppDelegate.m
//  SPOT
//
//  Created by framgia on 7/4/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Foursquare2.h"
#import "GDataXMLNode.h"
#import "Image.h"
#import "Country.h"
#import "Region.h"
#import "Tag.h"
#import "LTHPasscodeViewController.h"
#import "GuideBook.h"
#import "GuideBookInfo.h"
#import "iCloud+spotiCloudAddition.h"
#import "SPDropBox.h"
#import <CoreLocation/CoreLocation.h>
#import "GuideBookInfoType.h"
#import "FileJournal.h"
#import "FileJournal.h"
#import "BarButtonItem.h"
#import "CreateSPOTViewController.h"
#import "Voice.h"
#import "FoursquareUser.h"
#import "UIAlertView+Blocks.h"
#import "ImageCacher.h"
#import "CenterModeImageFetcher.h"
#import "Banner.h"
#import "Flurry.h"
#import "AirdropService.h"
#include <sys/sysctl.h>

//@import UIKit;


#define MAX_RESULTS_COUNT (50)

typedef NS_ENUM(NSUInteger, SaveSpotDataType) {
    SaveSpotDataTypeAirDrop,
    SaveSpotDataTypeXml,
};


@interface AppDelegate() <LTHPasscodeViewControllerDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    
    dispatch_queue_t saveXMLQueue;
    
    BOOL isShowPasscode;
    BOOL receivedGPS;
}

@property (nonatomic) NSMutableDictionary *smallIcons;

@end


@implementation AppDelegate

AppDelegate *appDelegate;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSString *defaultsStoredAirDropURLsKey = @"URLsFromAirdrop";

//NSDateFormatter *formatter;
NSDateFormatter *dateTimeFormatter;

//- (void) showActionSheetSimulationViewForSpot:(SPOT *)spot
//{
//    [self.actionSheetSimulationView setSpot:spot];
//    [self.window addSubview:self.darkView];
//    [self.window addSubview:self.actionSheetSimulationView];
//}
//
//- (void) hideActionSheetSimulationView
//{
//    [self.actionSheetSimulationView removeFromSuperview];
//    [self.darkView removeFromSuperview];
//}

- (void) showActionSheetSimulationViewForSpot:(SPOT *)spot completetion:(void (^)())complete
{
    [self.actionSheetSimulationView setSpot:spot];
    [self.window addSubview:self.darkView];
    [self.window addSubview:self.actionSheetSimulationView];
    
    //    [self.window addSubview:self.actionSheetSimulationView];
    
    [UIView animateWithDuration:0.35 animations:^{
        
        [self.actionSheetSimulationView setFrame:CGRectMake(20.0f,
                                                            [[UIScreen mainScreen] applicationFrame].size.height - self.actionSheetSimulationView.bounds.size.height-20,
                                                            self.actionSheetSimulationView.bounds.size.width,
                                                            self.actionSheetSimulationView.bounds.size.height)];
        
    }completion:^(BOOL finished) {
        
        complete();
    }];
}

- (void) hideActionSheetSimulationView
{
    [UIView animateWithDuration:0.35 animations:^{
        
        
        [self.actionSheetSimulationView setFrame:CGRectMake(20.0f,
                                                            [[UIScreen mainScreen] applicationFrame].size.height + self.actionSheetSimulationView.bounds.size.height+20,
                                                            self.actionSheetSimulationView.bounds.size.width,
                                                            self.actionSheetSimulationView.bounds.size.height)];
        
    } completion:^(BOOL finished) {
        
        
        
        [self.actionSheetSimulationView removeFromSuperview];
        [self.darkView removeFromSuperview];
    }];
    
    
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
            if ([_delegate_dropbox_icloud respondsToSelector:@selector(handleEventLoginFromDropbox:)]) {
                
                [_delegate_dropbox_icloud handleEventLoginFromDropbox:YES];
                
            }
        }
        else
            
        {
            NSLog(@"Login dropbox Faield");
            
            if ([_delegate_dropbox_icloud respondsToSelector:@selector(handleEventLoginFromDropbox:)]) {
                
                [_delegate_dropbox_icloud handleEventLoginFromDropbox:NO];
                
            }
            
        }
    }
    
    if (sourceApplication == nil && [[url absoluteString] rangeOfString:@"Documents/Inbox"].location != NSNotFound) // Incoming AirDrop
    {
        
        //  NSLog(@"%@ sent from %@ with annotation %@", url, sourceApplication, [annotation description]);
        //  NSError *error = nil;
        //   NSLog(@"%@",[NSString stringWithContentsOfURL:url encoding:NSStringEncodingConversionAllowLossy error:&error]);
        
        if (application.protectedDataAvailable) {
            NSLog(@"%@",annotation);
            AirdropService *airdropService = [AirdropService new];
            [airdropService importObjectFromUrl:url];
        }
        else {
            [self saveAirDropURL:url];
        }
        return YES;
    }
    
    return [Foursquare2 handleURL:url];
}

- (void)parseXMLToObject:(NSURL *)xmlFileUrl {
    
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlFileUrl];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    if (doc != nil) {
        NSString *rootName = [doc.rootElement name];
        if ([rootName  isEqual: @"SPOT"])
        {
            [self parseXMLToSpotObject:xmlFileUrl];
        }
        else if ([rootName  isEqual: @"GuideBook"]) {
            [self parseXMLToGuideBookObject:xmlFileUrl];
        }
    }
}

- (void)saveAirDropURL:(NSURL *)url
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray * currentStoredURLs = [defaults arrayForKey:defaultsStoredAirDropURLsKey];
    if (currentStoredURLs == nil) {
        currentStoredURLs = @[];
    }
    NSArray * updatedStoredURLs = [currentStoredURLs arrayByAddingObject:url];
    [defaults setObject:updatedStoredURLs forKey:defaultsStoredAirDropURLsKey];
    [defaults synchronize];
}

- (void)protectedDataDidBecomeAvailable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray * currentStoredURLs = [defaults arrayForKey:defaultsStoredAirDropURLsKey];
    if (currentStoredURLs) {
        for(NSURL* url in currentStoredURLs)
        {
            [self parseXMLToObject:url];
        }
    }
}

- (NSString*)saveGuideBookToXML:(GuideBook *)guideBook {
    
    NSString *filePath = @"";
    
    @try {
        NSData *xmlData;
        __weak AppDelegate *selfPointer = self;
        
        @autoreleasepool {
            
            GDataXMLDocument *document ;
            
            @autoreleasepool {
                
                GDataXMLElement *rootElement = [GDataXMLNode elementWithName:@"GuideBook"];
                
                //    GDataXMLNode *uuidAtribute = [GDataXMLNode attributeWithName:@"uuid" stringValue:guideBook.uuid];
                //
                //    [rootElement addAttribute:uuidAtribute];
                
                GDataXMLElement *guideBookNameElement = [GDataXMLNode elementWithName:@"guide_book_name" stringValue: guideBook.guide_book_name];
                [rootElement addChild:guideBookNameElement];
                
                GDataXMLElement *pdfFileNameElement = [GDataXMLNode elementWithName:@"pdf_file_name" stringValue:guideBook.pdf_file_name];
                [rootElement addChild:pdfFileNameElement];
                
                GDataXMLElement *startDateElement = [GDataXMLNode elementWithName:@"start_date" stringValue:[dateTimeFormatter stringFromDate:guideBook.start_date]];
                [rootElement addChild:startDateElement];
                
                GDataXMLElement *startSpotSelectedFromFoursquareElement = [GDataXMLNode elementWithName:@"start_spot_selected_from_foursquare" stringValue:[NSString stringWithFormat:@"%@", guideBook.start_spot_selected_from_foursquare]];
                [rootElement addChild:startSpotSelectedFromFoursquareElement];
                
                if (guideBook.start_spot_selected_from_foursquare.intValue) {
                    GDataXMLElement *foursquareSpotLatElement = [GDataXMLNode elementWithName:@"foursquare_spot_lat" stringValue:[NSString stringWithFormat:@"%@", guideBook.foursquare_spot_lat]];
                    [rootElement addChild:foursquareSpotLatElement];
                    
                    GDataXMLElement *foursquareSpotLngElement = [GDataXMLNode elementWithName:@"foursquare_spot_lng" stringValue:[NSString stringWithFormat:@"%@", guideBook.foursquare_spot_lng]];
                    [rootElement addChild:foursquareSpotLngElement];
                    
                    GDataXMLElement *foursquareSpotNameElement = [GDataXMLNode elementWithName:@"foursquare_spot_name" stringValue:guideBook.foursquare_spot_name];
                    [rootElement addChild:foursquareSpotNameElement];
                }
                else if (guideBook.start_spot) {
                    
                    @autoreleasepool {
                        
                        GDataXMLElement *startSpotElement = [GDataXMLNode elementWithName:@"start_spot"];
                        [selfPointer loadXMLElementsFrom:guideBook.start_spot toSpotElement:startSpotElement];
                        [rootElement addChild:startSpotElement];
                        
                    }
                }
                
                @autoreleasepool {
                    
                    GDataXMLElement *guideBookInfoListElement = [GDataXMLNode elementWithName:@"guide_book_info_list"];
                    
                    for (GuideBookInfo *info in guideBook.guide_book_info) {
                        
                        @autoreleasepool {
                            
                            GDataXMLElement *guideBookInfoElement = [GDataXMLNode elementWithName:@"guide_book_info"];
                            
                            GDataXMLElement *orderElement = [GDataXMLNode elementWithName:@"order" stringValue: [NSString stringWithFormat:@"%@", info.order]];
                            [guideBookInfoElement addChild:orderElement];
                            
                            GDataXMLElement *infoTypeElement = [GDataXMLNode elementWithName:@"info_type" stringValue:[info.info_type stringValue]];
                            
                            [guideBookInfoElement addChild:infoTypeElement];
                            
                            if (info.info_type.intValue == GuideBookInfoTypeSpot) {
                                
                                @autoreleasepool {
                                    
                                    GDataXMLElement *spotElement = [GDataXMLNode elementWithName:@"spot"];
                                    
                                    [selfPointer loadXMLElementsFrom:info.spot toSpotElement:spotElement];
                                    
                                    [guideBookInfoElement addChild:spotElement];
                                }
                                
                            }
                            
                            else if (info.info_type.intValue == GuideBookInfoTypeDay) {
                                
                                GDataXMLElement *dayFromStartDay = [GDataXMLNode elementWithName:@"day_from_start_day" stringValue: [NSString stringWithFormat:@"%@", info.day_from_start_day]];
                                [guideBookInfoElement addChild:dayFromStartDay];
                            }
                            else {
                                GDataXMLElement *memoElement = [GDataXMLNode elementWithName:@"memo" stringValue:info.memo];
                                [guideBookInfoElement addChild:memoElement];
                            }
                            [guideBookInfoListElement addChild:guideBookInfoElement];
                        }
                    }
                    
                    [rootElement addChild:guideBookInfoListElement];
                    
                }
                
                document  = [[GDataXMLDocument alloc]
                             initWithRootElement:rootElement];
                
            }
            
            NSString *fileName =  [StringHelpers validFileNameFromString:guideBook.guide_book_name];
            
            filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[(fileName ? fileName : @"noname") stringByAppendingPathExtension:@"spot"]];
            xmlData = document.XMLData;
            
        }
        
        NSLog(@"Saving xml data to %@...", filePath);
        
        [xmlData writeToFile:filePath atomically:YES];
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"Save to guide book exception");
    }
    @finally {
        
    }
    
    //   NSError *error = nil;
    //  NSLog(@"%@",[NSString stringWithContentsOfFile:filePath encoding:NSStringEncodingConversionAllowLossy error:&error]);
    return filePath;
}

- (void)loadXMLElementsFrom:(SPOT *)spot toSpotElement:(GDataXMLElement *)spotElement {
    @autoreleasepool {
        GDataXMLElement * uuidElement = [GDataXMLNode elementWithName:@"uuid" stringValue:spot.uuid];
        [spotElement addChild:uuidElement];
        
        GDataXMLElement * spotNameElement = [GDataXMLNode elementWithName:@"spot_name" stringValue:spot.spot_name];
        [spotElement addChild:spotNameElement];
        
        GDataXMLElement * timeLineImageElement = [GDataXMLNode elementWithName:@"time_line_image" stringValue:spot.time_line_image];
        [spotElement addChild:timeLineImageElement];
        
        GDataXMLElement * phoneElement = [GDataXMLNode elementWithName:@"phone" stringValue:spot.phone];
        [spotElement addChild:phoneElement];
        
        GDataXMLElement * urlElement = [GDataXMLNode elementWithName:@"url" stringValue:spot.url];
        [spotElement addChild:urlElement];
        
        GDataXMLElement * memoElement = [GDataXMLNode elementWithName:@"memo" stringValue:spot.memo];
        [spotElement addChild:memoElement];
        
        GDataXMLElement * trafficElement = [GDataXMLNode elementWithName:@"traffic" stringValue:[spot.traffic stringValue]];
        [spotElement addChild:trafficElement];
        
        GDataXMLElement * dateElement = [GDataXMLNode elementWithName:@"date" stringValue:[dateTimeFormatter stringFromDate:spot.date]];
        [spotElement addChild:dateElement];
        
        //    GDataXMLElement * startSpotElement = [GDataXMLNode elementWithName:@"start_spot" stringValue:spot.start_spot.spot_name];
        //    [spotElement addChild:startSpotElement];
        
        GDataXMLElement *startSpotNameElement = [GDataXMLNode elementWithName:@"start_spot_name" stringValue:spot.start_spot_name];
        [spotElement addChild:startSpotNameElement];
        GDataXMLElement *startSpotLatElement = [GDataXMLNode elementWithName:@"start_spot_lat" stringValue:[spot.start_spot_lat stringValue]];
        [spotElement addChild:startSpotLatElement];
        GDataXMLElement *startSpotLngElement = [GDataXMLNode elementWithName:@"start_spot_lng" stringValue:[spot.start_spot_lng stringValue]];
        [spotElement addChild:startSpotLngElement];
        
        
        GDataXMLElement * latElement = [GDataXMLNode elementWithName:@"lat" stringValue:[spot.lat stringValue]];
        [spotElement addChild:latElement];
        
        GDataXMLElement * lngElement = [GDataXMLNode elementWithName:@"lng" stringValue:[spot.lng stringValue]];
        [spotElement addChild:lngElement];
        
        GDataXMLElement * addressElement = [GDataXMLNode elementWithName:@"address" stringValue:spot.address];
        [spotElement addChild:addressElement];
        
        __weak SPOT *spotSelf = spot;
        
        __weak AppDelegate *selfPointer = self;
        
        @autoreleasepool {
            
            GDataXMLElement * imageListElement = [GDataXMLNode elementWithName:@"image_list"];
            for (Image* image in spotSelf.image.allObjects)
            {
                @autoreleasepool {
                    
                    GDataXMLElement * imageElement = [GDataXMLNode elementWithName:@"image"];
                    NSString *imageFileName = [image image_file_name];
                    
                    GDataXMLElement * imageFileNameElement = [GDataXMLNode elementWithName:@"image_file_name" stringValue:imageFileName];
                    [imageElement addChild:imageFileNameElement];
                    
                    NSData *imageData = (!imageFileName)?nil:[NSData dataWithContentsOfFile:[[selfPointer applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:imageFileName]];
                    NSString *base64ImageData = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                    imageData = nil;
                    
                    GDataXMLElement * imageDataElement = [GDataXMLNode elementWithName:@"image_data" stringValue:base64ImageData];
                    [imageElement addChild:imageDataElement];
                    [imageListElement addChild:imageElement];
                }
            }
            
            [spotElement addChild:imageListElement];
            
        }
        
        @autoreleasepool {
            
            GDataXMLElement * memoVoiceListElements = [GDataXMLNode elementWithName:@"memovoice_list"];
            
            for (Voice* voice in spotSelf.voice.allObjects){
                
                @autoreleasepool {
                    
                    GDataXMLElement * memoVoiceElements = [GDataXMLNode elementWithName:@"memoVoice"];
                    
                    GDataXMLElement * memoVoiceUUIDElement = [GDataXMLNode elementWithName:@"memoVoiceUUID" stringValue:voice.uuid];
                    [memoVoiceElements addChild:memoVoiceUUIDElement];
                    
                    GDataXMLElement * memoVoiceDateElement = [GDataXMLNode elementWithName:@"memoVoiceDate" stringValue:[dateTimeFormatter stringFromDate:voice.date]];
                    [memoVoiceElements addChild:memoVoiceDateElement];
                    
                    GDataXMLElement * memoVoiceTimeElement = [GDataXMLNode elementWithName:@"memoVoiceTime" stringValue:[voice.time stringValue]];
                    [memoVoiceElements addChild:memoVoiceTimeElement];
                    
                    GDataXMLElement * memoVoiceDataElement;
                    
                    @autoreleasepool {
                        
                        NSData *voiceData = [NSData dataWithContentsOfFile:[selfPointer.applicationDocumentsDirectoryForMemoVoice stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",voice.uuid,EXTENSION_RECORD]]];
                        
                        NSString *base64VoiceData = [voiceData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                        
                        NSLog(@"%lu",(unsigned long)[base64VoiceData dataUsingEncoding:NSASCIIStringEncoding].length);
                        
                        memoVoiceDataElement = [GDataXMLNode elementWithName:@"memoVoiceData" stringValue:base64VoiceData];
                        
                    }
                    
                    [memoVoiceElements addChild:memoVoiceDataElement];
                    
                    [memoVoiceListElements addChild:memoVoiceElements];
                }
            }
            
            [spotElement addChild:memoVoiceListElements];
        }
        
        GDataXMLElement * tagListElement = [GDataXMLNode elementWithName:@"tag_list"];
        for (Tag *tag in spot.tag.allObjects)
        {
            GDataXMLElement * tagElement = [GDataXMLNode elementWithName:@"tag" stringValue:tag.tag];
            [tagListElement addChild:tagElement];
        }
        [spotElement addChild:tagListElement];
        
        GDataXMLElement * countryElement = [GDataXMLNode elementWithName:@"country" stringValue:spot.country.country];
        [spotElement addChild:countryElement];
        
        GDataXMLElement * regionElement = [GDataXMLNode elementWithName:@"region" stringValue:spot.region.region];
        [spotElement addChild:regionElement];
    }
    
}



- (NSString*)saveSpotToXML:(SPOT *)spot {
    
    NSString *filePath=@"";
    
    @try {
        
        GDataXMLDocument *document;
        NSData *xmlData;
        __weak AppDelegate *selfPointer = self;
        __weak SPOT *spotPointer = spot;
        
        @autoreleasepool {
            
            @autoreleasepool {
                
                GDataXMLElement * spotElement = [GDataXMLNode elementWithName:@"SPOT"];
                
                //    GDataXMLNode *uuidAtribute = [GDataXMLNode attributeWithName:@"uuid" stringValue:spot.uuid];
                //
                //    [spotElement addAttribute:uuidAtribute];
                
                [selfPointer loadXMLElementsFrom:spotPointer toSpotElement:spotElement];
                
                
                document = [[GDataXMLDocument alloc]
                            initWithRootElement:spotElement];
            }
            
            NSString *fileName =  [StringHelpers validFileNameFromString:spot.spot_name];
            
            
            filePath = [[selfPointer applicationDocumentsDirectory] stringByAppendingPathComponent:[(fileName ? fileName : @"noname")stringByAppendingPathExtension:@"spot"]];
            xmlData = document.XMLData;
        }
        
        NSLog(@"Saving xml data to %@...", filePath);
        
        [xmlData writeToFile:filePath atomically:YES];
        
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"Save Spot to XML Exception");
    }
    @finally {
        
        NSLog(@"Save Spot to XML Complete");
    }
    
    
    // NSError *error = nil;
    // NSLog(@"%@",[NSString stringWithContentsOfFile:filePath encoding:NSStringEncodingConversionAllowLossy error:&error]);
    return filePath;
}

- (void)loadSpotFrom:(GDataXMLElement *)spotElement toSpot:(SPOT *)spot
{
    //    NSArray* uuidElements=[spotElement elementsForName:@"uuid" ];
    //    if (uuidElements.count > 0) {
    //        GDataXMLElement *uuidNode = (GDataXMLElement *) [uuidElements firstObject];
    //        spot.uuid = uuidNode.stringValue;
    //    }
    
    // create new uuid
    //    spot.uuid = [[NSUUID UUID] UUIDString];
    
    //    NSArray* uuidNameElements=[spotElement elementsForName:@"uuid" ];
    //    if (uuidNameElements.count > 0) {
    //        GDataXMLElement *uuidNode = (GDataXMLElement *) [uuidNameElements firstObject];
    //        spot.uuid = uuidNode.stringValue;
    //    }
    
    @autoreleasepool {
        spot.uuid = [[NSUUID UUID]UUIDString];
        
        NSArray* spotNameElements=[spotElement elementsForName:@"spot_name" ];
        
        if (spotNameElements.count > 0) {
            GDataXMLElement *spotNameNode = (GDataXMLElement *) [spotNameElements firstObject];
            spot.spot_name = spotNameNode.stringValue;
        }
        
        NSString *time_line_image_name ;
        NSArray* spotTimeLineElements=[spotElement elementsForName:@"time_line_image" ];
        if (spotTimeLineElements.count > 0) {
            GDataXMLElement *spotTimeLineNode = (GDataXMLElement *) [spotTimeLineElements firstObject];
            time_line_image_name= spotTimeLineNode.stringValue;
        }
        
        
        // phone
        NSArray* phoneElements=[spotElement elementsForName:@"phone"];
        if (phoneElements.count > 0) {
            GDataXMLElement *phoneNode = (GDataXMLElement *) [phoneElements firstObject];
            spot.phone = phoneNode.stringValue;
        }
        
        // url
        NSArray* urlElements=[spotElement elementsForName:@"url"];
        if (urlElements.count > 0) {
            GDataXMLElement *urlNode = (GDataXMLElement *) [urlElements firstObject];
            spot.url = urlNode.stringValue;
        }
        
        // memo
        NSArray* memoElements=[spotElement elementsForName:@"memo"];
        if (memoElements.count > 0) {
            GDataXMLElement *memoNode = (GDataXMLElement *) [memoElements firstObject];
            spot.memo = memoNode.stringValue;
        }
        
        // traffic
        NSArray* trafficElements=[spotElement elementsForName:@"traffic"];
        if (trafficElements.count > 0) {
            GDataXMLElement *trafficNode = (GDataXMLElement *) [trafficElements firstObject];
            spot.traffic = numberFromString(trafficNode.stringValue);
        }
        
        // date
        NSArray* dateElements=[spotElement elementsForName:@"date"];
        if (dateElements.count > 0) {
            GDataXMLElement *dateNode = (GDataXMLElement *) [dateElements firstObject];
            spot.date = [dateTimeFormatter dateFromString:dateNode.stringValue];
        }
        else {
            spot.date = [NSDate date];
            NSLog(@"Missing date element.");
        }
        
        // start spot
        //    NSArray* startSpotElements=[spotElement elementsForName:@"start_spot"];
        //    if (startSpotElements.count > 0) {
        //        GDataXMLElement *startSpotNode = (GDataXMLElement *) [startSpotElements firstObject];
        //        SPOT *startSpot = [SPOT MR_findFirstByAttribute:@"spot_name" withValue:startSpotNode.stringValue];
        //        if (!startSpot)
        //        {
        //            startSpot = [SPOT MR_createEntity];
        //            startSpot.spot_name = startSpotNode.stringValue;
        //        }
        //
        //        spot.start_spot = startSpot;
        //    }
        
        NSArray *startSpotNameElement = [spotElement elementsForName:@"start_spot_name"];
        if (startSpotNameElement.count > 0) {
            GDataXMLElement *startSpotNameNode = (GDataXMLElement *) [startSpotNameElement firstObject];
            spot.start_spot_name = startSpotNameNode.stringValue;
        }
        NSArray *startSpotLatElement = [spotElement elementsForName:@"start_spot_lat"];
        if (startSpotLatElement.count > 0) {
            GDataXMLElement *startSpotLatNode = (GDataXMLElement *) [startSpotLatElement firstObject];
            spot.start_spot_lat = numberFromString(startSpotLatNode.stringValue);
        }
        NSArray *startSpotLngElement = [spotElement elementsForName:@"start_spot_lng"];
        if (startSpotLngElement.count > 0) {
            GDataXMLElement *startSpotLngNode = (GDataXMLElement *)[startSpotLngElement firstObject];
            spot.start_spot_lng = numberFromString(startSpotLngNode.stringValue);
        }
        
        // lat
        NSArray* latElements=[spotElement elementsForName:@"lat"];
        if (latElements.count > 0) {
            GDataXMLElement *latNode = (GDataXMLElement *) [latElements firstObject];
            spot.lat = numberFromString(latNode.stringValue);
        }
        
        // lng
        NSArray* lngElements=[spotElement elementsForName:@"lng"];
        if (lngElements.count > 0) {
            GDataXMLElement *lngNode = (GDataXMLElement *) [lngElements firstObject];
            spot.lng = numberFromString(lngNode.stringValue);
        }
        
        // address
        NSArray* addressElements=[spotElement elementsForName:@"address"];
        if (addressElements.count > 0) {
            GDataXMLElement *addressNode = (GDataXMLElement *) [addressElements firstObject];
            spot.address = addressNode.stringValue;
        }
        
        // image list
        NSArray* imageListElements=[spotElement elementsForName:@"image_list"];
        if (imageListElements.count > 0) {
            GDataXMLElement *imageListNode = (GDataXMLElement *) [imageListElements firstObject];
            NSArray* imageElementsArray = [imageListNode elementsForName:@"image"];
            for(GDataXMLElement *imageElement in imageElementsArray)
            {
                Image* image= [Image MR_createEntity];
                
                NSString *newUUID = [[NSUUID UUID]UUIDString];
                
                NSArray *imageFileNameElements = [imageElement elementsForName:@"image_file_name"];
                if (imageFileNameElements.count > 0) {
                    GDataXMLElement *imageFileNameNode = (GDataXMLElement *) [imageFileNameElements firstObject];
                    image.image_file_name = [NSString stringWithFormat:@"%@.%@",newUUID,imageFileNameNode.stringValue.pathExtension];
                    
                    if ([time_line_image_name isEqualToString:imageFileNameNode.stringValue]) {
                        
                        spot.time_line_image = image.image_file_name;
                    }
                }
                
                @autoreleasepool {
                    
                    NSArray *imageDataElements = [imageElement elementsForName:@"image_data"];
                    if (imageDataElements.count > 0) {
                        GDataXMLElement *imageDataNode = (GDataXMLElement *) [imageDataElements firstObject];
                        NSData *imageData = [[NSData alloc]initWithBase64EncodedString:imageDataNode.stringValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        
                        NSString *savedImagePath = [[self applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:image.image_file_name];
                        [imageData writeToFile:savedImagePath atomically:NO];
                    }
                    image.spot = spot;
                    [spot addImageObject:image];
                }
            }
        }
        
        //MemoVoice
        
        @autoreleasepool {
            
            NSArray* memoVoiceListElements=[spotElement elementsForName:@"memovoice_list"];
            if (memoVoiceListElements.count > 0) {
                GDataXMLElement *memoVoiceListNode = (GDataXMLElement *) [memoVoiceListElements firstObject];
                NSArray *memoVoiceElements = [memoVoiceListNode elementsForName:@"memoVoice"];
                
                for (GDataXMLElement *memoVoiceElement in memoVoiceElements)
                {
                    Voice *voice  = [Voice MR_createEntity];
                    NSString *newUUID = [[NSUUID UUID]UUIDString];
                    voice.uuid = newUUID;
                    
                    //            NSArray *memoVoiceUUIDElements = [memoVoiceElement elementsForName:@"memoVoiceUUID"]
                    //            if (memoVoiceUUIDElements.count > 0) {
                    //                GDataXMLElement *memoVoiceUUIDNode = (GDataXMLElement *) [memoVoiceUUIDElements firstObject];
                    //                voice.uuid =  memoVoiceUUIDNode.stringValue;
                    //            }
                    
                    NSArray *memoVoiceDateElements = [memoVoiceElement elementsForName:@"memoVoiceDate"];
                    if (memoVoiceDateElements.count > 0) {
                        GDataXMLElement *memoVoiceDateNode = (GDataXMLElement *) [memoVoiceDateElements firstObject];
                        voice.date = [dateTimeFormatter dateFromString: memoVoiceDateNode.stringValue];
                    }
                    
                    
                    NSArray *memoVoiceTimeElements = [memoVoiceElement elementsForName:@"memoVoiceTime"];
                    if (memoVoiceTimeElements.count > 0) {
                        GDataXMLElement *memoVoiceTimeNode = (GDataXMLElement *) [memoVoiceTimeElements firstObject];
                        voice.time = [NSNumber numberWithInt:memoVoiceTimeNode.stringValue.intValue];
                        NSLog(@"%@",memoVoiceTimeNode.stringValue);
                        
                    }
                    
                    NSArray *memoVoiceDataElements = [memoVoiceElement elementsForName:@"memoVoiceData"];
                    if (memoVoiceDataElements.count > 0) {
                        GDataXMLElement *memoVoiceDataNode = (GDataXMLElement *) [memoVoiceDataElements firstObject];
                        NSData *memoVoiceData = [[NSData alloc]initWithBase64EncodedString:memoVoiceDataNode.stringValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        
                        NSString *savedMemoDataPath = [self.applicationDocumentsDirectoryForMemoVoice stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",voice.uuid,EXTENSION_RECORD]];
                        [memoVoiceData writeToFile:savedMemoDataPath atomically:NO];
                    }
                    
                    voice.spot = spot;
                    [spot addVoiceObject:voice];
                }
            }
        }
        
        // tag list
        NSArray* tagListElements=[spotElement elementsForName:@"tag_list"];
        if (tagListElements.count > 0) {
            GDataXMLElement *tagListNode = (GDataXMLElement *) [tagListElements firstObject];
            NSArray *tagElements = [tagListNode elementsForName:@"tag"];
            for (GDataXMLElement *tagElement in tagElements)
            {
                Tag *tag = [Tag MR_findFirstByAttribute:@"tag" withValue:tagElement.stringValue];
                if (!tag)
                {
                    tag = [Tag MR_createEntity];
                    tag.tag = tagElement.stringValue;
                }
                //[tag addSpotObject:spot];
                [spot addTagObject:tag];
            }
        }
        
        // country
        NSArray* countryElements=[spotElement elementsForName:@"country"];
        if (countryElements.count > 0) {
            GDataXMLElement *countryNode = (GDataXMLElement *) [countryElements firstObject];
            Country *country = [Country MR_findFirstByAttribute:@"country" withValue:countryNode.stringValue];
            if (!country)
            {
                country = [Country MR_createEntity];
                country.country = countryNode.stringValue;
            }
            [country addSpotObject:spot];
            spot.country = country;
        }
        
        // region
        NSArray* regionElements=[spotElement elementsForName:@"region"];
        if (regionElements.count > 0) {
            GDataXMLElement *regionNode = (GDataXMLElement *) [regionElements firstObject];
            Region *region = [Region MR_findFirstByAttribute:@"region" withValue:regionNode.stringValue];
            if (!region)
            {
                region = [Region MR_createEntity];
                region.region = regionNode.stringValue;
            }
            [region addSpotObject:spot];
            spot.region = region;
        }
    }
    
    
}


- (void) parseXMLToSpotObject:(NSURL*)xmlFileUrl
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlFileUrl];
            // NSLog(@"%@", xmlData);
            NSError *error;
            GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                                   options:0 error:&error];
            
            if (doc == nil) { return ; }
            
            GDataXMLElement *spotElement = doc.rootElement;
            
            
            SPOT *spot = [SPOT MR_createEntity];
            
            [self loadSpotFrom:spotElement toSpot:spot];
            
            NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_contextForCurrentThread];
            
            [magicalContext MR_saveToPersistentStoreAndWait];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SaveAirDropFileFinish" object:nil];
            });
            
            [self saveSpotToXMLForSync:spot];
        }
    });
}

- (NSString *) getStringValueFromGDataXMLElementName: (NSString *)elementName rootElement: (GDataXMLElement *)rootElement {
    NSArray* elements = [rootElement elementsForName:elementName ];
    if (elements.count > 0) {
        GDataXMLElement *node = (GDataXMLElement *) [elements firstObject];
        return node.stringValue;
    }
    return nil;
}

- (void) parseXMLToGuideBookObject:(NSURL*)xmlFileUrl {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlFileUrl];
            NSError *error;
            GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                                   options:0 error:&error];
            
            if (doc == nil) { return ; }
            
            GuideBook *guideBook = [GuideBook MR_createEntity];
            
            // create new uuid
            //    guideBook.uuid = [self getStringValueFromGDataXMLElementName:@"uuid" rootElement:doc.rootElement];
            guideBook.uuid = [[NSUUID UUID]UUIDString];
            
            NSString *guideBookName = [self getStringValueFromGDataXMLElementName:@"guide_book_name" rootElement:doc.rootElement];
            guideBook.guide_book_name = guideBookName != nil ? guideBookName : @"";
            
            
            NSString* pdfFileName = [self getStringValueFromGDataXMLElementName:@"pdf_file_name" rootElement:doc.rootElement];
            guideBook.pdf_file_name = pdfFileName != nil ? pdfFileName : @"";
            
            NSString* startDate = [self getStringValueFromGDataXMLElementName:@"start_date" rootElement:doc.rootElement];
            guideBook.start_date = startDate != nil ? [dateTimeFormatter dateFromString:startDate] : [NSDate date];
            
            NSString *startSpotSelectedFromFoursquareString = [self getStringValueFromGDataXMLElementName:@"start_spot_selected_from_foursquare" rootElement:doc.rootElement];
            
            int startSpotSelectedFromFoursquare = startSpotSelectedFromFoursquareString != nil ? [startSpotSelectedFromFoursquareString intValue] : 0;
            
            if (startSpotSelectedFromFoursquare) {
                NSString *foursquareSpotLat = [self getStringValueFromGDataXMLElementName:@"foursquare_spot_lat" rootElement:doc.rootElement];
                guideBook.foursquare_spot_lat = foursquareSpotLat != nil ? @([foursquareSpotLat doubleValue]) : @(0);
                
                NSString *foursquareSpotLng = [self getStringValueFromGDataXMLElementName:@"foursquare_spot_lng" rootElement:doc.rootElement];
                guideBook.foursquare_spot_lng = foursquareSpotLng != nil ? @([foursquareSpotLng doubleValue]) : @(0);
                
                NSString *foursquareSpotName = [self getStringValueFromGDataXMLElementName:@"foursquare_spot_name" rootElement:doc.rootElement];
                guideBook.foursquare_spot_name = foursquareSpotName != nil ? foursquareSpotName : @"";
            }
            else {
                NSArray* startSpotElements = [doc.rootElement elementsForName:@"start_spot" ];
                if (startSpotElements.count > 0) {
                    GDataXMLElement *startSportNode = (GDataXMLElement *)[startSpotElements firstObject];
                    SPOT *spot = [SPOT MR_createEntity];
                    [self loadSpotFrom:startSportNode toSpot:spot];
                    guideBook.start_spot = spot;
                }
            }
            
            NSArray* guideBookInfoListElements = [doc.rootElement elementsForName:@"guide_book_info_list" ];
            if (guideBookInfoListElements.count > 0) {
                GDataXMLElement *guideBookInfoListNode = (GDataXMLElement *) [guideBookInfoListElements firstObject];
                NSArray* guideBookInfoElements = [guideBookInfoListNode elementsForName:@"guide_book_info" ];
                NSMutableSet *guideBookInfoList = [NSMutableSet new];
                
                for (GDataXMLElement *guideBookInfoNode in guideBookInfoElements) {
                    NSArray* spotElements = [guideBookInfoNode elementsForName:@"spot" ];
                    NSArray* memoElements = [guideBookInfoNode elementsForName:@"memo" ];
                    NSArray* dayFromStartDayElements = [guideBookInfoNode elementsForName:@"day_from_start_day" ];
                    NSArray* infoElements = [guideBookInfoNode elementsForName:@"info_type"];
                    GDataXMLElement *infoElement = [infoElements firstObject];
                    
                    
                    NSArray* orderElements = [guideBookInfoNode elementsForName:@"order" ];
                    
                    
                    GuideBookInfo *guideBookInfo = [GuideBookInfo MR_createEntity];
                    guideBookInfo.info_type = [NSNumber numberWithInt: [infoElement.stringValue intValue]];
                    
                    if (orderElements.count > 0) {
                        GDataXMLElement *orderNode = [orderElements firstObject];
                        
                        guideBookInfo.order = [NSNumber numberWithInt:[orderNode.stringValue intValue]];
                    }
                    
                    if (spotElements.count > 0) {
                        GDataXMLElement *spotNode = [spotElements firstObject];
                        SPOT *spot = [SPOT MR_createEntity];
                        [self loadSpotFrom:spotNode toSpot:spot];
                        
                        guideBookInfo.spot = spot;
                        guideBookInfo.info_type = @(GuideBookInfoTypeSpot);
                        
                    }
                    else if (memoElements.count > 0){
                        GDataXMLElement *memoNode = [memoElements firstObject];
                        guideBookInfo.memo = memoNode.stringValue;
                        guideBookInfo.info_type = @(GuideBookInfoTypeMemo);
                    }
                    else if (dayFromStartDayElements.count > 0) {
                        GDataXMLElement *dayFromStartDayNode = [dayFromStartDayElements firstObject];
                        guideBookInfo.day_from_start_day = [NSNumber numberWithInt: [dayFromStartDayNode.stringValue intValue]];
                        guideBookInfo.info_type = @(GuideBookInfoTypeDay);
                    }
                    
                    [guideBookInfoList addObject:guideBookInfo];
                }
                
                guideBook.guide_book_info = guideBookInfoList;
            }
            
            
            NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_contextForCurrentThread];
            // save
            [magicalContext MR_saveToPersistentStoreAndWait];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SaveAirDropFileFinish" object:nil];
            });
            
            [self saveGuideBookToXMLForSync:guideBook];
        }
    });
}

#pragma mark - XML_CoreData_Import_Export



- (void)saveGuideBookToXMLForSync:(GuideBook *)guideBook {
    //    self.guideBookTableLastUpdateDate = [NSDate date];
    
    @autoreleasepool {
        GDataXMLElement *rootElement = [GDataXMLNode elementWithName:@"GuideBook"];
        
        GDataXMLElement *uuidElement = [GDataXMLNode elementWithName:@"uuid" stringValue: guideBook.uuid];
        [rootElement addChild:uuidElement];
        
        GDataXMLElement *guideBookNameElement = [GDataXMLNode elementWithName:@"guide_book_name" stringValue: guideBook.guide_book_name];
        [rootElement addChild:guideBookNameElement];
        
        GDataXMLElement *startDateElement = [GDataXMLNode elementWithName:@"start_date" stringValue:[dateTimeFormatter stringFromDate:guideBook.start_date]];
        [rootElement addChild:startDateElement];
        
        GDataXMLElement *startSpotSelectedFromFoursquareElement = [GDataXMLNode elementWithName:@"start_spot_selected_from_foursquare" stringValue:[NSString stringWithFormat:@"%@", guideBook.start_spot_selected_from_foursquare]];
        [rootElement addChild:startSpotSelectedFromFoursquareElement];
        
        
        if (guideBook.start_spot_selected_from_foursquare.intValue) {
            GDataXMLElement *foursquareSpotLatElement = [GDataXMLNode elementWithName:@"foursquare_spot_lat" stringValue:[NSString stringWithFormat:@"%@", guideBook.foursquare_spot_lat]];
            [rootElement addChild:foursquareSpotLatElement];
            
            GDataXMLElement *foursquareSpotLngElement = [GDataXMLNode elementWithName:@"foursquare_spot_lng" stringValue:[NSString stringWithFormat:@"%@", guideBook.foursquare_spot_lng]];
            [rootElement addChild:foursquareSpotLngElement];
            
            GDataXMLElement *foursquareSpotNameElement = [GDataXMLNode elementWithName:@"foursquare_spot_name" stringValue:guideBook.foursquare_spot_name];
            [rootElement addChild:foursquareSpotNameElement];
        }
        else {
            
            if (guideBook.start_spot) {
                
                GDataXMLElement *startSpotElement = [GDataXMLNode elementWithName:@"start_spot"];
                [self loadXMLElementsFrom:guideBook.start_spot toSpotElement:startSpotElement];
                [rootElement addChild:startSpotElement];
            }
        }
        
        
        GDataXMLElement *guideBookInfoListElement = [GDataXMLNode elementWithName:@"guide_book_info_list"];
        
        for (GuideBookInfo *info in guideBook.guide_book_info) {
            
            GDataXMLElement *guideBookInfoElement = [GDataXMLNode elementWithName:@"guide_book_info"];
            
            GDataXMLElement *orderElement = [GDataXMLNode elementWithName:@"order" stringValue: [NSString stringWithFormat:@"%@", info.order]];
            [guideBookInfoElement addChild:orderElement];
            
            GDataXMLElement *infoTypeElement = [GDataXMLNode elementWithName:@"info_type" stringValue:[info.info_type stringValue]];
            
            [guideBookInfoElement addChild:infoTypeElement];
            
            if (info.info_type.intValue == GuideBookInfoTypeSpot ) {
                
                GDataXMLElement *spotElement = [GDataXMLNode elementWithName:@"spot"];
                GDataXMLElement *uuidElement = [GDataXMLNode elementWithName:@"uuid" stringValue: info.spot.uuid];
                [spotElement addChild:uuidElement];
                [guideBookInfoElement addChild:spotElement];
            }
            else if (info.info_type.intValue == GuideBookInfoTypeDay) {
                GDataXMLElement *dayFromStartDay = [GDataXMLNode elementWithName:@"day_from_start_day" stringValue: [NSString stringWithFormat:@"%@", info.day_from_start_day]];
                [guideBookInfoElement addChild:dayFromStartDay];
            }
            else {
                GDataXMLElement *memoElement = [GDataXMLNode elementWithName:@"memo" stringValue:info.memo];
                [guideBookInfoElement addChild:memoElement];
            }
            [guideBookInfoListElement addChild:guideBookInfoElement];
        }
        
        [rootElement addChild:guideBookInfoListElement];
        
        GDataXMLDocument *document = [[GDataXMLDocument alloc]
                                      initWithRootElement:rootElement];
        
        NSString *filePath = [[self applicationDocumentsDirectoryForGuideBookData] stringByAppendingPathComponent:[guideBook.uuid stringByAppendingPathExtension:@"spotGuidebookData"]];
        
        NSData *xmlData = document.XMLData;
        
        NSLog(@"Saving xml data to %@...", filePath);
        [xmlData writeToFile:filePath atomically:YES];
        
        //   NSError *error = nil;
        //  NSLog(@"%@",[NSString stringWithContentsOfFile:filePath encoding:NSStringEncodingConversionAllowLossy error:&error]);
        
        [self startSync];
    }
}


- (void)saveSpotToXMLForSync:(SPOT *)spot {

    @autoreleasepool {
        NSLog(@"SaveSpotToXML::MainThread:%@ CurrentThread:%@",[NSThread mainThread],[NSThread currentThread]);
        
        GDataXMLElement * spotElement = [GDataXMLNode elementWithName:@"SPOT"];
        
        [self loadXMLElementsForSyncFrom:spot toSpotElement:spotElement];
        
        
        GDataXMLDocument *document = [[GDataXMLDocument alloc]
                                      initWithRootElement:spotElement];
        
        NSLog(@"%@",spot.uuid);
        
        NSString *filePath = [[self applicationDocumentsDirectoryForSpotData] stringByAppendingPathComponent:[spot.uuid stringByAppendingPathExtension:@"spotData"]];
        NSData *xmlData = document.XMLData;
        
        NSLog(@"Saving xml data to %@...", filePath);
        [xmlData writeToFile:filePath atomically:YES];
        
        //  NSError *error = nil;
        //   NSLog(@"%@",[NSString stringWithContentsOfFile:filePath encoding:NSStringEncodingConversionAllowLossy error:&error]);
        
        [self startSync];
    }
}



- (void)loadXMLElementsForSyncFrom:(SPOT *)spot toSpotElement:(GDataXMLElement *)spotElement {
    
    // iOS8 Crash without try/catch, iOS7 ? Maybe spot has not finished init yet
    @try {
        @autoreleasepool {
            GDataXMLElement * uuidElement = [GDataXMLNode elementWithName:@"uuid" stringValue:spot.uuid];
            NSLog(@"%@",spot.uuid);
            
            [spotElement addChild:uuidElement];
            
            GDataXMLElement * timeLineImageElement = [GDataXMLNode elementWithName:@"time_line_image" stringValue:spot.time_line_image];
            [spotElement addChild:timeLineImageElement];
            
            GDataXMLElement * spotNameElement = [GDataXMLNode elementWithName:@"spot_name" stringValue:spot.spot_name];
            [spotElement addChild:spotNameElement];
            
            GDataXMLElement * phoneElement = [GDataXMLNode elementWithName:@"phone" stringValue:spot.phone];
            [spotElement addChild:phoneElement];
            
            GDataXMLElement * urlElement = [GDataXMLNode elementWithName:@"url" stringValue:spot.url];
            [spotElement addChild:urlElement];
            
            GDataXMLElement * memoElement = [GDataXMLNode elementWithName:@"memo" stringValue:spot.memo];
            [spotElement addChild:memoElement];
            
            GDataXMLElement * trafficElement = [GDataXMLNode elementWithName:@"traffic" stringValue:[spot.traffic stringValue]];
            [spotElement addChild:trafficElement];
            
            GDataXMLElement * dateElement = [GDataXMLNode elementWithName:@"date" stringValue:[dateTimeFormatter stringFromDate:spot.date]];
            [spotElement addChild:dateElement];
            
            //    GDataXMLElement * startSpotElement = [GDataXMLNode elementWithName:@"start_spot" stringValue:spot.start_spot.spot_name];
            //    [spotElement addChild:startSpotElement];
            GDataXMLElement *startSpotNameElement = [GDataXMLNode elementWithName:@"start_spot_name" stringValue:spot.start_spot_name];
            [spotElement addChild:startSpotNameElement];
            GDataXMLElement *startSpotLatElement = [GDataXMLNode elementWithName:@"start_spot_lat" stringValue:[spot.start_spot_lat stringValue]];
            [spotElement addChild:startSpotLatElement];
            GDataXMLElement *startSpotLngElement = [GDataXMLNode elementWithName:@"start_spot_lng" stringValue:[spot.start_spot_lng stringValue]];
            [spotElement addChild:startSpotLngElement];
            
            GDataXMLElement * latElement = [GDataXMLNode elementWithName:@"lat" stringValue:[spot.lat stringValue]];
            [spotElement addChild:latElement];
            
            GDataXMLElement * lngElement = [GDataXMLNode elementWithName:@"lng" stringValue:[spot.lng stringValue]];
            [spotElement addChild:lngElement];
            
            GDataXMLElement * addressElement = [GDataXMLNode elementWithName:@"address" stringValue:spot.address];
            [spotElement addChild:addressElement];
            
            GDataXMLElement * imageListElement = [GDataXMLNode elementWithName:@"image_list"];
            for (Image* image in spot.image.allObjects)
            {
                @autoreleasepool {
                    GDataXMLElement * imageElement = [GDataXMLNode elementWithName:@"image"];
                    
                    NSString *imageFileName = [image image_file_name];
                    GDataXMLElement * imageFileNameElement = [GDataXMLNode elementWithName:@"image_file_name" stringValue:imageFileName];
                    [imageElement addChild:imageFileNameElement];
                    
                    NSString *imageOriginalFileName = [image origin_image_file_name];
                    NSLog(@"%@",imageOriginalFileName);
                    GDataXMLElement * imageOriginalFileNameElement = [GDataXMLNode elementWithName:@"image_original_file_name" stringValue:imageOriginalFileName];
                    [imageElement addChild:imageOriginalFileNameElement];
                    
                    NSNumber *imageNameCard = [image is_name_card];
                    GDataXMLElement * imageNameCardElement = [GDataXMLNode elementWithName:@"image_name_card" stringValue:imageNameCard.stringValue];
                    [imageElement addChild:imageNameCardElement];
                    
                    [imageListElement addChild:imageElement ];
                }
                
            }
            [spotElement addChild:imageListElement];
            
            GDataXMLElement * memoVoiceListElements = [GDataXMLNode elementWithName:@"memovoice_list"];
            for (Voice* voice in spot.voice.allObjects){
                @autoreleasepool {
                    GDataXMLElement * memoVoiceElement = [GDataXMLNode elementWithName:@"memoVoice"];
                    
                    GDataXMLElement * memoVoiceUUIDElement = [GDataXMLNode elementWithName:@"memoVoiceUUID" stringValue:voice.uuid];
                    [memoVoiceElement addChild:memoVoiceUUIDElement];
                    
                    GDataXMLElement * memoVoiceTimeElement = [GDataXMLNode elementWithName:@"memoVoiceTime" stringValue:[voice.time stringValue]];
                    [memoVoiceElement addChild:memoVoiceTimeElement];
                    
                    GDataXMLElement * memoVoiceDateElement = [GDataXMLNode elementWithName:@"memoVoiceDate" stringValue:[dateTimeFormatter stringFromDate:voice.date]];
                    [memoVoiceElement addChild:memoVoiceDateElement];
                    
                    [memoVoiceListElements addChild:memoVoiceElement];
                }
            }
            
            [spotElement addChild:memoVoiceListElements];
            
            
            GDataXMLElement * tagListElement = [GDataXMLNode elementWithName:@"tag_list"];
            for (Tag *tag in spot.tag.allObjects)
            {
                @autoreleasepool {
                    GDataXMLElement * tagElement = [GDataXMLNode elementWithName:@"tag" stringValue:tag.tag];
                    [tagListElement addChild:tagElement];
                }
            }
            [spotElement addChild:tagListElement];
            
            GDataXMLElement * countryElement = [GDataXMLNode elementWithName:@"country" stringValue:spot.country.country];
            [spotElement addChild:countryElement];
            
            GDataXMLElement * regionElement = [GDataXMLNode elementWithName:@"region" stringValue:spot.region.region];
            [spotElement addChild:regionElement];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION: ---- %@", exception);
    }
    @finally {
        
    }
    
}



- (SPOT*) parseXMLSyncDataToSpotObject:(NSURL*)xmlFileUrl newEntity:(BOOL)newEntity
{
    @autoreleasepool {
        NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlFileUrl];
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                               options:0 error:&error];
        
        if (doc == nil) { return nil; }
        
        SPOT* spot;
        if (newEntity) {
            spot = [SPOT MR_createEntity];
        }
        else{
            
            NSArray* uuidElements=[doc.rootElement elementsForName:@"uuid"];
            GDataXMLElement *uuidElement = (GDataXMLElement *) [uuidElements firstObject];
            NSString *uuid = uuidElement.stringValue;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid like %@ ",uuid];
            NSArray *result =  [SPOT MR_findAllWithPredicate:predicate];
            spot = result.firstObject;
            
        }
        // spot_name
        
        GDataXMLElement *spotElement = doc.rootElement;
        
        [self loadSpotSyncDataFrom:spotElement toSpot:spot];
        
        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [magicalContext MR_saveToPersistentStoreAndWait];
        
        return spot;
    }
}


- (void)loadSpotSyncDataFrom:(GDataXMLElement *)spotElement toSpot:(SPOT *)spot
{
    @autoreleasepool {
        NSArray* spotNameElements=[spotElement elementsForName:@"spot_name" ];
        if (spotNameElements.count > 0) {
            GDataXMLElement *spotNameNode = (GDataXMLElement *) [spotNameElements firstObject];
            spot.spot_name = spotNameNode.stringValue;
        }
        
        NSArray* spotTimeLineElements=[spotElement elementsForName:@"time_line_image" ];
        if (spotTimeLineElements.count > 0) {
            GDataXMLElement *spotTimeLineNode = (GDataXMLElement *) [spotTimeLineElements firstObject];
            spot.time_line_image= spotTimeLineNode.stringValue;
        }
        
        
        NSArray* uuidElements=[spotElement elementsForName:@"uuid"];
        if (uuidElements.count > 0) {
            GDataXMLElement *uuidNode = (GDataXMLElement *) [uuidElements firstObject];
            spot.uuid = uuidNode.stringValue;
        }
        
        // phone
        NSArray* phoneElements=[spotElement elementsForName:@"phone"];
        if (phoneElements.count > 0) {
            GDataXMLElement *phoneNode = (GDataXMLElement *) [phoneElements firstObject];
            spot.phone = phoneNode.stringValue;
        }
        
        // url
        NSArray* urlElements=[spotElement elementsForName:@"url"];
        if (urlElements.count > 0) {
            GDataXMLElement *urlNode = (GDataXMLElement *) [urlElements firstObject];
            spot.url = urlNode.stringValue;
        }
        
        // memo
        NSArray* memoElements=[spotElement elementsForName:@"memo"];
        if (memoElements.count > 0) {
            GDataXMLElement *memoNode = (GDataXMLElement *) [memoElements firstObject];
            spot.memo = memoNode.stringValue;
        }
        
        // traffic
        NSArray* trafficElements=[spotElement elementsForName:@"traffic"];
        if (trafficElements.count > 0) {
            GDataXMLElement *trafficNode = (GDataXMLElement *) [trafficElements firstObject];
            spot.traffic = numberFromString(trafficNode.stringValue);
        }
        
        // date
        NSArray* dateElements=[spotElement elementsForName:@"date"];
        if (dateElements.count > 0) {
            GDataXMLElement *dateNode = (GDataXMLElement *) [dateElements firstObject];
            spot.date = [dateTimeFormatter dateFromString:dateNode.stringValue];
        }
        
        //    // start spot
        //    NSArray* startSpotElements=[spotElement elementsForName:@"start_spot"];
        //    if (startSpotElements.count > 0) {
        //        GDataXMLElement *startSpotNode = (GDataXMLElement *) [startSpotElements firstObject];
        //        SPOT *startSpot = [SPOT MR_findFirstByAttribute:@"spot_name" withValue:startSpotNode.stringValue];
        //        if (!startSpot)
        //        {
        //            startSpot = [SPOT MR_createEntity];
        //            startSpot.spot_name = startSpotNode.stringValue;
        //        }
        //
        //        spot.start_spot = startSpot;
        //    }
        NSArray *startSpotNameElement = [spotElement elementsForName:@"start_spot_name"];
        if (startSpotNameElement.count > 0) {
            GDataXMLElement *startSpotNameNode = (GDataXMLElement *)[startSpotNameElement firstObject];
            spot.start_spot_name = startSpotNameNode.stringValue;
        }
        NSArray *startSpotLatElement = [spotElement elementsForName:@"start_spot_lat"];
        if (startSpotLatElement.count > 0) {
            GDataXMLElement *startSpotLatNode = (GDataXMLElement *)[startSpotLatElement firstObject];
            spot.start_spot_lat = numberFromString(startSpotLatNode.stringValue);
        }
        NSArray *startSpotLngElement = [spotElement elementsForName:@"start_spot_lng"];
        if (startSpotLngElement.count > 0) {
            GDataXMLElement *startSpotLngNode = (GDataXMLElement *)[startSpotLngElement firstObject];
            spot.start_spot_lng = numberFromString(startSpotLngNode.stringValue);
        }
        
        // lat
        NSArray* latElements=[spotElement elementsForName:@"lat"];
        if (latElements.count > 0) {
            GDataXMLElement *latNode = (GDataXMLElement *) [latElements firstObject];
            spot.lat = numberFromString(latNode.stringValue);
        }
        
        // lng
        NSArray* lngElements=[spotElement elementsForName:@"lng"];
        if (lngElements.count > 0) {
            GDataXMLElement *lngNode = (GDataXMLElement *) [lngElements firstObject];
            spot.lng = numberFromString(lngNode.stringValue);
        }
        
        // address
        NSArray* addressElements=[spotElement elementsForName:@"address"];
        if (addressElements.count > 0) {
            GDataXMLElement *addressNode = (GDataXMLElement *) [addressElements firstObject];
            spot.address = addressNode.stringValue;
        }
        
        // image list
        NSArray* imageListElements=[spotElement elementsForName:@"image_list"];
        if (imageListElements.count > 0) {
            GDataXMLElement *imageListNode = (GDataXMLElement *) [imageListElements firstObject];
            NSArray* imageElementsArray = [imageListNode elementsForName:@"image"];
            for(GDataXMLElement *imageElement in imageElementsArray)
            {
                Image* image= [Image MR_createEntity];
                NSArray *imageFileNameElements = [imageElement elementsForName:@"image_file_name"];
                if (imageFileNameElements.count > 0) {
                    GDataXMLElement *imageFileNameNode = (GDataXMLElement *) [imageFileNameElements firstObject];
                    image.image_file_name = imageFileNameNode.stringValue;
                }
                
                NSArray *imageOriginalFileNameElements = [imageElement elementsForName:@"image_original_file_name"];
                if (imageOriginalFileNameElements.count > 0) {
                    GDataXMLElement *imageOriginalFileNameNode = (GDataXMLElement *) [imageOriginalFileNameElements firstObject];
                    image.origin_image_file_name = imageOriginalFileNameNode.stringValue;
                    NSLog(@"%@",imageOriginalFileNameNode.stringValue);
                }
                
                NSArray *imageNameCardElements = [imageElement elementsForName:@"image_name_card"];
                if (imageNameCardElements.count > 0) {
                    GDataXMLElement *imageNameCardNode = (GDataXMLElement *) [imageNameCardElements firstObject];
                    image.is_name_card = [NSNumber numberWithInt:imageNameCardNode.stringValue.intValue];
                }
                
                image.spot = spot;
                [spot addImageObject:image];
            }
        }
        
        // memoVoice list
        NSArray* tagListElements=[spotElement elementsForName:@"tag_list"];
        if (tagListElements.count > 0) {
            GDataXMLElement *tagListNode = (GDataXMLElement *) [tagListElements firstObject];
            NSArray *tagElements = [tagListNode elementsForName:@"tag"];
            for (GDataXMLElement *tagElement in tagElements)
            {
                Tag *tag = [Tag MR_findFirstByAttribute:@"tag" withValue:tagElement.stringValue];
                if (!tag)
                {
                    tag = [Tag MR_createEntity];
                    tag.tag = tagElement.stringValue;
                }
                //  [tag addSpotObject:spot];
                [spot addTagObject:tag];
            }
        }
        
        
        // tag list
        NSArray* memoVoiceListElements=[spotElement elementsForName:@"memovoice_list"];
        if (memoVoiceListElements.count > 0) {
            GDataXMLElement *memoVoiceListNode = (GDataXMLElement *) [memoVoiceListElements firstObject];
            NSArray *memoVoiceElements = [memoVoiceListNode elementsForName:@"memoVoice"];
            
            for (GDataXMLElement *memoVoiceElement in memoVoiceElements)
            {
                Voice *voice  = [Voice MR_createEntity];
                
                NSArray *memoVoiceUUIDElements = [memoVoiceElement elementsForName:@"memoVoiceUUID"];
                if (memoVoiceUUIDElements.count > 0) {
                    GDataXMLElement *memoVoiceUUIDNode = (GDataXMLElement *) [memoVoiceUUIDElements firstObject];
                    voice.uuid =  memoVoiceUUIDNode.stringValue;
                }
                
                NSArray *memoVoiceDateElements = [memoVoiceElement elementsForName:@"memoVoiceDate"];
                if (memoVoiceDateElements.count > 0) {
                    GDataXMLElement *memoVoiceDateNode = (GDataXMLElement *) [memoVoiceDateElements firstObject];
                    voice.date = [dateTimeFormatter dateFromString: memoVoiceDateNode.stringValue];
                }
                
                
                NSArray *memoVoiceTimeElements = [memoVoiceElement elementsForName:@"memoVoiceTime"];
                if (memoVoiceTimeElements.count > 0) {
                    GDataXMLElement *memoVoiceTimeNode = (GDataXMLElement *) [memoVoiceTimeElements firstObject];
                    voice.time = [NSNumber numberWithInt:memoVoiceTimeNode.stringValue.intValue];
                    
                }
                
                voice.spot = spot;
                [spot addVoiceObject:voice];
            }
        }
        
        // country
        NSArray* countryElements=[spotElement elementsForName:@"country"];
        if (countryElements.count > 0) {
            GDataXMLElement *countryNode = (GDataXMLElement *) [countryElements firstObject];
            Country *country = [Country MR_findFirstByAttribute:@"country" withValue:countryNode.stringValue];
            if (!country)
            {
                country = [Country MR_createEntity];
                country.country = countryNode.stringValue;
            }
            [country addSpotObject:spot];
            spot.country = country;
        }
        
        // region
        NSArray* regionElements=[spotElement elementsForName:@"region"];
        if (regionElements.count > 0) {
            GDataXMLElement *regionNode = (GDataXMLElement *) [regionElements firstObject];
            Region *region = [Region MR_findFirstByAttribute:@"region" withValue:regionNode.stringValue];
            if (!region)
            {
                region = [Region MR_createEntity];
                region.region = regionNode.stringValue;
            }
            [region addSpotObject:spot];
            spot.region = region;
        }
    }
}

- (GuideBook *) parseXMLSyncDataToGuideBookObject:(NSURL*)xmlFileUrl newEntity:(BOOL)newEntity{
    @autoreleasepool {
        NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:xmlFileUrl];
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                               options:0 error:&error];
        
        if (doc == nil) { return nil; }
        
        GuideBook* guideBook ;
        NSArray* uuidElements=[doc.rootElement elementsForName:@"uuid"];
        GDataXMLElement *uuidElement = (GDataXMLElement *) [uuidElements firstObject];
        NSString *uuid = uuidElement.stringValue;
        
        if (newEntity) {
            
            guideBook = [GuideBook MR_createEntity];
            guideBook.uuid = uuid;
        }
        
        else{
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid like %@ ",uuid];
            NSArray *result =  [SPOT MR_findAllWithPredicate:predicate];
            guideBook = result.firstObject;
        }
        
        
        NSArray* guideBookNameElements=[doc.rootElement elementsForName:@"guide_book_name" ];
        if (guideBookNameElements.count > 0) {
            GDataXMLElement *guideBookNameNode = (GDataXMLElement *) [guideBookNameElements firstObject];
            guideBook.guide_book_name = guideBookNameNode.stringValue;
        }
        
        NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
        [dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateTimeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        NSArray* startDateElements=[doc.rootElement elementsForName:@"start_date" ];
        if (startDateElements.count > 0) {
            GDataXMLElement *startDateNode = (GDataXMLElement *) [startDateElements firstObject];
            guideBook.start_date = [dateTimeFormatter dateFromString:startDateNode.stringValue];
        }
        else {
            guideBook.start_date = [NSDate date];
        }
        
        NSString *startSpotSelectedFromFoursquareString = [self getStringValueFromGDataXMLElementName:@"start_spot_selected_from_foursquare" rootElement:doc.rootElement];
        
        int startSpotSelectedFromFoursquare = startSpotSelectedFromFoursquareString != nil ? [startSpotSelectedFromFoursquareString intValue] : 0;
        
        if (startSpotSelectedFromFoursquare) {
            NSString *foursquareSpotLat = [self getStringValueFromGDataXMLElementName:@"foursquare_spot_lat" rootElement:doc.rootElement];
            guideBook.foursquare_spot_lat = foursquareSpotLat != nil ? @([foursquareSpotLat doubleValue]) : @(0);
            
            NSString *foursquareSpotLng = [self getStringValueFromGDataXMLElementName:@"foursquare_spot_lng" rootElement:doc.rootElement];
            guideBook.foursquare_spot_lng = foursquareSpotLng != nil ? @([foursquareSpotLng doubleValue]) : @(0);
            
            NSString *foursquareSpotName = [self getStringValueFromGDataXMLElementName:@"foursquare_spot_name" rootElement:doc.rootElement];
            guideBook.foursquare_spot_name = foursquareSpotName != nil ? foursquareSpotName : @"";
        }
        else {
            NSArray* startSpotElements = [doc.rootElement elementsForName:@"start_spot" ];
            if (startSpotElements.count > 0) {
                GDataXMLElement *startSportNode = (GDataXMLElement *)[startSpotElements firstObject];
                SPOT *spot = [SPOT MR_createEntity];
                [self loadSpotFrom:startSportNode toSpot:spot];
                guideBook.start_spot = spot;
            }
        }
        
        NSArray* guideBookInfoListElements = [doc.rootElement elementsForName:@"guide_book_info_list" ];
        if (guideBookInfoListElements.count > 0) {
            GDataXMLElement *guideBookInfoListNode = (GDataXMLElement *) [guideBookInfoListElements firstObject];
            NSArray* guideBookInfoElements = [guideBookInfoListNode elementsForName:@"guide_book_info" ];
            NSMutableSet *guideBookInfoList = [NSMutableSet new];
            
            for (GDataXMLElement *guideBookInfoNode in guideBookInfoElements) {
                NSArray* spotElements = [guideBookInfoNode elementsForName:@"spot" ];
                NSArray* memoElements = [guideBookInfoNode elementsForName:@"memo" ];
                NSArray* dayFromStartDayElements = [guideBookInfoNode elementsForName:@"day_from_start_day" ];
                
                NSArray* orderElements = [guideBookInfoNode elementsForName:@"order" ];
                
                
                GuideBookInfo *guideBookInfo = [GuideBookInfo MR_createEntity];
                
                NSArray* infoElements = [guideBookInfoNode elementsForName:@"info_type"];
                GDataXMLElement *infoElement = [infoElements firstObject];
                
                guideBookInfo.info_type = [NSNumber numberWithInt: [infoElement.stringValue intValue]];
                
                
                if (orderElements.count > 0) {
                    GDataXMLElement *orderNode = [orderElements firstObject];
                    
                    guideBookInfo.order = [NSNumber numberWithInt:[orderNode.stringValue intValue]];
                }
                
                if (spotElements.count > 0) {
                    
                    GDataXMLElement *spotNode = [spotElements firstObject];
                    NSString *uuid =((GDataXMLElement*)[[spotNode elementsForName:@"uuid"]firstObject]).stringValue;
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid like %@ ",uuid];
                    NSArray *result =  [SPOT MR_findAllWithPredicate:predicate];
                    SPOT *spot;
                    
                    if (result.count>0) {
                        
                        spot = result.firstObject;
                    }
                    else
                    {
                        spot = [SPOT MR_createEntity];
                        
                    }
                    
                    guideBookInfo.spot = spot;
                    
                }
                else if (memoElements.count > 0){
                    GDataXMLElement *memoNode = [memoElements firstObject];
                    guideBookInfo.memo = memoNode.stringValue;
                }
                else if (dayFromStartDayElements.count > 0) {
                    GDataXMLElement *dayFromStartDayNode = [dayFromStartDayElements firstObject];
                    guideBookInfo.day_from_start_day = [NSNumber numberWithInt: [dayFromStartDayNode.stringValue intValue]];
                }
                
                [guideBookInfoList addObject:guideBookInfo];
            }
            
            guideBook.guide_book_info = guideBookInfoList;
        }
        
        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_contextForCurrentThread];
        // save
        [magicalContext MR_saveToPersistentStoreAndWait];
        return guideBook;
    }
    
}

#pragma mark - Sync


-(void)creatTimerForSync{
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"syncDropbox"]){
        
        if ([_delegate_dropbox_icloud respondsToSelector:@selector(handleAutoSyncDropbox)]) {
            
            [_delegate_dropbox_icloud handleAutoSyncDropbox];
        }
        [self performSelector:@selector(startSync) withObject:nil afterDelay:0.5];
        _timerSyncDropbox =  [NSTimer timerWithTimeInterval:90 target:self selector:@selector(autoSyncDropbox:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_timerSyncDropbox forMode:NSDefaultRunLoopMode];
        
    }
    else if([[NSUserDefaults standardUserDefaults]boolForKey:@"synciCloud"]){
        
        if ([[iCloud sharedCloud]checkCloudAvailability]) {
            
            if ([_delegate_dropbox_icloud respondsToSelector:@selector(handleAutoSynciCloud)]) {
                
                [_delegate_dropbox_icloud handleAutoSynciCloud];
            }
            [self performSelector:@selector(startSync) withObject:nil afterDelay:3];
            
            _timerSynciCloud = [NSTimer timerWithTimeInterval:90 target:self selector:@selector(autoSynciCloud:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:_timerSynciCloud forMode:NSDefaultRunLoopMode];
            
        }
        
        else{
            
            [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please signin your iCloud account" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        }
    }
}


-(void)startSync{
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"syncDropbox"]&&![SPDropBox sharedInstance].isSyncing){
        
        [[SPDropBox sharedInstance] sync];
    }
    else if([[NSUserDefaults standardUserDefaults]boolForKey:@"synciCloud"]&&![iCloud sharedCloud].isSyncing){
        
        if ([[iCloud sharedCloud]checkCloudAvailability]) {
            
            [[iCloud sharedCloud]startup];
        }
    }
}



-(void)autoSyncDropbox:(NSTimer*)timer{
    
    if(![SPDropBox sharedInstance].isSyncing){
        
        [[SPDropBox sharedInstance] forceStopIfRunning];
        [[SPDropBox sharedInstance] sync];
        
        if ([_delegate_dropbox_icloud respondsToSelector:@selector(handleAutoSyncDropbox)]) {
            
            [_delegate_dropbox_icloud handleAutoSyncDropbox];
        }
        
        
    }
}

-(void)autoSynciCloud:(NSTimer*)timer{
    
    if(![iCloud sharedCloud].isSyncing){
        
        if ([_delegate_dropbox_icloud respondsToSelector:@selector(handleAutoSynciCloud)]) {
            
            [_delegate_dropbox_icloud handleAutoSynciCloud];
        }
        [[iCloud sharedCloud]forceStopifRunning];
        [[iCloud sharedCloud]startup];
    }
}


-(void)updateDropboxModifiedDateDataDatabaseforNewEntity:(BOOL)isNewEntity data:(NSMutableDictionary*)data{
    
    FileJournal *fileJournal ;
    
    if (isNewEntity) {
        
        fileJournal = [FileJournal MR_createEntity];
        
    }else{
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"file_name like %@",data[@"file_name"]];
        NSArray *result =  [FileJournal MR_findAllWithPredicate:predicate];
        if (result.count>0) {
            
            fileJournal = result.firstObject;
        }
        else{
            
            fileJournal = [FileJournal MR_createEntity];
        }
    }
    
    fileJournal.last_modified_dropbox = data[@"date_dropbox"];
    fileJournal.last_modified_local = data[@"date_local"];
    fileJournal.file_name = data[@"file_name"];
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    // save
    [magicalContext MR_saveOnlySelfAndWait];
}


-(NSMutableDictionary*)getModifiedDateDropboxFromFilename:(NSString*)filename{
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSLog(@"filename:%@...",filename);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"file_name like %@",filename];
    NSArray *result =  [FileJournal MR_findAllWithPredicate:predicate];
    
    if(result.count>0){
        
        FileJournal *fileJournal = result.firstObject;
        
        [data setObject:fileJournal.last_modified_dropbox forKey:@"date_dropbox"];
        [data setObject:fileJournal.last_modified_local forKey:@"date_local"];
        [data setObject:filename forKey:@"file_name"];
    }
    else{
        //
        //        [data setObject:[NSNull null] forKey:@"date_dropbox"];
        //        [data setObject:[NSNull null] forKey:@"date_local"];
        //        [data setObject:[NSNull null] forKey:@"file_name"];
    }
    
    return data;
}


-(void)handleDeleteFileonDropbox:(NSNotification*)notification{
    
    
    NSDictionary *dic = notification.userInfo;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"file_name like %@",dic[FILE_PATH_DELETE_DROPBOX_KEY]];
    NSArray *result =  [FileJournal MR_findAllWithPredicate:predicate];
    
    if (result.count>0) {
        FileJournal *fileJournal  = result.firstObject;
        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
        [fileJournal MR_deleteInContext:magicalContext];
        [magicalContext MR_saveOnlySelfAndWait];
    }
    
}

#pragma mark - Application Delegate


- (void)setupDirectories
{
    // set up the directories to store data
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.applicationDocumentsDirectory = documentsDirectory;
    self.applicationDocumentsDirectoryForImage = [documentsDirectory stringByAppendingPathComponent:IMAGE_PATH];
    self.applicationDocumentsDirectoryForSpotData = [documentsDirectory stringByAppendingPathComponent:SPOT_DATA_PATH];
    self.applicationDocumentsDirectoryForGuideBookData = [documentsDirectory stringByAppendingPathComponent:GUIDE_BOOK_DATA_PATH];
    self.applicationDocumentsDirectoryForMemoVoice = [documentsDirectory stringByAppendingPathComponent:MEMO_VOICE_DATA_PATH];
    self.applicationTempDirectory = NSTemporaryDirectory();
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"journal_spot"])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"journal_spot"] withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.applicationDocumentsDirectory])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.applicationDocumentsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.applicationDocumentsDirectoryForImage])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.applicationDocumentsDirectoryForImage withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.applicationDocumentsDirectoryForSpotData])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.applicationDocumentsDirectoryForSpotData withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.applicationDocumentsDirectoryForGuideBookData])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.applicationDocumentsDirectoryForGuideBookData withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.applicationDocumentsDirectoryForMemoVoice])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.applicationDocumentsDirectoryForMemoVoice withIntermediateDirectories:NO attributes:nil error:&error];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupImages];
    [self setupFonts];
    
    isShowPasscode = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    saveXMLQueue = dispatch_queue_create("com.framgia.saveXMLQUEUE", NULL);
    
    //    formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"yyyy-MM-dd"];
    //    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    dateTimeFormatter = [[NSDateFormatter alloc] init];
    [dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    [dateTimeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    
    // Override point for customization after application launch.
    [GMSServices provideAPIKey:GOOGLE_MAP_SERVICE_KEY];
    [Foursquare2 setupFoursquareWithClientId:@"HF3CGKZGVBU5SL4HX0WBEFMMPDF330YUWXYMI34DFJQSZ3R5"
                                      secret:@"YL2M233N3VVKW0XGWNZBXB4UOA1LLUOYRCBM5CI35QPGG2ER"
                                 callbackURL:@"spotapp://foursquare"];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.transportationList=@[ @"None", @"Walk", @"Car/Taxi", @"Air plane", @"Train", @"Bus"];
    
    self.darkView = [[UIView  alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    self.darkView.backgroundColor = [UIColor darkTextColor];
    self.darkView.alpha = 0.8;
    self.actionSheetSimulationView = [[UINib nibWithNibName:@"ActionSheetSimulationView" bundle:nil] instantiateWithOwner:self options:nil][0];
    [self.actionSheetSimulationView setFrame:CGRectMake(20.0f,
                                                        [[UIScreen mainScreen] applicationFrame].size.height + self.actionSheetSimulationView.bounds.size.height+20,
                                                        self.actionSheetSimulationView.bounds.size.width,
                                                        self.actionSheetSimulationView.bounds.size.height)];
    
    
    // listen if UIApplicationProtectedDataDidBecomeAvailable to process received info from Airdrop
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(protectedDataDidBecomeAvailable) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
    
    // Make status bar opaque
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.statusBar = [[UIView alloc] init];
        self.statusBar.frame = CGRectMake(0, 0, 320, 20);
        self.statusBar.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1]; //change this to match your navigation bar
        [self.window.rootViewController.view addSubview:self.statusBar];
    }
    
    //Clear cache dropbox in device
    [[SPDropBox sharedInstance]registerDropboxAPI];
    
    if (![AppSettings isSecondRun]) {  // is first run
        //reset dropboxx
        [[SPDropBox sharedInstance]logout];
        //reset foursquare
        [Foursquare2 removeAccessToken];
        //reset passcode
        [LTHPasscodeViewController deletePasscode];
        
        [AppSettings setIsSecondRun:YES];
    }
    
    [self setupDirectories];
    
    
    [self creatTimerForSync];
    
    [MagicalRecord setupCoreDataStack];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeleteFileonDropbox:) name:@"FinishDeletedFileonDropbox" object:nil];
    
    // get current location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [locationManager requestAlwaysAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
    // config all search textfield
    UITextField *searchField = [UITextField appearanceWhenContainedIn:[UISearchBar class], nil];
    //    [searchField setFont:[UIFont italicSystemFontOfSize:14.0f]];
    
    [searchField setFont:self.normalFont];
    
    
    UIBarButtonItem *searchButton = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    
    [searchButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          self.normalFont, NSFontAttributeName,
                                          [UIColor darkGrayColor], NSForegroundColorAttributeName,
                                          nil]
                                forState:UIControlStateNormal];
    
    
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_box"]forState:UIControlStateNormal];
    [[UISearchBar appearance] setBackgroundColor:[UIColor whiteColor]];
    
    //    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"Slice_icon_88"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    [[UISearchBar appearance] setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
    
    
    // set font and color for bar buttons
    BarButtonItem *barButton = [BarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil];
    
    [barButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.largeFont, NSFontAttributeName,
                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                       nil]
                             forState:UIControlStateNormal];
    
    UIBarButtonItem *topNavButton = [UIBarButtonItem appearanceWhenContainedIn: [UINavigationBar class],  nil];
    
    [topNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.largeFont, NSFontAttributeName,nil]
                                forState:UIControlStateNormal];
    
    //    [topNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                          [UIFont fontWithName:FONT_NAME size:FONT_LARGE_SIZE], NSFontAttributeName,
    //                                          [UIColor whiteColor], NSForegroundColorAttributeName,
    //                                          nil]
    //                                forState:UIControlStateNormal];
    
    //prevent re-loading of the image
    
    //    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
    //                                                         diskCapacity:20 * 1024 * 1024
    //                                                             diskPath:nil];
    //    [NSURLCache setSharedURLCache:URLCache];
    
    [AppSettings setIsAuthorizedFoursquare:[Foursquare2 isAuthorized]];
    
    [self createXmlForSpotFromFoursquare];
    
    // ImageCacher
    CenterModeImageFetcher *detailsImageFetcher = [[CenterModeImageFetcher alloc] initWithFrameWidth:58 andFrameHeight:58];
    self.detailsImageCacher = [[ImageCacher alloc] initWithFetcher:detailsImageFetcher];
    
    
    CenterModeImageFetcher *spotSlideImageFetcher = [[CenterModeImageFetcher alloc] initWithFrameWidth:320 andFrameHeight:225];
    
    self.spotSlideImageCacher= [[ImageCacher alloc] initWithFetcher:spotSlideImageFetcher];
    
    //    CenterModeImageFetcher *guideBookSlideImageFetcher = [[CenterModeImageFetcher alloc] initWithFrameWidth:320 andFrameHeight:130];
    //
    //    self.guideBookSlideImageCacher= [[ImageCacher alloc] initWithFetcher:guideBookSlideImageFetcher];
    //
    
    // setup fetch
    
    //    self.spotFetchedResultsController = [SPOT MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:nil groupBy:@"month" delegate:self];
    
    
    [Flurry setCrashReportingEnabled:YES];
    
    // Replace YOUR_API_KEY with the api key in the downloaded package
    [Flurry startSession:@"K3WPTGRQ9JY8CT3P35FR"];
    
    
    return YES;
}

- (void)setupImages {
    self.cellBackgroundImage = [UIImage imageNamed:@"Slice_icon_17"];
    
    self.smallIcons = [[NSMutableDictionary alloc] init];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_194"] forKey:@"SpotName"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_203"] forKey:@"Address"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_208"] forKey:@"Memo"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_22"] forKey:@"Traffic"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_205"] forKey:@"Phone"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_210"] forKey:@"Url"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_200"] forKey:@"Tag"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Voicememo_slice_10"] forKey:@"Voice"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Voicememo_slice_10_blue"] forKey:@"VoiceBlue"];
    
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_156"] forKey:@"TrafficWalk"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_166"] forKey:@"TrafficTrain"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_169"] forKey:@"TrafficCar"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_172"] forKey:@"TrafficBus"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_164"] forKey:@"TrafficAirPlane"];
    
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_271"] forKey:@"GuideBookName"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_266"] forKey:@"StartDate"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_79"] forKey:@"Foursquare"];
    
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_120"] forKey:@"Delete"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_122"] forKey:@"TagWhite"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_117"] forKey:@"Airdrop"];
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_128"] forKey:@"Edit"];
    
    [self.smallIcons setValue:[UIImage imageNamed:@"Slice_icon_186"] forKey:@"Marker"];
}

- (UIImage *)getImageWithName:(NSString *)name {
    return [self.smallIcons objectForKey:name];
}

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (void)setupFonts {
    
    if ([[self platform] isEqualToString:@"iPhone7,1"]) {  // iPhone 6+
        self.smallFont = [UIFont fontWithName:FONT_NAME size:FONT_MINI_SIZE];
        self.normalFont = [UIFont fontWithName:FONT_NAME size:FONT_SMALL_SIZE];
        self.largeFont = [UIFont fontWithName:FONT_NAME size:FONT_NORMAL_SIZE];
    }
    else {
        self.smallFont = [UIFont fontWithName:FONT_NAME size:FONT_SMALL_SIZE];
        self.normalFont = [UIFont fontWithName:FONT_NAME size:FONT_NORMAL_SIZE];
        self.largeFont = [UIFont fontWithName:FONT_NAME size:FONT_LARGE_SIZE];
    }
    
}


- (UIImage *)getTrafficIconByType:(int)type {
    NSString *key;
    switch (type) {
        case TrafficTypeWalk:
            key = @"TrafficWalk";
            break;
        case TrafficTypeTrain:
            key = @"TrafficTrain";
            break;
        case TrafficTypeCar:
            key = @"TrafficCar";
            break;
        case TrafficTypeBus:
            key = @"TrafficBus";
            break;
        case TrafficTypeAirPlane:
            key = @"TrafficAirPlane";
            break;
        default:
            return nil;
    }
    
    return [self.smallIcons objectForKey:key];
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //for case iCloud syncing
    
    if([iCloud sharedCloud].isSyncing){
        
        [[iCloud sharedCloud]forceStopifRunning];
        [iCloud sharedCloud].suspendedWhileSyncing = YES;
    }
    
    //for case dropbox syncing
    
    else if([SPDropBox sharedInstance].isSyncing){
        
        [SPDropBox sharedInstance].suspendedWhileSyncing = YES;
        [[SPDropBox sharedInstance]forceStopIfRunning];
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Banner shared];
    
    // to refresh current location
    receivedGPS = NO;
    
    // for case user syncing and switch other app
    
    if ([Banner shared].isErroring) {
        
        [[Banner shared] performSelector:@selector(creatBanner) withObject:nil afterDelay:0.2];
        
    }
    
    
    if([iCloud sharedCloud].suspendedWhileSyncing){
        
        [iCloud sharedCloud].suspendedWhileSyncing=NO;
        
        //        if([iCloud sharedCloud].syncingPath.length){
        //            NSLog(@"%@",[iCloud sharedCloud].syncingPath);
        //
        //            [[iCloud sharedCloud] deleteDocumentWithName:[iCloud sharedCloud].syncingPath.lastPathComponent completion:^(NSError *error) {
        
        [[iCloud sharedCloud]startup];
        //            }];
        
        //        }
    }
    
    // For case if user login icloud and back to spot
    
    else if ([[iCloud sharedCloud]checkCloudAvailability]&&[[NSUserDefaults standardUserDefaults]boolForKey:@"synciCloud"]){
        
        [self creatTimerForSync];
    }
    
    //for case user syncing dropbox and back to spot
    
    else if([SPDropBox sharedInstance].suspendedWhileSyncing){
        
        [SPDropBox sharedInstance].suspendedWhileSyncing=NO;
        [[SPDropBox sharedInstance]sync];
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    appDelegate = self;
    
//    [self setupDirectories];
    
    if (isShowPasscode) {
        [LTHPasscodeViewController useKeychain:NO];
        if ([LTHPasscodeViewController doesPasscodeExist]) {
            if ([LTHPasscodeViewController didPasscodeTimerEnd]){
                isShowPasscode = NO;
                LTHPasscodeViewController* controller = [LTHPasscodeViewController sharedUser];
                [controller showLockScreenWithAnimation:YES withLogout:NO
                                         andLogoutTitle:nil];
                controller.delegate = self;
            }
        }
    }
    //    if (![Foursquare2 isAuthorized]) {
    //        self.isSyncingFoursquare = NO;
    //    }
    //[self createNewGuideBook];
    
    // Show passcode screen
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)passcodeViewControllerWillClose {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"passcodeViewControllerWillClose" object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[iCloud sharedCloud] forceStopifRunning];
    [[SPDropBox sharedInstance]forceStopIfRunning];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"MEMORY WARNING.....");
    [self.detailsImageCacher clearCache];
    
    // Dispose of any resources that can be recreated.
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];

}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SPOT" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"SPOT.sqlite"]];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Get current location, didFailWithError: %@", error);
    receivedGPS = NO;
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    //    NSLog(@"didUpdateToLocation: %@", newLocation);
//    CLLocation *currentLocation = newLocation;
//
//    if (currentLocation != nil) {
//        [AppSettings setLatitude:currentLocation.coordinate.latitude];
//        [AppSettings setLongitude:currentLocation.coordinate.longitude];
//    }
//}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //    NSLog(@"didUpdateToLocation: %@", locations);
    if (receivedGPS) {
        return;
    }
    CLLocation *currentLocation = [locations firstObject];
    //    NSLog(@"didUpdateToLocation: %@", currentLocation);
    
    [AppSettings setLatitude:currentLocation.coordinate.latitude];
    [AppSettings setLongitude:currentLocation.coordinate.longitude];
    receivedGPS = YES;
}




- (void) deleteAllNotUsedImage
{
    NSLog(@"deleteAllNotUsedImage");
    NSArray *all = [Image MR_findAll];
    int len = (int)[all count];
    
    for ( int i = 0 ; i < len ; i++ ) {
        Image *image = [all objectAtIndex:i];
        if (!image.spot)
        {
            NSString *savedImagePath = [[self applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:image.image_file_name];
            NSError *error;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:savedImagePath error:&error];
            if (success) {
                [image MR_deleteEntity];
            }
            else
            {
                NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
            }
        }
    }
    
    
    
}

#pragma mark - Foursquare
- (void) startSyncFoursquare
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"lost connection");
        NSLog(@"MainThread:%@ CurrentThread: %@",[NSThread mainThread],[NSThread currentThread]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"completeSyncFoursquare" object:nil];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.isSyncingFoursquare = YES;
    __block NSString *foursquareUsername = [AppSettings getFoursquareUser];
    BOOL isFoursquareAuthorized = [AppSettings isAuthorizedFoursquare];
    if (foursquareUsername.length > 0 && isFoursquareAuthorized) {
        NSLog(@"sync with username");
        FoursquareUser *foursquareUser = [self foursquareGetUser:foursquareUsername];
        
        NSDate *lastCheckinSavedDate = foursquareUser.last_checkin;
        // Get checkins of user
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self foursquareUserGetCheckin:lastCheckinSavedDate ofFoursquareUser: foursquareUser];
        });
    } else if (isFoursquareAuthorized && !foursquareUsername){
        NSLog(@"sync without username");
        [Foursquare2 userGetDetail:@"self" callback:^(BOOL success, id result) {
            if (success) {
                foursquareUsername = [result valueForKeyPath:@"response.user.contact.email"];
                [AppSettings setFoursquareUser:foursquareUsername];
                
                FoursquareUser *foursquareUser = [self foursquareGetUser:foursquareUsername];
                
                NSDate *lastCheckinSavedDate = foursquareUser.last_checkin;
                // Get checkins of user
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self foursquareUserGetCheckin:lastCheckinSavedDate ofFoursquareUser: foursquareUser];
                });
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"failSyncFoursquare" object:nil];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                self.isSyncingFoursquare = NO;
            }
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"failSyncFoursquare" object:nil];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.isSyncingFoursquare = NO;
    }
}

- (void) foursquareUserGetCheckin: (NSDate *)lastCheckin ofFoursquareUser: (FoursquareUser *)foursquareUser
{
    
    [Foursquare2 userGetCheckins:@"self" limit:[NSNumber numberWithInt:250] offset:nil sort:FoursquareCheckinsOldestFirst after:lastCheckin before:nil callback:^(BOOL success, id result) {
        if (success) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
                // Get newest downloaded checkin date (we'll save this date to db)
                NSArray *items = [result valueForKeyPath:@"response.checkins.items"];
                
                if ([items count] == 0) { // nothing to sync
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"completeSyncFoursquare" object:nil];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    self.isSyncingFoursquare = NO;
                    return ;
                }
                
                NSString *checkinDateInSeconds = [[items objectAtIndex:([items count]-1)] valueForKeyPath:@"createdAt"];
                NSDate *newestCheckinDate = [self dateConvertFromStringSeconds:checkinDateInSeconds];
                foursquareUser.last_checkin = newestCheckinDate;
                
                [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *foursquareLocalContext) {
                    @autoreleasepool {
                        int checkinCount = 0;
                        BOOL isEndLoop = YES;
                        
                        // query country from db
                        NSArray *queryCountryArray = [Country MR_findAllInContext:foursquareLocalContext];
                        NSArray *queryCountryNameArray = [queryCountryArray valueForKeyPath:@"country"];
                        NSMutableDictionary *queryCountryDictionary = [[NSMutableDictionary alloc] initWithObjects:queryCountryArray forKeys:queryCountryNameArray];
                        // query region from db
                        NSArray *queryRegionArray = [Region MR_findAllInContext:foursquareLocalContext];
                        NSArray *queryRegionNameArray = [queryRegionArray valueForKeyPath:@"region"];
                        NSMutableDictionary *queryRegionDictionary = [[NSMutableDictionary alloc] initWithObjects:queryRegionArray forKeys:queryRegionNameArray];
                        // query tag from db
                        NSArray *queryTagArray = [Tag MR_findAllInContext:foursquareLocalContext];
                        NSArray *queryTagNameArray = [queryTagArray valueForKeyPath:@"tag"];
                        NSMutableDictionary *queryTagDictionary = [[NSMutableDictionary alloc] initWithObjects:queryTagArray forKeys:queryTagNameArray];
                        
                        // loop all checkins to create new spots
                        for (NSDictionary *item in items) {
                            @autoreleasepool {
                                checkinCount++;
                                NSLog(@"checkin count : %d", checkinCount);
                                NSString *checkinDateInStringSeconds = [item valueForKeyPath:@"createdAt"];
                                NSDate *checkinDate = [self dateConvertFromStringSeconds:checkinDateInStringSeconds];
                                // create new spot if User nerver sync before or checkin date is newer than last user sync date
                                if (!lastCheckin || ([checkinDate compare:lastCheckin] == NSOrderedDescending)) {
                                    isEndLoop = NO;
                                    [self createNewSpotFromFoursquare:item inDate:checkinDate countryDictionary:queryCountryDictionary regionDictionary:queryRegionDictionary tagDictionary:queryTagDictionary inContext: foursquareLocalContext];
                                }

                            }
                        }
                        
                        // condition to stop recursion
                        if (checkinCount < MAX_RESULTS_COUNT || isEndLoop) {
                            [self createXmlForSpotFromFoursquare];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"completeSyncFoursquare" object:nil];
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                            self.isSyncingFoursquare = NO;
                            return;
                        }
                        
                        [NSThread sleepForTimeInterval:1];
                        
                        // recursion
                        [self foursquareUserGetCheckin:foursquareUser.last_checkin ofFoursquareUser:foursquareUser];

                    }
                    
                } completion:nil];
            });
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failSyncFoursquare" object:nil];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            self.isSyncingFoursquare = NO;
        }
    }];
}

// Create spot to managed object context
- (void) createNewSpotFromFoursquare: (NSDictionary *)item inDate:(NSDate *)checkinDate countryDictionary: (NSMutableDictionary *) queryCountryDictionary regionDictionary: (NSMutableDictionary *) queryRegionDictionary tagDictionary: (NSMutableDictionary *)queryTagDictionary inContext:(NSManagedObjectContext *) foursquareLocalContext
{
    // Check if user checkin many time at one place, we only create one spot
    if (![self isVenueExist:[item valueForKeyPath:@"venue.name"] inContext: foursquareLocalContext]) {
        //        SPOT *newSpot = [SPOT MR_createEntity];
        SPOT *newSpot = [SPOT MR_createInContext:foursquareLocalContext];
        newSpot.uuid = [[NSUUID UUID] UUIDString];
        newSpot.is_need_create_xml = YES;
        newSpot.lat = [item valueForKeyPath:@"venue.location.lat"];
        newSpot.lng = [item valueForKeyPath:@"venue.location.lng"];
        newSpot.date = checkinDate;
        newSpot.address = [item valueForKeyPath:@"venue.location.address"];
        newSpot.spot_name = [item valueForKeyPath:@"venue.name"];
        newSpot.phone = [item valueForKeyPath:@"venue.contact.formattedPhone"];
        newSpot.url = [item valueForKeyPath:@"venue.url"];
        if ([[item valueForKeyPath:@"venue.location.country"] length] > 0) {
            NSString *countryName = [item valueForKeyPath:@"venue.location.country"];
            Country *country = [queryCountryDictionary objectForKey:countryName];
            if (country == nil) {
                //                country = [Country MR_createEntity];
                country = [Country MR_createInContext:foursquareLocalContext];
                country.country = countryName;
                [queryCountryDictionary setValue:country forKey:countryName];
            }
            newSpot.country = country;
        }
        if ([[item valueForKeyPath:@"venue.location.state"] length] > 0) {
            NSString *regionName = [item valueForKeyPath:@"venue.location.state"];
            Region *region = [queryRegionDictionary objectForKey:regionName];
            if (region == nil) {
                //                region = [Region MR_createEntity];
                region = [Region MR_createInContext:foursquareLocalContext];
                region.region = regionName;
                [queryRegionDictionary setValue:region forKey:regionName];
            }
            newSpot.region = region;
        }
        // tag
        if ([[item valueForKeyPath:@"venue.categories.name"] count] > 0) {
            NSString *categoryTagName = [[item valueForKeyPath:@"venue.categories.name"] objectAtIndex:0];
            Tag *categoryTag = [queryTagDictionary objectForKey:categoryTagName];
            if (categoryTag == nil) {
                //                categoryTag = [Tag MR_createEntity];
                categoryTag = [Tag MR_createInContext:foursquareLocalContext];
                categoryTag.tag = categoryTagName;
                [queryTagDictionary setValue:categoryTag forKey:categoryTagName];
            }
            [categoryTag addSpotObject:newSpot];
            //            [newSpot addTagObject:categoryTag];
        }
        if ([[item valueForKeyPath:@"venue.location.city"] length] > 0) {
            NSString *locationTagName = [item valueForKeyPath:@"venue.location.city"];
            Tag *locationTag = [queryTagDictionary objectForKey:locationTagName];
            if (locationTag == nil) {
                //                locationTag = [Tag MR_createEntity];
                locationTag = [Tag MR_createInContext:foursquareLocalContext];
                locationTag.tag = locationTagName;
                [queryTagDictionary setValue:locationTag forKey:locationTagName];
            }
            [locationTag addSpotObject:newSpot];
            //            [newSpot addTagObject:locationTag];
        }
        
        // Customer change requirement
        //    // Image
        //    NSString *venueId = [item valueForKeyPath:@"venue.id"];
        //    // check if user choose save image
        //    if ([[self.userChosenCategories valueForKey:@"Allow"] isEqualToString:@"YES"]) {
        //        [self getImagesOfVenue:venueId andAddToSpot:newSpot];
        //    }
        //    // memo
        //    NSString *checkinId = [item valueForKey:@"id"];
        //    [self checkinGetComments:checkinId andAddToSpot: newSpot];
        //    [self venueGetTips:venueId andAddToSpot: newSpot];
    }else {
        if ([self.spot.date compare:checkinDate] == NSOrderedAscending) {
            self.spot.date = checkinDate;
        }
    }
}

- (BOOL) isVenueExist: (NSString *)venueName inContext: (NSManagedObjectContext *)foursquareLocalContext
{
    //    NSArray *spots = [SPOT MR_findByAttribute:@"spot_name" withValue:venueName];
    NSArray *spots = [SPOT MR_findByAttribute:@"spot_name" withValue:venueName inContext:foursquareLocalContext];
    if ([spots count] > 0) {
        self.spot = [spots objectAtIndex:0];
        return YES;
    }
    return NO;
}

//- (void) saveDataToDatabase: (NSManagedObjectContext *)foursquareLocalContext
//{
//    
//    [foursquareLocalContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
//        if (success) {
//            NSLog(@"You successfully saved your context.");
//            [self createXmlForSpotFromFoursquare];
//        }else{
//            NSLog(@"Error saving context: %@", error.description);
//        }
//    }];
//}

- (void) createXmlForSpotFromFoursquare {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        //        NSManagedObjectContext *saveXmlContext = [NSManagedObjectContext MR_context];
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        
        NSArray *SpotToXmlArray = [SPOT MR_findByAttribute:@"is_need_create_xml" withValue:@YES inContext:context];
     
        for (SPOT *xmlSpot in SpotToXmlArray) {
            @autoreleasepool {
                NSLog(@"spotName: %@", xmlSpot.spot_name);
                xmlSpot.is_need_create_xml = NO;
                [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                    NSLog(@"%@",xmlSpot.uuid);
                    if (success) {
                        [self saveSpotToXMLForSync:xmlSpot];
                    }
                }];
                [NSThread sleepForTimeInterval:0.1];
            }
        }
        
    });
}

- (FoursquareUser *) foursquareGetUser: (NSString *)username
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *users = [FoursquareUser MR_findByAttribute:@"username" withValue:username inContext:context];
    FoursquareUser *user = nil;
    
    if([users count] > 0){
        user = [users objectAtIndex:0];
    }else{
        user = [FoursquareUser MR_createInContext:context];
        user.username = username;
        [context MR_saveToPersistentStoreAndWait];
    }
    
    return user;
}

- (NSDate *) dateConvertFromStringSeconds: (NSString *)secondsInString
{
    long secondsInInteger = [secondsInString intValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:secondsInInteger];
    return date;
}


@end
