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

#import "WHDemoViewController.h"

#import "WHDemoMessage.h"
#import "UIColor+WHMessagesView.h"
#import "WHDemoBubbleView.h"
#import "WHDemoAvatarImageFactory.h"
#import "WHDemoBubbleMessageCell.h"
#import "WHSimpleMessageCell.h"

#define kSubtitleJobs @"Jobs"
#define kSubtitleWoz @"Steve Wozniak"
#define kSubtitleCook @"Mr. Cook"


@implementation WHDemoViewController


#pragma mark - View lifecycle
- (void)viewDidLoad {
    self.messageDelegate = self;
    self.messageDataSource = self;
    [super viewDidLoad];
    
    [[WHDemoBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    [self setBackgroundColor:[UIColor backgroundColorClassic]];
    
    [[WHDemoBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    self.title = @"Messages";
    self.messageInputView.textView.placeHolder = @"New Message";
    self.sender = @"Jobs";
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.messages = [[NSMutableArray alloc] initWithObjects:
                     [[WHDemoMessage alloc] initWithText:@"WHMessagesViewController is simple and easy to use." sender:kSubtitleJobs date:[NSDate distantPast]],
                     [[WHDemoMessage alloc] initWithText:@"It's highly customizable." sender:kSubtitleWoz date:[NSDate distantPast]],
                     [[WHDemoMessage alloc] initWithText:@"It even has data detectors. You can call me tonight. My cell number is 452-123-4567. \nMy website is www.hexedbits.com." sender:kSubtitleJobs date:[NSDate distantPast]],
                     [[WHDemoMessage alloc] initWithText:@"Group chat. Sound effects and images included. Animations are smooth. Messages can be of arbitrary size!" sender:kSubtitleCook date:[NSDate distantPast]],
                     [[WHDemoMessage alloc] initWithText:@"Group chat. Sound effects and images included. Animations are smooth. Messages can be of arbitrary size!" sender:kSubtitleJobs date:[NSDate date]],
                     [[WHDemoMessage alloc] initWithText:@"Group chat. Sound effects and images included. Animations are smooth. Messages can be of arbitrary size!" sender:kSubtitleWoz date:[NSDate date]],
                     nil];
    
    
    for (NSUInteger i = 0; i < 3; i++) {
        for (WHDemoMessage *m in [self.messages copy]) {
            [self.messages addObject:[m copy]];
        }
    }
    
    self.avatars = @{kSubtitleJobs: [WHDemoAvatarImageFactory avatarImageNamed:@"demo-avatar-jobs" croppedToCircle:YES],
                     kSubtitleWoz: [WHDemoAvatarImageFactory avatarImageNamed:@"demo-avatar-woz" croppedToCircle:YES],
                     kSubtitleCook: [WHDemoAvatarImageFactory avatarImageNamed:@"demo-avatar-cook" croppedToCircle:YES]};
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                                           target:self
                                                                                           action:@selector(buttonPressed:)];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
}


- (void)setBackgroundColor:(UIColor *)color {
    self.view.backgroundColor = color;
    self.collectionView.backgroundColor = color;
}


#pragma mark - Actions
- (void)buttonPressed:(UIBarButtonItem *)sender {
    // Testing pushing/popping messages view
    WHDemoViewController *vc = [[WHDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source
- (void)registerObjectsToCollectionView:(UICollectionView *)collectionView {
    [collectionView registerNib:[WHSimpleMessageCell cellNib] forCellWithReuseIdentifier:@"WHSimpleMessageCell"];
}


- (NSString *)customCellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"WHSimpleMessageCell";
}


#pragma mark - UICollectionViewDelegateFlowLayout (UICollectionViewDelegate)
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    WHDemoMessage * message = [self messageForRowAtIndexPath:indexPath];
    CGFloat height = [WHSimpleMessageCell preferredHeightForCellWithMessage:message.text];
    
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), height);
}


#pragma mark - Messages view delegate: REQUIRED
- (void)didSendText:(NSString *)text onDate:(NSDate *)date {
    [self.messages addObject:[[WHDemoMessage alloc] initWithText:text sender:self.sender date:date]];
}


- (WHBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row % 2) ? WHBubbleMessageTypeIncoming : WHBubbleMessageTypeOutgoing;
}


- (UIImageView *)bubbleImageViewWithType:(WHBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2) {
        return [WHDemoBubbleImageViewFactory bubbleImageViewForType:type
                                                              color:[UIColor bubbleLightGrayColor]];
    }
    
    return [WHDemoBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor bubbleBlueColor]];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
}


#pragma mark - Messages view delegate: OPTIONAL
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 3 == 0) {
        return YES;
    }
    return NO;
}


#pragma mark - WHMessagesViewDelegate
- (NSInteger)numberOfSections {
    return 1;
}


- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}


//
//  *** Implement to customize cell further
//
- (void)configureCell:(UICollectionViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath {
    WHSimpleMessageCell *cell = (WHSimpleMessageCell *)aCell;
    cell.titleLabel.text = [self messageForRowAtIndexPath:indexPath].text;
    
//    WHDemoBubbleMessageCell *cell = (WHDemoBubbleMessageCell *)aCell;
//    WHBubbleMessageType type = [self messageTypeForRowAtIndexPath:indexPath];
//    
//    UIImageView *bubbleImageView = [self bubbleImageViewWithType:type
//                                               forRowAtIndexPath:indexPath];
//    
//    BOOL displayTimestamp = [self shouldDisplayTimestampForRowAtIndexPath:indexPath];
//    
//    WHDemoMessage * message = [self messageForRowAtIndexPath:indexPath];
//    UIImage *avatarImage = [self avatarImageViewForRowAtIndexPath:indexPath sender:[message sender]];
//    
//    
//    [cell configureWithType:type
//            bubbleImageView:bubbleImageView
//                    message:message
//          displaysTimestamp:displayTimestamp
//                     avatar:(avatarImage != nil)];
//    
//    [cell setAvatarImage:avatarImage];
//    //    [cell setBackgroundColor:collectionView.backgroundColor];
//    
//    
//    if ([cell messageType] == WHBubbleMessageTypeOutgoing) {
//        cell.bubbleView.textView.textColor = [UIColor whiteColor];
//        
//        if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
//            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
//            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
//            
//            cell.bubbleView.textView.linkTextAttributes = attrs;
//        }
//    }
//    
//    if (cell.timestampLabel) {
//        cell.timestampLabel.textColor = [UIColor lightGrayColor];
//        cell.timestampLabel.shadowOffset = CGSizeZero;
//    }
//    
//    if (cell.subtitleLabel) {
//        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
//    }
//    
//#if TARGET_IPHONE_SIMULATOR
//    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
//#else
//    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
//#endif
}

//  *** Implement to use a custom send button
//
//  The button's frame is set automatically for you
//
//  - (UIButton *)sendButtonForInputView
//

//  *** Implement to prevent auto-scrolling when message is added
//
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}


// *** Implemnt to enable/disable pan/tap todismiss keyboard
//
- (BOOL)allowsPanToDismissKeyboard {
    return YES;
}


#pragma mark - Messages data source
/**
 *  Asks the data soruce for the message object to display for the row at the specified index path. The message text is displayed in the bubble at index path. The message date is displayed *above* the row at the specified index path. The message sender is displayed *below* the row at the specified index path.
 *
 *  @param indexPath An index path locating a row in the table view.
 *
 *  @return An object that conforms to the `WHMessageData` protocol containing the message data. This value must not be `nil`.
 */
- (WHDemoMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.messages)[indexPath.row];
}


/**
 *  Asks the data source for the imageView to display for the row at the specified index path with the given sender. The imageView must have its `image` property set.
 *
 *  @param indexPath An index path locating a row in the table view.
 *  @param sender    The name of the user who sent the message at indexPath.
 *
 *  @return An image view specifying the avatar for the message at indexPath. This value may be `nil`.
 */
- (UIImage *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender {
    return (self.avatars)[sender];
}

@end
