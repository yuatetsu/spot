//
//  StringHelpers.m
//  SPOT
//
//  Created by Truong Anh Tuan on 8/26/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "StringHelpers.h"
#import "MMMarkdown.h"

@implementation StringHelpers

+ (NSString *)stringByTrimmingWhitespace:(NSString *)str {
    if (str) {
        return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return @"";
    
}

+ (NSString *)stringByRemovingAllWhitespace:(NSString *)str {
    if (str) {
        return [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return @"";
}

+ (BOOL)isNilOrWhitespace:(NSString *)str {
    if (!str || [StringHelpers stringByTrimmingWhitespace:str].length == 0) {
        return YES;
    }
    return NO;
}

+ (NSString *)htmlString:(NSString *)str {
    if (str) {
//        NSError *error;
        return [MMMarkdown HTMLStringWithMarkdown:str extensions:MMMarkdownExtensionsGitHubFlavored error:NULL];
//        NSString *result = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
//        NSLog(@"HTML string:  %@", result);
//        return result;
    }
    return @"";
}

+ (NSString *)validFileNameFromString: (NSString *)str {
    if (!str) {
        return nil;
    }
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    str = [[str componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    return [StringHelpers isNilOrWhitespace:str] ? nil : str;
}
@end
