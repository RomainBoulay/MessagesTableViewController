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

#import <Foundation/Foundation.h>

/**
 *  `WHMessageSoundEffect` is a class that encapsulates the playing of the default sound effects for sending and receiving messages in `WHMessagesViewController`. It is backed by an instance of `WHQSystemSoundPlayer`.
 */
@interface WHMessageSoundEffect : NSObject

/**
 *  Plays the default sound for received messages.
 */
+ (void)playMessageReceivedSound;

/**
 *  Plays the default sound for received messages *as an alert*, invoking device vibration if available.
 */
+ (void)playMessageReceivedAlert;

/**
 *  Plays the default sound for sent messages.
 */
+ (void)playMessageSentSound;

/**
 *  Plays the default sound for sent messages *as an alert*, invoking device vibration if available.
 */
+ (void)playMessageSentAlert;

@end