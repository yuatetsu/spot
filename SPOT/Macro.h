//
//  Macro.h
//  SPOT
//
//  Created by nguyen hai dang on 9/8/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#ifndef SPOT_Macro_h
#define SPOT_Macro_h

// Singleton

#ifndef MU_SINGLETON_INTERFACE_PATTERN
#   define MU_SINGLETON_INTERFACE_PATTERN(class_name) \
+ (class_name *) shared;\
+ (BOOL) isInitialize;
#endif

#ifndef MU_SINGLETON_IMPLEMENTATION_PATTERN
#   define MU_SINGLETON_IMPLEMENTATION_PATTERN(class_name) \
static class_name *_instance = nil;\
static BOOL _isInitialize;\
+ (class_name *) shared\
{\
@synchronized([class_name class])\
{\
if (!_instance)\
{\
_instance = [[self alloc] init];\
_isInitialize = TRUE;\
}\
\
return _instance;\
}\
\
return nil;\
}\
+ (id) alloc\
{\
@synchronized([class_name class])\
{\
NSAssert(_instance == nil, @"Attempted to allocate a second instance of a singleton.");\
_instance = [super alloc];\
return _instance;\
}\
return nil;\
}\
+ (BOOL)isInitialize{\
return _isInitialize;\
}
#endif



//CHBgDropbox

#ifndef FILE_PATH_DELETE_DROPBOX_KEY
#define FILE_PATH_DELETE_DROPBOX_KEY @"file_path_dropbox_delete"
#endif

#ifndef API_KEY
#define API_KEY @"w2izvm9wnqp2h0z"
#endif

#ifndef API_SECRET
#define API_SECRET @"8g6jv0e2f61l23e"
#endif
//


//iCloud

#ifndef LAST_SYNC_DEFAULTS_KEY
#define LAST_SYNC_DEFAULTS_KEY @"iCLoudSyncLastSyncFiles"
#endif

#ifndef IMAGE_PATH
#define IMAGE_PATH @"journal_spot/image"
#endif

#ifndef SPOT_DATA_PATH
#define SPOT_DATA_PATH @"journal_spot/spot_data"
#endif

#ifndef GUIDE_BOOK_DATA_PATH
#define GUIDE_BOOK_DATA_PATH @"journal_spot/guide_book_data"
#endif

#ifndef MEMO_VOICE_DATA_PATH
#define MEMO_VOICE_DATA_PATH @"journal_spot/memo_voice"
#endif


// Font

#ifndef FONT_NORMAL_SIZE
#define FONT_NORMAL_SIZE 16.0
#endif

#ifndef FONT_SMALL_SIZE
#define FONT_SMALL_SIZE 14.0
#endif

#ifndef FONT_MINI_SIZE
#define FONT_MINI_SIZE 12.0
#endif

#ifndef FONT_MICRO_SIZE
#define FONT_MICRO_SIZE 10.0
#endif

#ifndef FONT_LARGE_SIZE
#define FONT_LARGE_SIZE 19.0
#endif

#ifndef FONT_NAME
#define FONT_NAME @"Molengo"
#endif

// Color

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


// Recorder

#ifndef EXTENSION_RECORD
#define EXTENSION_RECORD @"caf"
#endif

#ifndef FINISH_RECORD_NOTIFICATION
#define FINISH_RECORD_NOTIFICATION @"FinishRecord"
#endif

#ifndef RECORD_FAILED_NOTIFICATION
#define RECORD_FAILED_NOTIFICATION @"RecordFailed"
#endif

// System version

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// Device

//#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
//#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
//#define IS_IPHONE_6PLUS (IS_IPHONE && [[UIScreen mainScreen] nativeScale] == 3.0f)
//#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
//#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))
#define IS_STANDARD_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)
#define IS_ZOOMED_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)
#define IS_STANDARD_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_ZOOMED_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 375.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)

// GoogleAdmod

#ifndef AD_UNIT_SMALL
#define AD_UNIT_SMALL @"ca-app-pub-8511482805250174/9853648819"
#endif

#ifndef AD_UNIT_MEDIUM
#define AD_UNIT_MEDIUM @"ca-app-pub-8511482805250174/5680801210"
#endif

// Google search
#ifndef GOOGLE_API_BROWSER_KEY
#define GOOGLE_API_BROWSER_KEY @"AIzaSyCOhZ6zpFR-0MnVUtRz8mwIAbfVXttyxx4"
#endif

// Google map
#ifndef GOOGLE_MAP_SERVICE_KEY
#define GOOGLE_MAP_SERVICE_KEY @"AIzaSyCOhZ6zpFR-0MnVUtRz8mwIAbfVXttyxx4"
#endif


// Ads heights
#ifndef MEDIUM_ADS_HEIGHT
#define MEDIUM_ADS_HEIGHT 250.0
#endif
#ifndef ADS_MARGIN_HEIGHT
#define ADS_MARGIN_HEIGHT 20.0
#endif
#ifndef SMALL_ADS_HEIGHT
#define SMALL_ADS_HEIGHT 50.0
#endif


#endif
