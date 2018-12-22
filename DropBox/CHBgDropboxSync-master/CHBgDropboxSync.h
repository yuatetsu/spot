//
//  CHBgDropboxSync.h
//  Passwords
//
//  Created by Chris Hulbert on 4/03/12.
//

#import <Foundation/Foundation.h>

/*#define LAST_SYNC_DEFAULTS_KEY @"CHBgDropboxSyncLastSyncFiles"*/
#define IMAGE_PATH @"journal_spot/image"
#define SPOT_DATA_PATH @"journal_spot/spot_data"
#define GUIDE_BOOK_DATA_PATH @"journal_spot/guide_book_data"
#define MEMO_VOICE_DATA_PATH @"journal_spot/memo_voice"

@interface CHBgDropboxSync : NSObject<DBRestClientDelegate, UIAlertViewDelegate>

+ (void)start;
+ (void)forceStopIfRunning;
+ (void)clearLastSyncData;
+ (void)deleteFileAtPath:(NSString* )filePath;
+ (void)increaseDeleteCount:(int)count;


@end

