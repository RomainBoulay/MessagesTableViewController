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
#import "WHMessageTableView.h"
#import "WHMessageData.h"
#import "WHBubbleMessageCell.h"
#import "WHMessageInputView.h"
#import "WHAvatarImageFactory.h"
#import "WHBubbleImageViewFactory.h"
#import "WHMessageSoundEffect.h"
#import "UIColor+WHMessagesView.h"

/**
 *  The delegate of a `WHMessagesViewController` must adopt the `WHMessagesViewDelegate` protocol.
 */
@protocol WHMessagesViewDelegate <NSObject>


@required

/**
 *  Tells the delegate that the user has sent a message with the specified text, sender, and date.
 *
 *  @param text   The text that was present in the textView of the messageInputView when the send button was pressed.
 *  @param sender The user who sent the message.
 *  @param date   The date and time at which the message was sent.
 */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date;


/**
 *  Asks the delegate for the message type for the row at the specified index path.
 *
 *  @param indexPath The index path of the row to be displayed.
 *
 *  @return A constant describing the message type. 
 *  @see WHBubbleMessageType.
 */
- (WHBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  Asks the delegate for the bubble image view for the row at the specified index path with the specified type.
 *
 *  @param type      The type of message for the row located at indexPath.
 *  @param indexPath The index path of the row to be displayed.
 *
 *  @return A `UIImageView` with both `image` and `highlightedImage` properties set. 
 *  @see WHBubbleImageViewFactory.
 */
- (UIImageView *)bubbleImageViewWithType:(WHBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  Asks the delegate for the input view style.
 *
 *  @return A constant describing the input view style.
 *  @see WHMessageInputViewStyle.
 */
- (WHMessageInputViewStyle)inputViewStyle;


/**
 *  Asks the delegate for a custom cell reuse identifier for the row to be displayed at the specified index path.
 *
 *  @param indexPath The index path of the row to be displayed.
 *
 *  @return A string specifying the cell reuse identifier for the row at indexPath.
 */
- (NSString *)customCellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;


@optional

/**
 *  Asks the delegate if a timestamp should be displayed *above* the row at the specified index path.
 *
 *  @param indexPath The index path of the row to be displayed.
 *
 *  @return A boolean value specifying whether or not a timestamp should be displayed for the row at indexPath. The default value is `YES`.
 */
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  Asks the delegate to configure or further customize the given cell at the specified index path.
 *
 *  @param cell      The message cell to configure.
 *  @param indexPath The index path for cell.
 */
- (void)configureCell:(WHBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath;


/**
 *  Asks the delegate if should always scroll to bottom automatically when new messages are sent or received.
 *
 *  @return `YES` if you would like to prevent the table view from being scrolled to the bottom while the user is scrolling the table view manually, `NO` otherwise.
 */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling;


/**
 *  Ask the delegate if the keyboard should be dismissed by panning/swiping downward. The default value is `YES`. Return `NO` to dismiss the keyboard by tapping.
 *
 *  @return A boolean value specifying whether the keyboard should be dismissed by panning/swiping.
 */
- (BOOL)allowsPanToDismissKeyboard;


/**
 *  Asks the delegate for the send button to be used in messageInputView. Implement this method if you wish to use a custom send button. The button must be a `UIButton` or a subclass of `UIButton`. The button's frame is set for you.
 *
 *  @return A custom `UIButton` to use in messageInputView.
 */
- (UIButton *)sendButtonForInputView;


@end



@protocol WHMessagesViewDataSource <NSObject>

@required

/**
 *  This method is called dureing viewDidLoad. Needed to register cells and supplementary views
 *
 *  @param collectionView the targeted collection view
 */
- (void)registerObjectsToCollectionView:(UICollectionView *)collectionView;


/**
 *  Asks the data soruce for the message object to display for the row at the specified index path. The message text is displayed in the bubble at index path. The message date is displayed *above* the row at the specified index path. The message sender is displayed *below* the row at the specified index path.
 *
 *  @param indexPath An index path locating a row in the table view.
 *
 *  @return An object that conforms to the `WHMessageData` protocol containing the message data. This value must not be `nil`.
 */
- (id<WHMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  Asks the data source for the imageView to display for the row at the specified index path with the given sender. The imageView must have its `image` property set.
 *
 *  @param indexPath An index path locating a row in the table view.
 *  @param sender    The name of the user who sent the message at indexPath.
 *
 *  @return An image view specifying the avatar for the message at indexPath. This value may be `nil`.
 */
- (UIImage *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender;


@end


/**
 *  An instance of `WHMessagesViewController` is a subclass of `UIViewController` specialized to display a messaging interface.
 */
@interface WHMessagesViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate>


/**
 *  The object that acts as the delegate of the receiving messages view.
 */
@property (weak, nonatomic) id<WHMessagesViewDelegate> messageDelegate;


/**
 *  The object that acts as the data source of receiving messages view.
 */
@property (weak, nonatomic) id<WHMessagesViewDataSource> messageDataSource;


///**
// *  Returns the table view that displays the messages in `WHMessagesViewController`.
// */
//@property (weak, nonatomic, readonly) WHMessageTableView *collectionView;


/**
 *  Returns the message input view with which new messages are composed.
 */
@property (weak, nonatomic, readonly) WHMessageInputView *messageInputView;


/**
 *  The name of the user sending messages. The default value is `nil`.
 */
@property (copy, nonatomic) NSString *sender;


#pragma mark - Messages view controller
/**
 *  Animates and resets the text view in messageInputView. Call this method at the end of the delegate method `didSendText:`. 
 *  @see WHMessagesViewDelegate.
 */
- (void)finishSend;


/**
 *  Sets the background color of the table view, the table view cells, and the table view separator.
 *
 *  @param color The color to be used as the new background color.
 */
- (void)setBackgroundColor:(UIColor *)color;


/**
 *  Scrolls the table view such that the bottom most cell is completely visible, above the messageInputView. 
 *
 *  This method respects the delegate method `shouldPreventScrollToBottomWhileUserScrolling`. 
 *
 *  @see WHMessagesViewDelegate.
 *
 *  @param animated `YES` if you want to animate scrolling, `NO` if it should be immediate.
 */
- (void)scrollToBottomAnimated:(BOOL)animated;


/**
 *  Scrolls the receiver until a row identified by index path is at a particular location on the screen. 
 *
 *  This method respects the delegate method `shouldPreventScrollToBottomWhileUserScrolling`. 
 *
 *  @see WHMessagesViewDelegate.
 *
 *  @param indexPath An index path that identifies a row in the table view by its row index and its section index.
 *  @param position  A constant defined in `UICollectionViewScrollPosition` that identifies a relative position in the receiving table view.
 *  @param animated  `YES` if you want to animate the change in position, `NO` if it should be immediate.
 */
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
			  atScrollPosition:(UICollectionViewScrollPosition)position
					  animated:(BOOL)animated;

@end