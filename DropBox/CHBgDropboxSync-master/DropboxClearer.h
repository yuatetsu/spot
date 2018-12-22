//
//  DropboxClearer.h
//  Passwords
//
//  Created by Chris on 10/03/12.
//

#import <Foundation/Foundation.h>


typedef void(^dropboxCleared)(BOOL success);

@interface DropboxClearer : NSObject<DBRestClientDelegate>

+ (void)doClear:(dropboxCleared)complete;

@end
