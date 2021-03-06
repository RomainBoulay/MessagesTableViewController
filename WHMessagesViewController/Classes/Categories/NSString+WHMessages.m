//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/WHMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "NSString+WHMessages.h"


@implementation NSString (WHMessages)

- (NSString *)stringByTrimingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSUInteger)numberOfLines {
    return [[self componentsSeparatedByString:@"\n"] count] + 1;
}

@end