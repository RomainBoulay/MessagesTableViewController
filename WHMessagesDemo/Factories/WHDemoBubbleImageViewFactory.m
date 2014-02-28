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

#import "WHDemoBubbleImageViewFactory.h"
#import "UIImage+WHMessagesView.h"
#import "UIColor+WHMessagesView.h"

static NSDictionary *bubbleImageDictionary;

@interface WHDemoBubbleImageViewFactory()

+ (UIImageView *)classicBubbleImageViewForStyle:(WHBubbleImageViewStyle)style
                                     isOutgoing:(BOOL)isOutgoing;

+ (UIImage *)classicHighlightedBubbleImageForStyle:(WHBubbleImageViewStyle)style;

+ (UIEdgeInsets)classicBubbleImageCapInsetsForStyle:(WHBubbleImageViewStyle)style
                                         isOutgoing:(BOOL)isOutgoing;

@end



@implementation WHDemoBubbleImageViewFactory

#pragma mark - Initialization

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bubbleImageDictionary = @{@(WHBubbleImageViewStyleClassicGray): @"bubble-classic-gray",
                                 @(WHBubbleImageViewStyleClassicBlue): @"bubble-classic-blue",
                                 @(WHBubbleImageViewStyleClassicGreen): @"bubble-classic-green",
                                 @(WHBubbleImageViewStyleClassicSquareGray): @"bubble-classic-square-gray",
                                 @(WHBubbleImageViewStyleClassicSquareBlue): @"bubble-classic-square-blue"};
    });
}

#pragma mark - Public

+ (UIImageView *)bubbleImageViewForType:(WHBubbleMessageType)type
                                  color:(UIColor *)color
{
    UIImage *bubble = [UIImage imageNamed:@"bubble-min"];
    
    UIImage *normalBubble = [bubble imageMaskWithColor:color];
    UIImage *highlightedBubble = [bubble imageMaskWithColor:[color darkenColorWithValue:0.12f]];
    
    if (type == WHBubbleMessageTypeIncoming) {
        normalBubble = [normalBubble imageFlippedHorizontal];
        highlightedBubble = [highlightedBubble imageFlippedHorizontal];
    }
    
    // make image stretchable from center point
    CGPoint center = CGPointMake(bubble.size.width / 2.0f, bubble.size.height / 2.0f);
    UIEdgeInsets capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
    
    return [[UIImageView alloc] initWithImage:[normalBubble stretchableImageWithCapInsets:capInsets]
                             highlightedImage:[highlightedBubble stretchableImageWithCapInsets:capInsets]];
}

+ (UIImageView *)classicBubbleImageViewForType:(WHBubbleMessageType)type
                                         style:(WHBubbleImageViewStyle)style
{
    return [WHDemoBubbleImageViewFactory classicBubbleImageViewForStyle:style
                                                  isOutgoing:type == WHBubbleMessageTypeOutgoing];
}

#pragma mark - Private

+ (UIImageView *)classicBubbleImageViewForStyle:(WHBubbleImageViewStyle)style
                                     isOutgoing:(BOOL)isOutgoing
{
    UIImage *image = [UIImage imageNamed:bubbleImageDictionary[@(style)]];
    UIImage *highlightedImage = [WHDemoBubbleImageViewFactory classicHighlightedBubbleImageForStyle:style];
    
    if (!isOutgoing) {
        image = [image imageFlippedHorizontal];
        highlightedImage = [highlightedImage imageFlippedHorizontal];
    }
    
    UIEdgeInsets capInsets = [WHDemoBubbleImageViewFactory classicBubbleImageCapInsetsForStyle:style
                                                                                isOutgoing:isOutgoing];
    
    return [[UIImageView alloc] initWithImage:[image stretchableImageWithCapInsets:capInsets]
                             highlightedImage:[highlightedImage stretchableImageWithCapInsets:capInsets]];
}

+ (UIImage *)classicHighlightedBubbleImageForStyle:(WHBubbleImageViewStyle)style
{
    switch (style) {
        case WHBubbleImageViewStyleClassicGray:
        case WHBubbleImageViewStyleClassicBlue:
        case WHBubbleImageViewStyleClassicGreen:
            return [UIImage imageNamed:@"bubble-classic-selected"];
            
        case WHBubbleImageViewStyleClassicSquareGray:
        case WHBubbleImageViewStyleClassicSquareBlue:
            return [UIImage imageNamed:@"bubble-classic-square-selected"];
            
        default:
            return nil;
    }
}

+ (UIEdgeInsets)classicBubbleImageCapInsetsForStyle:(WHBubbleImageViewStyle)style
                                         isOutgoing:(BOOL)isOutgoing
{
    switch (style) {
        case WHBubbleImageViewStyleClassicGray:
        case WHBubbleImageViewStyleClassicBlue:
        case WHBubbleImageViewStyleClassicGreen:
            return UIEdgeInsetsMake(15.0f, 20.0f, 15.0f, 20.0f);
            
        case WHBubbleImageViewStyleClassicSquareGray:
        case WHBubbleImageViewStyleClassicSquareBlue:
            return isOutgoing ? UIEdgeInsetsMake(15.0f, 18.0f, 16.0f, 23.0f) : UIEdgeInsetsMake(15.0f, 25.0f, 16.0f, 23.0f);
            
        default:
            return UIEdgeInsetsZero;
    }
}

@end
