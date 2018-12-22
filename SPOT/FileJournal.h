//
//  FileJournal.h
//  SPOT
//
//  Created by framgia on 9/1/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FileJournal : NSManagedObject

@property (nonatomic, retain) NSString *file_name;
@property (nonatomic, retain) NSDate *last_modified_dropbox;
@property (nonatomic, retain) NSDate *last_modified_local;

@end
