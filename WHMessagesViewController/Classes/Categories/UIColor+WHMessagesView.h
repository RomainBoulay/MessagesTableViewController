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

#import <UIKit/UIKit.h>

@interface UIColor (WHMessagesView)

#pragma mark - Colors

/**
 *  @return A color object containing the RGB values for the iOS 6 messages app background color.
 */
+ (UIColor *)backgroundColorClassic;

/**
 *  @return A color object containing the RGB values iOS 6 messages app timestamp text color.
 */
+ (UIColor *)messagesTimestampColorClassic;

#pragma mark - Bubble colors

/**
 *  @return A color object containing the HSB values iOS 7 messages app green bubble color.
 */
+ (UIColor *)bubbleGreenColor;

/**
 *  @return A color object containing the HSB values iOS 7 messages app blue bubble color.
 */
+ (UIColor *)bubbleBlueColor;

/**
 *  @return A color object containing the HSB values iOS 7 messages app light gray bubble color.
 */
+ (UIColor *)bubbleLightGrayColor;

#pragma mark - Utilities

/**
 *  Creates and returns a new color object whose brightness component is decreased by the given value, using the initial color values of the receiver.
 *
 *  @param value A floating point value describing the amount by which to decrease the brightness of the receiver.
 *
 *  @return A new color object whose brightness is decreased by the given values. The other color values remain the same as the receiver.
 */
- (UIColor *)darkenColorWithValue:(CGFloat)value;

@end