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

#import "WHMessageSoundEffect.h"
#import <JSQSystemSoundPlayer/JSQSystemSoundPlayer.h>

static NSString * const kJSMessageReceived = @"message-received";
static NSString * const kJSMessageSent = @"message-sent";

@implementation WHMessageSoundEffect

+ (void)playMessageReceivedSound
{
    [[WHQSystemSoundPlayer sharedPlayer] playSoundWithName:kJSMessageReceived
                                                 extension:kJSQSystemSoundTypeAIFF];
}

+ (void)playMessageReceivedAlert
{
    [[WHQSystemSoundPlayer sharedPlayer] playAlertSoundWithName:kJSMessageReceived
                                                      extension:kJSQSystemSoundTypeAIFF];
}

+ (void)playMessageSentSound
{
    [[WHQSystemSoundPlayer sharedPlayer] playSoundWithName:kJSMessageSent
                                                 extension:kJSQSystemSoundTypeAIFF];
}

+ (void)playMessageSentAlert
{
    [[WHQSystemSoundPlayer sharedPlayer] playAlertSoundWithName:kJSMessageSent
                                                      extension:kJSQSystemSoundTypeAIFF];
}

@end