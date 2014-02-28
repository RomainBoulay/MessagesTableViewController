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

#import "WHMessageInputView.h"


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
- (void)didSendText:(NSString *)text onDate:(NSDate *)date;


/**
 *  Asks the delegate for a custom cell reuse identifier for the row to be displayed at the specified index path.
 *
 *  @param indexPath The index path of the row to be displayed.
 *
 *  @return A string specifying the cell reuse identifier for the row at indexPath.
 */
- (NSString *)customCellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  Asks the data source for the number of sections in the collection view.
 *
 *  @return The number of sections in collectionView.
 */
- (NSInteger)numberOfSections;


/**
 *  Asks the data source for the number of items in the specified section. (required)
 *
 *  @param section  An index number identifying a section in collectionView. This index value is 0-based.
 *
 *  @return The number of rows in section.
 */
- (NSInteger)numberOfItemsInSection:(NSInteger)section;


@optional

/**
 *  Asks the delegate for the input view style.
 *
 *  @return A constant describing the input view style.
 *  @see WHMessageInputViewStyle.
 */
- (WHMessageInputViewStyle)inputViewStyle;


/**
 *  Asks the delegate to configure or further customize the given cell at the specified index path.
 *
 *  @param cell      The message cell to configure.
 *  @param indexPath The index path for cell.
 */
- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;


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


/**
 *  Returns the message input view with which new messages are composed.
 */
@property (weak, nonatomic, readonly) WHMessageInputView *messageInputView;


#pragma mark - Messages view controller
/**
 *  Animates and resets the text view in messageInputView. This method is called at the end of the delegate method `didSendText:`. 
 *  @see WHMessagesViewDelegate.
 */
- (void)finishSend;


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