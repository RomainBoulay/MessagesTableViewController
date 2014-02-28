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

#import "WHMessagesViewController.h"
#import "NSString+WHMessagesView.h"


@interface WHMessagesViewController () <WHDismissiveTextViewDelegate>

@property(assign, nonatomic) CGFloat previousTextViewContentHeight;
@property(assign, nonatomic) BOOL isUserScrolling;

@end


@implementation WHMessagesViewController

#pragma mark - Initialization
- (id)init {
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    return self;
}


- (void)setup {
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        // FIXME: hack-ish fix for ipad modal form presentations
        ((UIScrollView *) self.view).scrollEnabled = NO;
    }
    
    _isUserScrolling = NO;
    
    WHMessageInputViewStyle inputViewStyle = [self.messageDelegate inputViewStyle];
    CGFloat inputViewHeight = (inputViewStyle == WHMessageInputViewStyleFlat) ? 45.0f : 40.0f;
    
    WHMessageTableView *collectionView = [[WHMessageTableView alloc] initWithFrame:self.view.frame collectionViewLayout:self.collectionViewLayout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    self.collectionView = collectionView;
    
    [self setInsetsWithBottomValue:inputViewHeight];
    
    [self setBackgroundColor:[UIColor backgroundColorClassic]];
    
    CGRect inputFrame = CGRectMake(0.0f,
                                   self.view.frame.size.height - inputViewHeight,
                                   self.view.frame.size.width,
                                   inputViewHeight);
    
    BOOL allowsPan = YES;
    if ([self.messageDelegate respondsToSelector:@selector(allowsPanToDismissKeyboard)]) {
        allowsPan = [self.messageDelegate allowsPanToDismissKeyboard];
    }
    
    UIPanGestureRecognizer *pan = allowsPan ? self.collectionView.panGestureRecognizer : nil;
    
    WHMessageInputView *inputView = [[WHMessageInputView alloc] initWithFrame:inputFrame
                                                                        style:inputViewStyle
                                                                     delegate:self
                                                         panGestureRecognizer:pan];
    
    if (!allowsPan) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self.collectionView addGestureRecognizer:tap];
    }
    
    if ([self.messageDelegate respondsToSelector:@selector(sendButtonForInputView)]) {
        UIButton *sendButton = [self.messageDelegate sendButtonForInputView];
        [inputView setSendButton:sendButton];
    }
    
    inputView.sendButton.enabled = NO;
    [inputView.sendButton addTarget:self
                             action:@selector(sendPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:inputView];
    _messageInputView = inputView;
    
    // Cell register
    [self.messageDataSource registerObjectsToCollectionView:self.collectionView];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [[WHBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.messageInputView.textView addObserver:self
                                     forKeyPath:@"contentSize"
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.messageInputView resignFirstResponder];
    [self setEditing:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self.messageInputView.textView removeObserver:self forKeyPath:@"contentSize"];
}


- (void)dealloc {
    [self.messageInputView.textView removeObserver:self forKeyPath:@"contentSize"];
    _messageDelegate = nil;
    _messageDataSource = nil;
    self.collectionView = nil;
    _messageInputView = nil;
}

#pragma mark - View rotation

- (BOOL)shouldAutorotate {
    return YES;
}


- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView reloadData];
    [self.collectionView setNeedsLayout];
}

#pragma mark - Actions

- (void)sendPressed:(UIButton *)sender {
    [self.messageDelegate didSendText:[self.messageInputView.textView.text stringByTrimingWhitespace]
                           fromSender:self.sender
                               onDate:[NSDate date]];
}


- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tap {
    [self.messageInputView.textView resignFirstResponder];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [self.messageDelegate customCellIdentifierForRowAtIndexPath:indexPath];
    
    WHBubbleMessageCell *cell = (WHBubbleMessageCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                                                  forIndexPath:indexPath];
    
    WHBubbleMessageType type = [self.messageDelegate messageTypeForRowAtIndexPath:indexPath];
    
    UIImageView *bubbleImageView = [self.messageDelegate bubbleImageViewWithType:type
                                                               forRowAtIndexPath:indexPath];
    
    BOOL displayTimestamp = YES;
    if ([self.messageDelegate respondsToSelector:@selector(shouldDisplayTimestampForRowAtIndexPath:)]) {
        displayTimestamp = [self.messageDelegate shouldDisplayTimestampForRowAtIndexPath:indexPath];
    }
    
    id <WHMessageData> message = [self.messageDataSource messageForRowAtIndexPath:indexPath];
    UIImage *avatarImage = [self.messageDataSource avatarImageViewForRowAtIndexPath:indexPath sender:[message sender]];
    
    
    [cell configureWithType:type
            bubbleImageView:bubbleImageView
                    message:message
          displaysTimestamp:displayTimestamp
                     avatar:(avatarImage != nil)];
    
    [cell setAvatarImage:avatarImage];
    [cell setBackgroundColor:collectionView.backgroundColor];
    
    if ([self.messageDelegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
        [self.messageDelegate configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id <WHMessageData> message = [self.messageDataSource messageForRowAtIndexPath:indexPath];
    UIImage *avatarImage = [self.messageDataSource avatarImageViewForRowAtIndexPath:indexPath sender:[message sender]];
    
    BOOL displayTimestamp = YES;
    if ([self.messageDelegate respondsToSelector:@selector(shouldDisplayTimestampForRowAtIndexPath:)]) {
        displayTimestamp = [self.messageDelegate shouldDisplayTimestampForRowAtIndexPath:indexPath];
    }
    
    CGFloat heigth = [WHBubbleMessageCell neededHeightForBubbleMessageCellWithMessage:message
                                                                       displaysAvatar:avatarImage != nil
                                                                    displaysTimestamp:displayTimestamp];
    
    return CGSizeMake(320, heigth);
}


#pragma mark - Messages view controller
- (void)finishSend {
    [self.messageInputView.textView setText:nil];
    [self textViewDidChange:self.messageInputView.textView];
    [self.collectionView reloadData];
}


- (void)setBackgroundColor:(UIColor *)color {
    self.view.backgroundColor = color;
    self.collectionView.backgroundColor = color;
    //    self.collectionView.separatorColor = color;
}


- (void)scrollToBottomAnimated:(BOOL)animated {
    if (![self shouldAllowScroll])
        return;
    
    NSInteger rows = [self.collectionView numberOfItemsInSection:0];
    
    if (rows > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionBottom
                                            animated:animated];
    }
}


- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
              atScrollPosition:(UICollectionViewScrollPosition)position
                      animated:(BOOL)animated {
    if (![self shouldAllowScroll])
        return;
    
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:position
                                        animated:animated];
}


- (BOOL)shouldAllowScroll {
    if (self.isUserScrolling) {
        if ([self.messageDelegate respondsToSelector:@selector(shouldPreventScrollToBottomWhileUserScrolling)]
            && [self.messageDelegate shouldPreventScrollToBottomWhileUserScrolling]) {
            return NO;
        }
    }
    
    return YES;
}


#pragma mark - Scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isUserScrolling = YES;
    
    [self.messageInputView.textView resignFirstResponder];

}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isUserScrolling = NO;
}


#pragma mark - Text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    
    if (!self.previousTextViewContentHeight)
        self.previousTextViewContentHeight = textView.contentSize.height;
    
    [self scrollToBottomAnimated:YES];
}


- (void)textViewDidChange:(UITextView *)textView {
    self.messageInputView.sendButton.enabled = ([[textView.text stringByTrimingWhitespace] length] > 0);
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}


#pragma mark - Layout message input view
- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView {
    CGFloat maxHeight = [WHMessageInputView maxHeight];
    
    BOOL isShrinking = textView.contentSize.height < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textView.contentSize.height - self.previousTextViewContentHeight;
    
    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [self setInsetsWithBottomValue:self.collectionView.contentInset.bottom + changeInHeight];
                             
                             [self scrollToBottomAnimated:NO];
                             
                             if (isShrinking) {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.messageInputView.frame;
                             self.messageInputView.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             
                             if (!isShrinking) {
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.previousTextViewContentHeight = MIN(textView.contentSize.height, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, textView.contentSize.height - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}


- (void)setInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = [self collectionViewInsetsWithBottomValue:bottom];
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
}


- (UIEdgeInsets)collectionViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = self.topLayoutGuide.length;
    }
    
    insets.bottom = bottom;
    
    return insets;
}


#pragma mark - Key-value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.messageInputView.textView && [keyPath isEqualToString:@"contentSize"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}


#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboardNotification:(NSNotification *)notification {
    [self keyboardWillShowHide:notification];
}


- (void)handleWillHideKeyboardNotification:(NSNotification *)notification {
    [self keyboardWillShowHide:notification];
}


- (void)keyboardWillShowHide:(NSNotification *)notification {
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:[self animationOptionsForCurve:curve]
                     animations:^{
                         CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                         
                         CGRect inputViewFrame = self.messageInputView.frame;
                         CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                         
                         // for ipad modal form presentations
                         CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
                         if (inputViewFrameY > messageViewFrameBottom)
                             inputViewFrameY = messageViewFrameBottom;
                         
                         self.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                                  inputViewFrameY,
                                                                  inputViewFrame.size.width,
                                                                  inputViewFrame.size.height);
                         
                         [self setInsetsWithBottomValue:self.view.frame.size.height
                          - self.messageInputView.frame.origin.y];
                     }
                     completion:nil];
}


#pragma mark - Dismissive text view delegate
- (void)keyboardDidScrollToPoint:(CGPoint)point {
    CGRect inputViewFrame = self.messageInputView.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:point fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    self.messageInputView.frame = inputViewFrame;
}


- (void)keyboardWillBeDismissed {
    CGRect inputViewFrame = self.messageInputView.frame;
    inputViewFrame.origin.y = self.view.bounds.size.height - inputViewFrame.size.height;
    self.messageInputView.frame = inputViewFrame;
}


#pragma mark - Utilities
- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve {
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            
        default:
            return kNilOptions;
    }
}


@end
