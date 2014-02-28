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

@import UIKit;
#import "WHMessageTextView.h"

/**
 *  The appearance style of the input bar view for composing a new message.
 */
typedef NS_ENUM(NSUInteger, WHMessageInputViewStyle) {
    /**
     *  An input view style that has the appearance as seen in iOS 6 and before.
     */
    WHMessageInputViewStyleClassic,
    /**
     *  An input view style that has the appearance as seen in iOS 7 and later.
     */
    WHMessageInputViewStyleFlat
};


/**
 *  An instance of `WHMessageInputView` defines the input toolbar for composing a new message that is to be displayed above the keyboard.
 */
@interface WHMessageInputView : UIImageView

/**
 *  Returns the style appearance for the input view.
 *  @see WHMessageInputViewStyle.
 */
@property (assign, nonatomic, readonly) WHMessageInputViewStyle style;

/**
 *  Returns the textView into which a new message is composed. This property is never `nil`.
 */
@property (weak, nonatomic, readonly) WHMessageTextView *textView;

/**
 *  The send button for the input view. The default value is an initialized `UIButton` whose appearance is styled according to the value of style during initialization. 
 *  @see WHMessageInputViewStyle.
 */
@property (weak, nonatomic) UIButton *sendButton;


#pragma mark - Initialization
/**
 *  Initializes and returns an input view having the given frame, style, delegate, and panGestureRecognizer.
 *
 *  @param frame                A rectangle specifying the initial location and size of the bubble view in its superview's coordinates.
 *  @param style                The style of the input view. @see WHMessageInputViewStyle.
 *  @param delegate             An object that conforms to the `UITextViewDelegate` protocol and `WHDismissiveTextViewDelegate` protocol. 
 *  @see WHDismissiveTextViewDelegate.
 *  @param panGestureRecognizer A `UIPanGestureRecognizer` used to dismiss the input view by dragging down.
 *
 *  @return An initialized `WHMessageInputView` object or `nil` if the object could not be successfully initialized.
 */
- (instancetype)initWithFrame:(CGRect)frame
                        style:(WHMessageInputViewStyle)style
                     delegate:(id<UITextViewDelegate, WHDismissiveTextViewDelegate>)delegate
         panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;


#pragma mark - Message input view
/**
 *  Adjusts the input view's frame height by the given value.
 *
 *  @param changeInHeight The delta value by which to increase or decrease the existing height for the input view.
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

/**
 *  @return A constant indicating the height of one line of text in the input view.
 */
+ (CGFloat)textViewLineHeight;

/**
 *  @return A contant indicating the maximum number of lines of text that can be displayed in the textView.
 */
+ (CGFloat)maxLines;

/**
 *  @return The maximum height of the input view as determined by `maxLines` and `textViewLineHeight`. This value is used for controlling the animation of the growing and shrinking of the input view as the text changes in the textView.
 */
+ (CGFloat)maxHeight;
@end