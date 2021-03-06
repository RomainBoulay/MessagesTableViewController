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


@interface NSString (WHMessages)

/**
 *  Returns a copy of the receiver with all whitespaced removed from the front and back.
 *
 *  @return A copied string with all leading and trailing whitespace removed.
 */
- (NSString *)stringByTrimingWhitespace;

/**
 *  Returns the number of lines in the receiver by counting the number of occurences of the newline character, `\n`.
 *
 *  @return An unsigned integer describing the number of lines in the string.
 */
- (NSUInteger)numberOfLines;

@end