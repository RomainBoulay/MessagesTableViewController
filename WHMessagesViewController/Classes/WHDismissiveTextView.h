//
//  Taken from MADismissiveTextView
//  https://github.com/mikeahmarani/MADismissiveTextView
//
//  Created by Mike Ahmarani on 12-02-18.
//  Copyright (c) 2012 Mike Ahmarani. All rights reserved.
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

/**
 *  The delegate of a `WHDismissiveTextView` object must adopt the `WHDismissiveTextViewDelegate` protocol.
 */
@protocol WHDismissiveTextViewDelegate <NSObject>

@optional
/**
 *  Tells the delegate that the keyboard has full appeared on screen.
 */
- (void)keyboardDidShow;

/**
 *  Tells the delegate that the keyboard origin has moved to the specified point.
 *
 *  @param point The origin of the keyboard's frame in its superview's coordinate system.
 */
- (void)keyboardDidScrollToPoint:(CGPoint)point;

/**
 *  Tells the delegate that the keyboard is about to be dismissed. The keyboard will be removed from from its superview and resign first responder.
 */
- (void)keyboardWillBeDismissed;

/**
 *  Tells the delegate that the keyboard origin is about to move back to the specified point.
 *
 *  @param point The new origin of the keyboard's frame after it has completed animation.
 */
- (void)keyboardWillSnapBackToPoint:(CGPoint)point;

@end


/**
 *  An instance of `WHDismissiveTextView` is a means for displaying a text view that is contained as a subview of the keyboard's `inputAccessoryView` and responds to a pan gesture to dismiss the keyboard and end editing.
 */
@interface WHDismissiveTextView : UITextView

/**
 *  The object that acts as the delegate of the receiving text view.
 */
@property (weak, nonatomic) id<WHDismissiveTextViewDelegate> keyboardDelegate;

/**
 *  The pan gesture recognizer for the text view.
 */
@property (strong, nonatomic) UIPanGestureRecognizer *dismissivePanGestureRecognizer;

@end
