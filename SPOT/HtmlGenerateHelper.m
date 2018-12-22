//
//  HtmlGenerateHelper.m
//  SPOT
//
//  Created by framgia on 8/27/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "HtmlGenerateHelper.h"
#import "AppDelegate.h"
#import "Image.h"
#import "Tag.h"
#import "GuideBookInfo.h"
#import <CoreLocation/CoreLocation.h>
#import "GuideBookInfoType.h"
#import "SPOT+Traffic.h"
#import "ImageUtility.h"
#import "SPOT+Image.h"

@implementation HtmlGenerateHelper

AppDelegate* appDelegate;

+(NSString*)generateHtmlStringForSpot:(SPOT*)spot
{
    @autoreleasepool {
        NSMutableArray *htmlStringArray = [[NSMutableArray alloc] init];
        
        [htmlStringArray addObject:@"<head>"];
        [htmlStringArray addObject:@"<meta charset='utf-8'>"];
        [htmlStringArray addObject:@"<title></title>"];
        [htmlStringArray addObject:@"<link rel='stylesheet' href='./css/normalize.css'>"];
        [htmlStringArray addObject:@"<link rel='stylesheet' href='./css/style.css'>"];
        
        [htmlStringArray addObject:@"<style>"];
        
        [htmlStringArray addObject:[self generateHtmlStringForCommonStyle]];
        
        [htmlStringArray addObject:@"</style>"];
        [htmlStringArray addObject:@"</head>"];
        
        [htmlStringArray addObject:@"<body>"];
        
        NSString *spotHtmlString = [self generateHtmlStringForSingleSPOT:spot];
        [htmlStringArray addObject:spotHtmlString?spotHtmlString:@""];
        
        [htmlStringArray addObject:@"</body>"];
        
        NSString *joinedHtml = [htmlStringArray componentsJoinedByString:nil];
        return joinedHtml;
    }
}

+ (void)generateHtmlStringForSingleSPOTImages:(NSMutableArray *)htmlStringArray spot:(SPOT *)spot
{
    if (spot.image.count == 0)
    {
        if (spot.lat.doubleValue || spot.lng.doubleValue)
        {
            // spot has latitude and longitude info
            [htmlStringArray addObject:@"<div class='wrapper picture-none'>"];
            [htmlStringArray addObject:@"<div class='box'>"];
            [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='http://maps.googleapis.com/maps/api/staticmap?center=%lf,%lf&zoom=15&size=670x220&scale=1&maptype=roadmap&markers=color:red%%7Clabel:T%%7C%lf,%lf&sensor=false' width='670' height='220'>",[spot.lat doubleValue],[spot.lng doubleValue],[spot.lat doubleValue],[spot.lng doubleValue]]];
            [htmlStringArray addObject:@"</div>"];
            [htmlStringArray addObject:@"</div>"];
        }
    }
    else if (spot.image.count == 1)
    {
        if (spot.lat.doubleValue || spot.lng.doubleValue)
        {
            // spot has latitude and longitude info
            
            [htmlStringArray addObject:@"<div class='wrapper picture-1'>"];
            
            [htmlStringArray addObject:@"<table>"];
            
            [htmlStringArray addObject:@"<tr>"];
            
            [htmlStringArray addObject:@"<td style='width:221px'>"];
            
            [htmlStringArray addObject:@"<div class='box' style='overflow: hidden; width: 220px'>"];
            
            NSString* imagePath = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:[spot firstImageFileName]];
            
            UIImage *imageOrigin = [UIImage imageWithContentsOfFile:imagePath];
            
            UIImage *image = [ImageUtility centerModeImageFrom:imageOrigin withFrameWidth:220 andFrameHeight:220];
            
            imageOrigin = nil;
            
            if (image.size.width >= image.size.height) {
                [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='height: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath]]];
            }
            else {
                [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='width: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath]]];
            }
            
            [htmlStringArray addObject:@"</div>"];
            
            [htmlStringArray addObject:@"</td>"];
            
            [htmlStringArray addObject:@"<td style='width:442px'>"];
            
            [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='http://maps.googleapis.com/maps/api/staticmap?center=%lf,%lf&zoom=15&size=440x220&scale=1&maptype=roadmap&markers=color:red%%7Clabel:T%%7C%lf,%lf&sensor=false'>",[spot.lat doubleValue],[spot.lng doubleValue],[spot.lat doubleValue],[spot.lng doubleValue]]];
            
            [htmlStringArray addObject:@"</td>"];
            
            [htmlStringArray addObject:@"</tr>"];
            
            [htmlStringArray addObject:@"</table>"];
            
            [htmlStringArray addObject:@"</div>"];
            
        }
        else
        {
            [htmlStringArray addObject:@"<div class='wrapper picture-none'>"];
            [htmlStringArray addObject:@"<div class='box' style='overflow: hidden; width: 100%'>"];
            NSString* imagePath = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:[spot firstImageFileName]];
            
            UIImage *imageOrigin = [UIImage imageWithContentsOfFile:imagePath];
            
            UIImage *image = [ImageUtility centerModeImageFrom:imageOrigin withFrameWidth:670 andFrameHeight:220];
            
            imageOrigin = nil;
            
            if (image.size.width >= image.size.height) {
                [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='width: 670px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath]]];
            }
            else {
                [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='height: 220px; margin-left:auto; margin-right:auto; display:block; text-align: center'>",[NSURL fileURLWithPath:imagePath]]];
            }
            
            
            //            [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='background-image: url(%@);' width='670' height='220' border='0' class='picture' >",[NSURL fileURLWithPath:imagePath], [NSURL fileURLWithPath:imagePath]]];
            //            
            
            [htmlStringArray addObject:@"</div>"];
            [htmlStringArray addObject:@"</div>"];
        }
    }
    else if (spot.image.count > 1)
    {
        NSArray *images = [spot sortedImages];
        
        if (spot.lat.doubleValue || spot.lng.doubleValue)
        {
            [htmlStringArray addObject:@"<div class='wrapper picture-1'>"];
            
            [htmlStringArray addObject:@"<table>"];
            
            [htmlStringArray addObject:@"<tr>"];
            
            
            // picture 1
            [htmlStringArray addObject:@"<td style='width:221px'>"];
            
            [htmlStringArray addObject:@"<div class='box' style='overflow: hidden; width: 220px'>"];
            
            
            
            NSString* imagePath1 = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:[[images objectAtIndex:0] image_file_name]];
            
            UIImage *imageOrigin1 = [UIImage imageWithContentsOfFile:imagePath1];
            
            UIImage *image1 = [ImageUtility centerModeImageFrom:imageOrigin1 withFrameWidth:220 andFrameHeight:220];
            
            imageOrigin1 = nil;
            
            if (image1.size.width >= image1.size.height) {
                [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='height: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath1]]];
            }
            else {
                [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='width: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath1]]];
            }
            
            [htmlStringArray addObject:@"</div>"];
            
            [htmlStringArray addObject:@"</td>"];
            
            // picture 2
            
            [htmlStringArray addObject:@"<td style='width:221px'>"];
            
            [htmlStringArray addObject:@"<div class='box' style='overflow: hidden; width: 220px'>"];
            
            NSString* imagePath2 = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:[[images objectAtIndex:1] image_file_name]];
            
            UIImage *imageOrigin2 = [UIImage imageWithContentsOfFile:imagePath2];
            
            UIImage *image2 = [ImageUtility centerModeImageFrom:imageOrigin2 withFrameWidth:220 andFrameHeight:220];
            
            imageOrigin2 = nil;
            
            if (image2.size.width >= image2.size.height) {
                [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='height: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath2]]];
            }
            else {
                [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='width: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath2]]];
            }
            
            [htmlStringArray addObject:@"</div>"];
            
            [htmlStringArray addObject:@"</td>"];
            
            // map
            
            [htmlStringArray addObject:@"<td style='width:221px'>"];
            
            [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='http://maps.googleapis.com/maps/api/staticmap?center=%lf,%lf&zoom=15&size=220x220&scale=1&maptype=roadmap&markers=color:red%%7Clabel:T%%7C%lf,%lf&sensor=false'>",[spot.lat doubleValue],[spot.lng doubleValue],[spot.lat doubleValue],[spot.lng doubleValue]]];
            
            [htmlStringArray addObject:@"</td>"];
            
            [htmlStringArray addObject:@"</tr>"];
            
            [htmlStringArray addObject:@"</table>"];
            
            [htmlStringArray addObject:@"</div>"];
        }
        
        else
        {
            if (spot.image.count == 2) {
                [htmlStringArray addObject:@"<div class='wrapper picture-1'>"];
                
                [htmlStringArray addObject:@"<table>"];
                
                [htmlStringArray addObject:@"<tr>"];
                
                
                // picture 1
                [htmlStringArray addObject:@"<td style='width:auto'>"];
                
                [htmlStringArray addObject:@"<div class='box' style='overflow: hidden; width: 330px; height: 220px'>"];
                
                NSString* imagePath1 = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:[[images objectAtIndex:0] image_file_name]];
                
                UIImage *imageOrigin1 = [UIImage imageWithContentsOfFile:imagePath1];
                
                UIImage *image1 = [ImageUtility centerModeImageFrom:imageOrigin1 withFrameWidth:330 andFrameHeight:220];
                
                imageOrigin1 = nil;
                
                if (image1.size.width >= image1.size.height) {
                    [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='height: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath1]]];
                }
                else {
                    [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='width: 330px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath1]]];
                }
                
                [htmlStringArray addObject:@"</div>"];
                
                [htmlStringArray addObject:@"</td>"];
                
                // picture 2
                
                [htmlStringArray addObject:@"<td style='width:auto'>"];
                
                [htmlStringArray addObject:@"<div class='box' style='overflow: hidden; width: 330px'>"];
                
                NSString* imagePath2 = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:[[images objectAtIndex:1] image_file_name]];
                
                UIImage *imageOrigin2 = [UIImage imageWithContentsOfFile:imagePath2];
                
                UIImage *image2 = [ImageUtility centerModeImageFrom:imageOrigin2 withFrameWidth:330 andFrameHeight:220];
                
                imageOrigin2 = nil;
                
                if (image2.size.width >= image2.size.height) {
                    [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='height: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath2]]];
                }
                else {
                    [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='width: 330px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath2]]];
                }
                
                [htmlStringArray addObject:@"</div>"];
                
                [htmlStringArray addObject:@"</td>"];
                
                [htmlStringArray addObject:@"</tr>"];
                
                [htmlStringArray addObject:@"</table>"];
                
                [htmlStringArray addObject:@"</div>"];
            }
            else {
                [htmlStringArray addObject:@"<div class='wrapper picture-1'>"];
                
                [htmlStringArray addObject:@"<table>"];
                
                [htmlStringArray addObject:@"<tr>"];
                
                
                // picture 1
                [htmlStringArray addObject:@"<td style='width:auto'>"];
                
                [htmlStringArray addObject:@"<div class='box' style='overflow: hidden; width: 220px; height: 220px'>"];
                
                NSString* imagePath1 = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:[[images objectAtIndex:0] image_file_name]];
                
                UIImage *imageOrigin1 = [UIImage imageWithContentsOfFile:imagePath1];
                
                UIImage *image1 = [ImageUtility centerModeImageFrom:imageOrigin1 withFrameWidth:220 andFrameHeight:220];
                
                imageOrigin1 = nil;
                
                if (image1.size.width >= image1.size.height) {
                    [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='height: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath1]]];
                }
                else {
                    [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='width: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath1]]];
                }
                
                [htmlStringArray addObject:@"</div>"];
                
                [htmlStringArray addObject:@"</td>"];
                
                // picture 2
                
                [htmlStringArray addObject:@"<td style='width:auto'>"];
                
                [htmlStringArray addObject:@"<div class='box' style='overflow: hidden; width: 220px'>"];
                
                NSString* imagePath2 = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:[[images objectAtIndex:1] image_file_name]];
                
                UIImage *imageOrigin2 = [UIImage imageWithContentsOfFile:imagePath2];
                
                UIImage *image2 = [ImageUtility centerModeImageFrom:imageOrigin2 withFrameWidth:220 andFrameHeight:220];
                
                imageOrigin2 = nil;
                
                if (image2.size.width >= image2.size.height) {
                    [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='height: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath2]]];
                }
                else {
                    [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='width: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath2]]];
                }
                
                [htmlStringArray addObject:@"</div>"];
                
                [htmlStringArray addObject:@"</td>"];
                
                
                // picture 3
                
                [htmlStringArray addObject:@"<td style='width:auto'>"];
                
                [htmlStringArray addObject:@"<div class='box' style='overflow: hidden; width: 220px'>"];
                
                NSString* imagePath3 = [[appDelegate applicationDocumentsDirectoryForImage] stringByAppendingPathComponent:[[images objectAtIndex:2] image_file_name]];
                
                UIImage *imageOrigin3 = [UIImage imageWithContentsOfFile:imagePath3];
                
                UIImage *image3 = [ImageUtility centerModeImageFrom:imageOrigin3 withFrameWidth:220 andFrameHeight:220];
                
                imageOrigin3 = nil;
                
                if (image3.size.width >= image3.size.height) {
                    [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='height: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath3]]];
                }
                else {
                    [htmlStringArray addObject:[NSString stringWithFormat:@"<img src='%@' style='width: 220px; margin-left:auto; margin-right:auto'>",[NSURL fileURLWithPath:imagePath3]]];
                }
                
                [htmlStringArray addObject:@"</div>"];
                
                [htmlStringArray addObject:@"</td>"];
                
                
                
                [htmlStringArray addObject:@"</tr>"];
                
                [htmlStringArray addObject:@"</table>"];
                
                [htmlStringArray addObject:@"</div>"];
            }
            
            
        }
    }
}

+(NSString*)generateHtmlStringForSingleSPOT:(SPOT*)spot
{
    NSMutableArray *htmlStringArray = [[NSMutableArray alloc] init];
    [htmlStringArray addObject:@"<div id='content' style='min-height:1000px !important;'>"];
    [htmlStringArray addObject:@"<div class='variable'>"];
    
    [htmlStringArray addObject:@"<h1>"];
    if (spot.spot_name) [htmlStringArray addObject:spot.spot_name];
    [htmlStringArray addObject:@"</h1>"];
    
    [self generateHtmlStringForSingleSPOTImages:htmlStringArray spot:spot];
    
    [htmlStringArray addObject:@"<div class='spot_info'>"];
    [htmlStringArray addObject:@"<div class='spot_info_top'>"];
    [htmlStringArray addObject:@"<p class='spot_info_address'>"];
    [htmlStringArray addObject:@"Address : "];
    if (spot.address) [htmlStringArray addObject:spot.address];
    [htmlStringArray addObject:@"</p>"];
    [htmlStringArray addObject:@"<div class='wrapper'>"];
    [htmlStringArray addObject:@"<p class='spot_info_tel'>"];
    [htmlStringArray addObject:@"TEL : "];
    if (spot.phone) [htmlStringArray addObject:spot.phone];
    [htmlStringArray addObject:@"</p>"];
    
    [htmlStringArray addObject:@"<div class='spot_info_traffic' style='width:280px !important'>"];
    
    NSString *traffic_icon;
    switch (spot.traffic.intValue) {
        case 1:
            traffic_icon = @"icon_traffic_04";
            break;
        case 2:
            traffic_icon = @"icon_traffic_02";
            break;
        case 3:
            traffic_icon = @"icon_traffic_03";
            break;
        case 4:
            traffic_icon = @"icon_traffic_01";
            break;
        case 5:
            traffic_icon = @"icon_traffic_05";
            break;
        default:
            break;
    }
    
    [htmlStringArray addObject:[NSString stringWithFormat:@"<span>Traffic: %@</span>",spot.trafficText]];
    if (spot.traffic.intValue) {
        [htmlStringArray addObject:[NSString stringWithFormat:@"<img height='10' style='margin-top: 5px; margin-right:10px; float: right' src='./images/%@.png'/>", traffic_icon]];
    }
    
    [htmlStringArray addObject:@"</div>"];
    
    [htmlStringArray addObject:@"</div>"];  // div wrapper
    [htmlStringArray addObject:@"<div class='spot_info_memo'>"];
    if (spot.memo)
        [htmlStringArray addObject:[StringHelpers htmlString:spot.memo] ];
    [htmlStringArray addObject:@"</div>"];
    [htmlStringArray addObject:@"</div>"]; // div spot_info_top
    [htmlStringArray addObject:@"<div class='wrapper spot_info_bottom'>"];
    [htmlStringArray addObject:@"<p class='spot_info_url'>"];
    [htmlStringArray addObject:@"URL : "];
    if (spot.url) [htmlStringArray addObject:spot.url];
    [htmlStringArray addObject:@"</p>"];
    [htmlStringArray addObject:@"<p class='spot_info_tag'>"];
    [htmlStringArray addObject:@"Tags : "];
    NSString *tagStringConcat = @"";
    for (int i=0; i<spot.tag.count; i++)
    {
        Tag *tag = [spot.tag.allObjects objectAtIndex:i];
        tagStringConcat = [tagStringConcat stringByAppendingFormat:(i==spot.tag.count-1)?@"%@":@"%@, ",tag.tag];
        
    }
    [htmlStringArray addObject:tagStringConcat];
    [htmlStringArray addObject:@"</p>"];
    [htmlStringArray addObject:@"</div>"];  // div class='wrapper spot_info_bottom'
    
    [htmlStringArray addObject:@"</div>"];  // div spot_info
    
    [htmlStringArray addObject:@"</div>"];  // div variable
    [htmlStringArray addObject:@"<div class='copyright'>"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    [htmlStringArray addObject:[formatter stringFromDate:[NSDate date]]];
    [htmlStringArray addObject:@"- Created by SPOT"];
    [htmlStringArray addObject:@"</div>"]; // div copyright
    [htmlStringArray addObject:@"</div>"]; // div content
    
    NSString *joinedHtml = [htmlStringArray componentsJoinedByString:nil];
    return joinedHtml;
}

+(NSString*)generateHtmlStringForGuideBook:(GuideBook *)guideBook
{
    @autoreleasepool {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(guide_book = %@)", guideBook.objectID];
        NSArray *guideBookInfoArray = [GuideBookInfo MR_findAllSortedBy:@"order" ascending:YES withPredicate:predicate];
        
        NSMutableArray *guideBookInfoMutableArray = [NSMutableArray arrayWithArray:guideBookInfoArray];
        
        NSMutableArray *htmlStringArray = [[NSMutableArray alloc] init];
        
        
        [htmlStringArray addObject:@"<head>"];
        [htmlStringArray addObject:@"<meta charset='utf-8'>"];
        [htmlStringArray addObject:@"<title></title>"];
        [htmlStringArray addObject:@"<link rel='stylesheet' href='./css/normalize.css'>"];
        [htmlStringArray addObject:@"<link rel='stylesheet' href='./css/style.css'>"];
        
        [htmlStringArray addObject:@"<style>"];
        
        [htmlStringArray addObject:@"@media print {"];
        [htmlStringArray addObject:@".pagebreak-before:first-child{display: block; page-break-before: avoid; }"];
        [htmlStringArray addObject:@".pagebreak-before { display: block; page-break-before: always; }"];
        [htmlStringArray addObject:@"}"];
        
        [htmlStringArray addObject:[self generateHtmlStringForCommonStyle]];
        
        [htmlStringArray addObject:@"</style>"];
        [htmlStringArray addObject:@"</head>"];
        
        [htmlStringArray addObject:@"<body>"];
        [htmlStringArray addObject:@"<div id='content' class='guidebook' style='min-height:1000px !important;'>"];
        
        NSString *guideBookNameAndStartDateSectionHtmlString = [self generateHtmlStringForGuideBookNameAndStartDate:guideBook];
        [htmlStringArray addObject:guideBookNameAndStartDateSectionHtmlString?guideBookNameAndStartDateSectionHtmlString:@""];
        
        if ((guideBook.start_spot || guideBook.start_spot_selected_from_foursquare)) {
            
            if (guideBookInfoMutableArray.count > 0) {
                GuideBookInfo *info = [guideBookInfoMutableArray objectAtIndex:0];
                
                if (info.info_type.intValue == GuideBookInfoTypeDay) {
                    NSString *guideBookInfoHtmlString = [self generateHtmlStringForGuideBookInfo:info ofGuideBook:guideBook];
                    [htmlStringArray addObject:guideBookInfoHtmlString?guideBookInfoHtmlString:@""];
                    
                    [guideBookInfoMutableArray removeObjectAtIndex:0];
                }
            }
        }
        
        if (guideBook.start_spot) {
            NSString *startSpotHtmlString = [self generateHtmlStringForGuideBookInfoSpot:guideBook.start_spot ofGuideBook:guideBook];
            [htmlStringArray addObject:startSpotHtmlString?startSpotHtmlString:@""];
            
        }
        else if (guideBook.start_spot_selected_from_foursquare) {
            [htmlStringArray addObject:@"<div class='guide_item'>"];
            [htmlStringArray addObject:@"<div style='margin-top:5px'>"];
            [htmlStringArray addObject:@"<img width='14' height='19' style='' src='./images/icon_foursquare.png'/>"];
            [htmlStringArray addObject:[NSString stringWithFormat:@"<span style='margin-left: 10px'>%@</span>", guideBook.foursquare_spot_name]];
            [htmlStringArray addObject:@"</div>"];
            [htmlStringArray addObject:@"</div>"];
        }
        
        
        [htmlStringArray addObject:@"<div class='variable' style='min-height:900px !important'>"];
        for (GuideBookInfo *guideBookInfo in guideBookInfoMutableArray)
        {
            NSString *guideBookInfoHtmlString = [self generateHtmlStringForGuideBookInfo:guideBookInfo ofGuideBook:guideBook];
            [htmlStringArray addObject:guideBookInfoHtmlString?guideBookInfoHtmlString:@""];
        }
        
        [htmlStringArray addObject:@"<div class='copyright'>"];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        [htmlStringArray addObject:[formatter stringFromDate:[NSDate date]]];
        [htmlStringArray addObject:@"- Created by SPOT"];
        [htmlStringArray addObject:@"</div>"];
        
        [htmlStringArray addObject:@"</div>"];
        
        [htmlStringArray addObject:@"</div>"];
        [htmlStringArray addObject:@"</body>"];
        NSString *joinedHtml = [htmlStringArray componentsJoinedByString:nil];
        return joinedHtml;
    }
    
}

+(NSString*)generateHtmlStringForCommonStyle
{
    
    NSMutableArray *htmlStringArray = [[NSMutableArray alloc] init];
    /*
    [htmlStringArray addObject:@"div{"];
    [htmlStringArray addObject:@"width: 240px;"];
    [htmlStringArray addObject:@"height: 140px;"];
    [htmlStringArray addObject:@"overflow: hidden;"];
    [htmlStringArray addObject:@"margin: 10px;"];
    [htmlStringArray addObject:@"position: relative;"];
    [htmlStringArray addObject:@"}"];
    
    [htmlStringArray addObject:@".crop {"];
    [htmlStringArray addObject:@"position:absolute;"];
    [htmlStringArray addObject:@"left: -100%;"];
    [htmlStringArray addObject:@"right: -100%;"];
    [htmlStringArray addObject:@"top: -100%;"];
    [htmlStringArray addObject:@"bottom: -100%;"];
    [htmlStringArray addObject:@"margin: auto;"];
    [htmlStringArray addObject:@"max-height: auto;"];
    [htmlStringArray addObject:@"max-width: 100%"];
    [htmlStringArray addObject:@"}"];
    */
    
    
    NSString *joinedHtml = [htmlStringArray componentsJoinedByString:nil];
    return joinedHtml;
}
+(NSString*)generateHtmlStringForGuideBookNameAndStartDate:(GuideBook*)guideBook
{
    NSMutableArray *htmlStringArray = [[NSMutableArray alloc] init];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    [htmlStringArray addObject:@"<div class='head_wrapper'>"];
    [htmlStringArray addObject:@"<table>"];
    [htmlStringArray addObject:@"<tr>"];
    [htmlStringArray addObject:@"<td style='width: 88%'>"];
    [htmlStringArray addObject:[NSString stringWithFormat:@"<h1>%@</h1>",guideBook.guide_book_name?guideBook.guide_book_name:@""]];
    [htmlStringArray addObject:@"</td>"];
    
    [htmlStringArray addObject:@"<td style='width: 12%'>"];
    [htmlStringArray addObject:@"<p class='date'>"];
    [htmlStringArray addObject:guideBook.start_date?[formatter stringFromDate:guideBook.start_date]:@""];
    [htmlStringArray addObject:@"</p>"];
    [htmlStringArray addObject:@"</td>"];
    [htmlStringArray addObject:@"</tr>"];
    [htmlStringArray addObject:@"</table>"];
    
    [htmlStringArray addObject:@"</div>"];
    
    NSString *joinedHtml = [htmlStringArray componentsJoinedByString:nil];
    return joinedHtml;
}

+(NSString*)generateHtmlStringForGuideBookInfo:(GuideBookInfo *)guideBookInfo ofGuideBook:(GuideBook*)guideBook
{
    if (guideBookInfo.info_type.intValue == GuideBookInfoTypeDay)
    {
        //day
        // it's not required to pass the guideBook parameter here
        return [self generateHtmlStringForGuideBookInfoDay:guideBookInfo ofGuideBook:nil];
    }
    else if (guideBookInfo.info_type.intValue == GuideBookInfoTypeSpot)
    {
        //spot
        return [self generateHtmlStringForGuideBookInfoSpot:guideBookInfo.spot ofGuideBook:guideBook];
    }
    else
    {
        //memo
        // it's not required to pass the guideBook parameter here
        return [self generateHtmlStringForGuideBookInfoMemo:guideBookInfo ofGuideBook:nil];
    }
}

+(NSString*)generateHtmlStringForGuideBookInfoDay:(GuideBookInfo*)guideBookInfoDay ofGuideBook:(GuideBook*)guideBook
{
    NSMutableArray *htmlStringArray = [[NSMutableArray alloc] init];
    
    if (guideBookInfoDay.day_from_start_day.intValue > 1)
    {
//        [htmlStringArray addObject:@"<h1 class='pagebreak-before'></h1>"];
        
        
        [htmlStringArray addObject:@"<div class='date_title'>"];
        [htmlStringArray addObject:@"<h2>"];
        [htmlStringArray addObject:[NSString stringWithFormat:@"day %d", guideBookInfoDay.day_from_start_day.intValue]];
        [htmlStringArray addObject:@"</h2>"];
        [htmlStringArray addObject:@"</div>"];
    }
    else
    {
        [htmlStringArray addObject:@"<div class='date_title'>"];
        [htmlStringArray addObject:@"<h2>"];
        [htmlStringArray addObject:[NSString stringWithFormat:@" day %d ", guideBookInfoDay.day_from_start_day.intValue]];
        [htmlStringArray addObject:@"<span>"];
        if (guideBook.start_spot_selected_from_foursquare.boolValue)
        {
            if (guideBook.foursquare_spot_name) [htmlStringArray addObject:guideBook.foursquare_spot_name];
        }
        else
        {
            if (guideBook.start_spot.spot_name) [htmlStringArray addObject:guideBook.start_spot.spot_name];
        }
        [htmlStringArray addObject:@"</span>"];
        [htmlStringArray addObject:@"</h2>"];
        [htmlStringArray addObject:@"</div>"];
    }
    NSString *joinedHtml = [htmlStringArray componentsJoinedByString:nil];
    return joinedHtml;
}

+(NSString*)generateHtmlStringForGuideBookInfoSpot:(SPOT*)spot ofGuideBook:(GuideBook*)guideBook
{
    NSMutableArray *htmlStringArray = [[NSMutableArray alloc] init];
    [htmlStringArray addObject:@"<div class='guide_item'>"];
    
    [HtmlGenerateHelper generateHtmlStringForSingleSPOTImages:htmlStringArray spot:spot];
    
    [htmlStringArray addObject:@"<div class='spot_info'>"];
    [htmlStringArray addObject:@"<div class='spot_info_top'>"];
    [htmlStringArray addObject:@"<p class='spot_info_spotname'>"];
    [htmlStringArray addObject:spot.spot_name];
    [htmlStringArray addObject:@"</p>"];
    [htmlStringArray addObject:@"<p class='spot_info_address'>"];
    [htmlStringArray addObject:@"Address : "];
    if (spot.address) [htmlStringArray addObject:spot.address];
    [htmlStringArray addObject:@"</p>"];
    [htmlStringArray addObject:@"<div class='wrapper'>"];
    [htmlStringArray addObject:@"<p class='spot_info_tel'>"];
    [htmlStringArray addObject:@"TEL : "];
    if (spot.phone) [htmlStringArray addObject:spot.phone];
    [htmlStringArray addObject:@"</p>"];
    [htmlStringArray addObject:@"<p class='spot_info_url'>"];
    [htmlStringArray addObject:@"URL : "];
    if (spot.url) [htmlStringArray addObject:spot.url];
    [htmlStringArray addObject:@"</p>"];
    [htmlStringArray addObject:@"</div>"];
    
    [htmlStringArray addObject:@"<div class='spot_info_memo'>"];
    if (spot.memo) [htmlStringArray addObject:[StringHelpers htmlString:spot.memo]];
    [htmlStringArray addObject:@"</div>"];
    
    [htmlStringArray addObject:@"<div class='spot_info_traffic' style='width: 620px'>"];

    
    NSString *traffic_icon;
    switch (spot.traffic.intValue) {
        case 1:
            traffic_icon = @"icon_traffic_04";
            break;
        case 2:
            traffic_icon = @"icon_traffic_02";
            break;
        case 3:
            traffic_icon = @"icon_traffic_03";
            break;
        case 4:
            traffic_icon = @"icon_traffic_01";
            break;
        case 5:
            traffic_icon = @"icon_traffic_05";
            break;
        default:
            break;
    }
    
    [htmlStringArray addObject:[NSString stringWithFormat:@"<span>Traffic: %@</span>",spot.trafficText]];
    if (spot.traffic.intValue) {
        [htmlStringArray addObject:[NSString stringWithFormat:@"<img height='10' style='margin-top: 5px; margin-right: 10px; float: right' src='./images/%@.png'/>", traffic_icon]];
    }
    
    [htmlStringArray addObject:@"</div>"]; //spot_info_traffic
    
    [htmlStringArray addObject:@"</div>"];
    [htmlStringArray addObject:@"</div>"];
    [htmlStringArray addObject:@"</div>"];
    
    NSString *joinedHtml = [htmlStringArray componentsJoinedByString:nil];
    return joinedHtml;
}

+(NSString*)generateHtmlStringForGuideBookInfoMemo:(GuideBookInfo*)guideBookInfoMemo ofGuideBook:(GuideBook*)guideBook
{
    NSMutableArray *htmlStringArray = [[NSMutableArray alloc] init];
    [htmlStringArray addObject:@"<div class='guide_memo'>"];
    [htmlStringArray addObject:[StringHelpers htmlString:guideBookInfoMemo.memo]];
    [htmlStringArray addObject:@"</div>"];
    
    NSString *joinedHtml = [htmlStringArray componentsJoinedByString:nil];
    return joinedHtml;
}

@end
