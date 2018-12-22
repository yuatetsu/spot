//
//  AirdropService.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/22/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "AirdropService.h"
#import "AppDelegate.h"
#import "SPOT.h"
#import "Image.h"
#import "Voice.h"
#import "Tag.h"
#import "Country.h"
#import "Region.h"
#import "GuideBook.h"
#import "GuideBookInfo.h"
#import "GuideBookInfoType.h"

@implementation AirdropService

AppDelegate *appDelegate;

- (NSString *)sendSpot:(SPOT *)spot {
    @autoreleasepool {
        SPOT *localSpot = spot;
        
        NSString *fileName =  [StringHelpers validFileNameFromString:localSpot.spot_name];
        NSString *filePath = [[appDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:[(fileName ? fileName : @"noname")stringByAppendingPathExtension:@"spot"]];
        
        NSLog(@"Saving data to %@...", filePath);
        NSDictionary *dic = [self dictionaryFromSpot:localSpot];
        
        BOOL success = [NSKeyedArchiver archiveRootObject:dic toFile:filePath];
        
        if (success) {
            return filePath;
        }
        return nil;
    }
}

- (NSDictionary *)dictionaryFromSpot:(SPOT *)inputSpot {
    SPOT *spot = inputSpot;
    NSMutableDictionary *spotDictionary = [NSMutableDictionary new];
    
    [spotDictionary setValue:@"spot" forKey:@"file_type"];
    
    [spotDictionary setValue:spot.address forKey:@"address"];
    [spotDictionary setValue:spot.date forKey:@"date"];
    [spotDictionary setValue:spot.lat forKey:@"lat"];
    [spotDictionary setValue:spot.lng forKey:@"lng"];
    [spotDictionary setValue:spot.memo forKey:@"memo"];
//    [spotDictionary setValue:spot.month forKey:@"month"];
//    [spotDictionary setValue:spot.pdf_file_name forKey:@"pdf_file_name"];
    [spotDictionary setValue:spot.phone forKey:@"phone"];
    [spotDictionary setValue:spot.spot_description forKey:@"spot_description"];
    [spotDictionary setValue:spot.spot_name forKey:@"spot_name"];
    [spotDictionary setValue:spot.start_spot_lat forKey:@"start_spot_lat"];
    [spotDictionary setValue:spot.start_spot_lng forKey:@"start_spot_lng"];
    [spotDictionary setValue:spot.start_spot_name forKey:@"start_spot_name"];
//    [spotDictionary setValue:spot.thumbnail_file_name forKey:@"thumbnail_file_name"];
    [spotDictionary setValue:spot.traffic forKey:@"traffic"];
    [spotDictionary setValue:spot.url forKey:@"url"];
    [spotDictionary setValue:spot.time_line_image forKey:@"time_line_image"];
    
    // IMAGES
    NSMutableArray *imageArray = [NSMutableArray new];
    NSArray *images = spot.image.allObjects;
    for (Image* image in images)
    {
        NSMutableDictionary *imageDictionary = [NSMutableDictionary new];
        [imageDictionary setValue:image.image_file_name forKey:@"image_file_name"];
        NSData *imageData = (!image.image_file_name) ? nil : [NSData dataWithContentsOfFile:[[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:image.image_file_name]];
        [imageDictionary setValue:imageData forKey:@"image_data"];
        [imageArray addObject:imageDictionary];
        imageDictionary = nil;
        
    }
    [spotDictionary setValue:imageArray forKey:@"images"];
    imageArray = nil;
    
    // VOICES
    
    NSMutableArray *voiceArray = [NSMutableArray new];
    
    NSArray *voices = spot.voice.allObjects;
    for (Voice* voice in voices)
    {
        NSMutableDictionary *voiceDictionary = [NSMutableDictionary new];
        [voiceDictionary setValue:voice.date forKey:@"date"];
        [voiceDictionary setValue:voice.time forKey:@"time"];
        
        NSData *voiceData = [NSData dataWithContentsOfFile:[appDelegate.applicationDocumentsDirectoryForMemoVoice stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",voice.uuid,EXTENSION_RECORD]]];
        
        [voiceDictionary setValue:voiceData forKey:@"voice_data"];
        
        [voiceArray addObject:voiceDictionary];
        voiceDictionary = nil;
        
    }
    [spotDictionary setValue:voiceArray forKey:@"voices"];
    voiceArray = nil;
    
    // TAGS
    NSMutableArray *tagArray = [NSMutableArray new];
    NSArray *tags = spot.tag.allObjects;
    for (Tag *tag in tags) {
        NSMutableDictionary *tagDictionary = [NSMutableDictionary new];
        [tagDictionary setValue:tag.tag forKey:@"tag"];
        [tagArray addObject:tagDictionary];
        tagDictionary = nil;
    }
    [spotDictionary setValue:tagArray forKey:@"tags"];
    tagArray = nil;
    
    [spotDictionary setValue:spot.country.country forKey:@"country"];
    [spotDictionary setValue:spot.region.region forKey:@"region"];
    
    spot = nil;
    
    return spotDictionary;
}

- (NSString *)sendGuideBook:(GuideBook *)guideBook {
    
    @autoreleasepool {
        NSString *fileName =  [StringHelpers validFileNameFromString:guideBook.guide_book_name];
        NSString *filePath = [[appDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:[(fileName ? fileName : @"noname")stringByAppendingPathExtension:@"spot"]];
        
        NSLog(@"Saving data to %@...", filePath);
        NSDictionary *dic = [self dictionaryFromGuideBook:guideBook];
        
        __unused BOOL success = [NSKeyedArchiver archiveRootObject:dic toFile:filePath];
        dic = nil;
        if (success) {
            return filePath;
        }
        return nil;
    }
}

- (NSDictionary *)dictionaryFromGuideBook:(GuideBook *)inputGuideBook {
    GuideBook *guideBook = inputGuideBook;
    NSMutableDictionary *guideBookDictionary = [NSMutableDictionary new];
    [guideBookDictionary setValue:@"guidebook" forKey:@"file_type"];
    
//    @property (nonatomic, retain) NSSet *guide_book_info;
    
    [guideBookDictionary setValue:guideBook.foursquare_spot_lat forKey:@"foursquare_spot_lat"];
    [guideBookDictionary setValue:guideBook.foursquare_spot_lng forKey:@"foursquare_spot_lng"];
    [guideBookDictionary setValue:guideBook.foursquare_spot_name forKey:@"foursquare_spot_name"];
    [guideBookDictionary setValue:guideBook.guide_book_name forKey:@"guide_book_name"];
    [guideBookDictionary setValue:guideBook.pdf_file_name forKey:@"pdf_file_name"];
    [guideBookDictionary setValue:guideBook.start_date forKey:@"start_date"];
    [guideBookDictionary setValue:guideBook.start_spot_selected_from_foursquare forKey:@"start_spot_selected_from_foursquare"];
    
    // START SPOT
    if (guideBook.start_spot) {
        [guideBookDictionary setValue:[self dictionaryFromSpot:guideBook.start_spot] forKey:@"start_spot"];
    }
    
    // GUIDE BOOK INFO
    NSArray *guideBookInfos = [guideBook.guide_book_info allObjects];
    NSMutableArray *guideBookInfoArray = [NSMutableArray new];
    
    for (GuideBookInfo *guideBookInfo in guideBookInfos) {
      
        NSMutableDictionary *guideBookInfoDictionary = [NSMutableDictionary new];
        if (!guideBookInfo.info_type) {  // nil due to add guide book memo bug
            guideBookInfo.info_type = [NSNumber numberWithInt:GuideBookInfoTypeMemo];
        }
        [guideBookInfoDictionary setObject:guideBookInfo.info_type forKey:@"info_type"];
        [guideBookInfoDictionary setObject:guideBookInfo.order forKey:@"order"];
        
        switch (guideBookInfo.info_type.intValue) {
            case GuideBookInfoTypeDay:
                [guideBookInfoDictionary setObject:guideBookInfo.day_from_start_day forKey:@"day_from_start_day"];
                break;
            case GuideBookInfoTypeMemo:
                [guideBookInfoDictionary setObject:guideBookInfo.memo forKey:@"memo"];
                break;
            case GuideBookInfoTypeSpot:
                [guideBookInfoDictionary setObject:[self dictionaryFromSpot:guideBookInfo.spot] forKey:@"spot"];
                break;
        }
        [guideBookInfoArray addObject:guideBookInfoDictionary];
    }
    [guideBookDictionary setValue:guideBookInfoArray forKey:@"guide_book_info"];
    
    guideBook = nil;
    
    return guideBookDictionary;
}

- (void)importObjectFromFile:(NSString *)filePath {
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [self importObjectFromFileData:data];
    }
}

- (void)importObjectFromUrl:(NSURL *)url {
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self importObjectFromFileData:data];
    }
}

- (void)importObjectFromFileData:(NSData *)data {
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *fileType = [dictionary objectForKey:@"file_type"];
    
    if ([fileType isEqualToString:@"spot"]) {
        [self spotFromDictionary:dictionary];
    }
    else if ([fileType isEqualToString:@"guidebook"]) {
        [self guideBookFromDictionary:dictionary];
    }
}

- (SPOT *)spotFromDictionary: (NSDictionary *)inputDictionary {
    @autoreleasepool {
        NSDictionary *dictionary = inputDictionary;
        SPOT *spot = [SPOT MR_createEntity];
        spot.uuid = [[NSUUID UUID] UUIDString];
        
        spot.address = [dictionary objectForKey:@"address"];
        spot.date = [dictionary objectForKey:@"date"];
        spot.lat = [dictionary objectForKey:@"lat"];
        spot.lng = [dictionary objectForKey:@"lng"];
        spot.memo = [dictionary objectForKey:@"memo"];
        spot.phone = [dictionary objectForKey:@"phone"];
        spot.spot_description = [dictionary objectForKey:@"spot_description"];
        spot.spot_name = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"spot_name"]];
        spot.start_spot_lat = [dictionary objectForKey:@"start_spot_lat"];
        spot.start_spot_lng = [dictionary objectForKey:@"start_spot_lng"];
        spot.start_spot_name = [dictionary objectForKey:@"start_spot_name"];
        spot.traffic = [dictionary objectForKey:@"traffic"];
        spot.url = [dictionary objectForKey:@"url"];
        spot.time_line_image = [dictionary objectForKey:@"time_line_image"];
        
        // IMAGES
        NSArray *images = [dictionary objectForKey:@"images"];
        for (NSDictionary *imageDictionary in images) {
            NSString *imageFileName = [imageDictionary objectForKey:@"image_file_name"];
            
            NSData *imageData = [imageDictionary objectForKey:@"image_data"];
            
            Image* image= [Image MR_createEntity];
            
            NSString *newUUID = [[NSUUID UUID]UUIDString];
            image.image_file_name = [NSString stringWithFormat:@"%@.%@", newUUID,imageFileName.pathExtension];
            
            if ([spot.time_line_image isEqualToString:imageFileName]) {
                spot.time_line_image = image.image_file_name;
            }
            NSString *savedImagePath = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:image.image_file_name];
            [imageData writeToFile:savedImagePath atomically:NO];
            [spot addImageObject:image];
        }
        
        // VOICES
        NSArray *voices = [dictionary objectForKey:@"voices"];
        for (NSDictionary *voiceDictionary in voices) {
            
            Voice *voice  = [Voice MR_createEntity];
            NSString *newUUID = [[NSUUID UUID]UUIDString];
            voice.uuid = newUUID;
            voice.date = [voiceDictionary objectForKey:@"date"];
            voice.time = [voiceDictionary objectForKey:@"time"];
            NSData *memoVoiceData = [voiceDictionary objectForKey:@"voice_data"];
            
            NSString *savedMemoDataPath = [appDelegate.applicationDocumentsDirectoryForMemoVoice stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",voice.uuid,EXTENSION_RECORD]];
            [memoVoiceData writeToFile:savedMemoDataPath atomically:NO];
            
            [spot addVoiceObject:voice];
        }
        
        // TAGS
        NSArray *tags = [dictionary objectForKey:@"tags"];
        for (NSDictionary *tagDictionary in tags) {
            NSString *tagName = [tagDictionary objectForKey:@"tag"];
            if (!tagName) continue;
            
            Tag *tag = [Tag MR_findFirstByAttribute:@"tag" withValue:tagName];
            if (!tag)
            {
                tag = [Tag MR_createEntity];
                tag.tag = tagName;
            }
            [spot addTagObject:tag];
        }
        
        // Country
        NSString *countryName = [dictionary objectForKey:@"country"];
        Country *country = [Country MR_findFirstByAttribute:@"country" withValue:countryName];
        if (!country)
        {
            country = [Country MR_createEntity];
            country.country = countryName;
        }
        [country addSpotObject:spot];
        spot.country = country;
        
        // Region
        NSString *regionName = [dictionary objectForKey:@"region"];
        Region *region = [Region MR_findFirstByAttribute:@"region" withValue:regionName];
        if (!region)
        {
            region = [Region MR_createEntity];
            region.region = regionName;
        }
        [region addSpotObject:spot];
        spot.region = region;
        
        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [magicalContext MR_saveToPersistentStoreAndWait];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SaveAirDropFileFinish" object:nil];
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [appDelegate saveSpotToXMLForSync:spot];
        });
        
        dictionary = nil;
        
        return spot;
    }
}

- (GuideBook *)guideBookFromDictionary: (NSDictionary *)inputDictionary {
    @autoreleasepool {
        NSDictionary *dictionary = inputDictionary;
        GuideBook *guideBook = [GuideBook MR_createEntity];
        guideBook.uuid = [[NSUUID UUID] UUIDString];
        guideBook.foursquare_spot_lat = [dictionary objectForKey:@"foursquare_spot_lat"];
        guideBook.foursquare_spot_lng = [dictionary objectForKey:@"foursquare_spot_lng"];
        guideBook.foursquare_spot_name = [dictionary objectForKey:@"foursquare_spot_name"];
        guideBook.guide_book_name = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"guide_book_name"]];
        guideBook.pdf_file_name = [dictionary objectForKey:@"pdf_file_name"];
        guideBook.start_date = [dictionary objectForKey:@"start_date"];
        guideBook.start_spot_selected_from_foursquare = [dictionary objectForKey:@"start_spot_selected_from_foursquare"];
        
        NSDictionary *startSpotDictionary = [dictionary objectForKey:@"start_spot"];
        if (startSpotDictionary) {
            guideBook.start_spot = [self spotFromDictionary:startSpotDictionary];
        }
        
        NSArray *guideBookInfos = [dictionary objectForKey:@"guide_book_info"];
        
        for (NSDictionary *guideBookInfoDictionary in guideBookInfos) {
            
            GuideBookInfo *guideBookInfo = [GuideBookInfo MR_createEntity];
            guideBookInfo.info_type = [guideBookInfoDictionary objectForKey:@"info_type"];
            guideBookInfo.order = [guideBookInfoDictionary objectForKey:@"order"];
            
            switch (guideBookInfo.info_type.intValue) {
                case GuideBookInfoTypeDay:
                    guideBookInfo.day_from_start_day = [guideBookInfoDictionary objectForKey:@"day_from_start_day"];
                    break;
                case GuideBookInfoTypeMemo:
                    guideBookInfo.memo = [guideBookInfoDictionary objectForKey:@"memo"];
                    break;
                case GuideBookInfoTypeSpot:
                    guideBookInfo.spot = [self spotFromDictionary:[guideBookInfoDictionary objectForKey:@"spot"]];
                    break;
                    
            }
            
            [guideBook addGuide_book_infoObject:guideBookInfo];
        }
        
        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_contextForCurrentThread];
        // save
        [magicalContext MR_saveToPersistentStoreAndWait];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SaveAirDropFileFinish" object:nil];
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [appDelegate saveGuideBookToXMLForSync:guideBook];
        });
        
        dictionary = nil;
        
        return guideBook;
    }    
}

@end
