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

#import <KVOController/FBKVOController.h>

#import "NSString+WHMessages.h"
#import "UIScrollView+WHMessages.h"


@interface WHMessagesViewController () <WHDismissiveTextViewDelegate>

@property(assign, nonatomic) CGFloat previousTextViewContentHeight;
@property(assign, nonatomic) BOOL isUserScrolling;
@property(assign, nonatomic) BOOL allowsPan;
@property(nonatomic, readwrite) WHMessageInputViewStyle inputViewStyle;
@property(weak, nonatomic, readwrite) WHMessageInputView *messageInputView;
@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic) BOOL isFirstTimeViewDidLayoutSubviews;

@end


@implementation WHMessagesViewController


#pragma mark - Initialization
- (id)init {
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        [self setup];
    }
    
    return self;
}


- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    self.allowsPan = YES;
    self.inputViewStyle = WHMessageInputViewStyleFlat;
    
    // create KVO controller with observer
    self.kvoController = [FBKVOController controllerWithObserver:self];
}


#pragma mark - Getter
- (BOOL)isInputViewFlat {
    return (self.inputViewStyle == WHMessageInputViewStyleFlat || self.inputViewStyle == WHMessageInputViewStyleFlatFullExperience);
}


- (WHMessageInputView *)messageInputView {
    if (_messageInputView)
        return _messageInputView;
    
    CGFloat inputViewHeight = (self.isInputViewFlat) ? 45.0f : 40.0f;
    UIPanGestureRecognizer *pan = self.allowsPan ? self.collectionView.panGestureRecognizer : nil;
    
    CGRect inputFrame = CGRectMake(0.0f,
                                   self.view.frame.size.height - inputViewHeight,
                                   self.view.frame.size.width,
                                   inputViewHeight);
    
    WHMessageInputView *inputView = [[WHMessageInputView alloc] initWithFrame:inputFrame
                                                                        style:self.inputViewStyle
                                                                     delegate:self
                                                         panGestureRecognizer:pan];
    
    if ([self.messageDelegate respondsToSelector:@selector(sendButtonForInputView)]) {
        UIButton *sendButton = [self.messageDelegate sendButtonForInputView];
        inputView.sendButton = sendButton;
        
        sendButton.enabled = NO;
        [sendButton addTarget:self
                       action:@selector(sendPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    
    [self.view addSubview:inputView];
    self.messageInputView = inputView;
    
    return _messageInputView;
}


#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        // FIXME: hack-ish fix for ipad modal form presentations
        ((UIScrollView *) self.view).scrollEnabled = NO;
    }
    
    _isUserScrolling = NO;
    
    // Ask delegate for inputViewStyle.
    if ([self.messageDelegate respondsToSelector:@selector(inputViewStyle)]) {
        self.inputViewStyle = [self.messageDelegate inputViewStyle];
    }
    
    // Set insets
    CGFloat inputViewHeight = (self.inputViewStyle == WHMessageInputViewStyleFlat) ? 45.0f : 40.0f;
    [self setInsetsWithBottomValue:inputViewHeight];
    
    // Ask delegate for allowsPan.
    if ([self.messageDelegate respondsToSelector:@selector(allowsPanToDismissKeyboard)]) {
        self.allowsPan = [self.messageDelegate allowsPanToDismissKeyboard];
    }
    
    if (!self.allowsPan) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self.collectionView addGestureRecognizer:tap];
    }
    
    // Register cells/views
    [self.messageDataSource registerObjectsToCollectionView:self.collectionView];
    
    // Refresh UI state on WillEnterForeground Notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUIState)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    self.isFirstTimeViewDidLayoutSubviews = YES;
    
    //    [self.collectionView reloadData];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidHideKeyboardNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [self.kvoController observe:self.messageInputView.textView
                        keyPath:NSStringFromSelector(@selector(contentSize))
                        options:NSKeyValueObservingOptionNew
                          block:^(WHMessagesViewController *observer, WHMessageTextView *object, NSDictionary *change) {
                              [observer layoutAndAnimateMessageInputTextView:object];
                          }];
}


- (void)viewDidLayoutSubviews {
    // only after layoutSubviews executes for subviews, do constraints and frames agree (WWDC 2012 video "Best Practices for Mastering Auto Layout")
    if (self.isFirstTimeViewDidLayoutSubviews) {
        // good place to set scroll view's content offset, if its subviews are added dynamically (in code)
        [self scrollToLastCellAnimated:YES];
        self.isFirstTimeViewDidLayoutSubviews = NO;
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self dismissKeyboard];
    [self unsubscribeToNotifications];
}


- (void)refreshUIState {
    if (self.isViewLoaded)
        [self.collectionView reloadData];
}


#pragma mark - View rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView reloadData];
    [self.collectionView setNeedsLayout];
}


#pragma mark - Actions
- (void)beginTextEdition {
    self.editing = YES;
    [self.messageInputView.textView becomeFirstResponder];
}


- (void)endTextEdition {
    [self dismissKeyboard];
    self.editing = NO;
}


- (void)sendPressed:(UIButton *)sender {
    [self.messageDelegate didSendText:[self.messageInputView.textView.text stringByTrimingWhitespace]
                               onDate:[NSDate date]];
    
    [self finishSend];
}


- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tap {
    [self dismissKeyboard];
}


- (void)dismissKeyboard {
    [self.messageInputView.textView resignFirstResponder];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.messageDelegate numberOfSections];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.messageDelegate numberOfItemsInSection:section];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue or init cell
    NSString *cellIdentifier = [self.messageDelegate customCellIdentifierForRowAtIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                           forIndexPath:indexPath];
    
    // Configure cell
    if ([self.messageDelegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
        [self.messageDelegate configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}


#pragma mark - Messages view controller
- (void)finishSend {
    self.messageInputView.textView.text = nil;
    self.messageInputView.sendButton.enabled = NO;
    
    [self.collectionView reloadData];
    [self scrollToLastCellAnimated:YES];
    
    [self performSelector:@selector(dismissKeyboard) withObject:nil afterDelay:0.25];
}


- (void)scrollToLastCellAnimated:(BOOL)animated {
    if (![self shouldAllowScroll])
        return;
    
    NSInteger section = [self.collectionView numberOfSections]-1;
    NSInteger row = [self.collectionView numberOfItemsInSection:section]-1;
    if (row >= 0 && section >= 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:row inSection:section]
                                    atScrollPosition:UICollectionViewScrollPositionTop
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
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isUserScrolling = NO;
}


#pragma mark - Text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    
    if (!self.previousTextViewContentHeight)
        self.previousTextViewContentHeight = textView.contentSize.height;
    
    [self scrollToLastCellAnimated:YES];
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
    
    if (changeInHeight) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [self setInsetsWithBottomValue:self.collectionView.contentInset.bottom + changeInHeight];
                             
                             //                             [self.collectionView scrollToBottomAnimated:NO];
                             
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
                             [self scrollToLastCellAnimated:YES];
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


#pragma mark - Insets
- (void)setInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = self.collectionView.contentInset;
    insets.bottom = bottom;
    [self setInsets:insets];
}


- (void)updateCollectionViewInsets {
    UIEdgeInsets insets = [self collectionViewInsets];
    [self setInsets:insets];
}


- (void)setInsets:(UIEdgeInsets)insets {
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
}


- (UIEdgeInsets)collectionViewInsets {
    UIEdgeInsets insets = self.collectionView.contentInset;
    
    if (self.topLayoutGuideLength)
        insets.top = self.topLayoutGuideLength.floatValue;
    else if ([self respondsToSelector:@selector(topLayoutGuide)])
        insets.top = self.topLayoutGuide.length;
    
    if (self.bottomLayoutGuideLength)
        insets.bottom = self.bottomLayoutGuideLength.floatValue;
    else if ([self respondsToSelector:@selector(bottomLayoutGuide)])
        insets.bottom = self.bottomLayoutGuide.length;
    
    return insets;
}


#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboardNotification:(NSNotification *)notification {
    self.editing = YES;
    [self keyboardWillShowHide:notification];
}


- (void)handleWillHideKeyboardNotification:(NSNotification *)notification {
    [self keyboardWillShowHide:notification];
}


- (void)handleDidHideKeyboardNotification:(NSNotification *)notification {
    self.editing = NO;
    [self keyboardWillShowHide:notification];
}


- (void)keyboardWillShowHide:(NSNotification *)notification {
    CGRect keyboardRect = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
    
    CGRect inputViewFrame = self.messageInputView.frame;
    CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
    
    // for ipad modal form presentations
    CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
    if (inputViewFrameY > messageViewFrameBottom)
        inputViewFrameY = messageViewFrameBottom;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // work
    self.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
                                             inputViewFrameY,
                                             inputViewFrame.size.width,
                                             inputViewFrame.size.height);
    
    [self setInsetsWithBottomValue:self.view.frame.size.height - self.messageInputView.frame.origin.y];
    
    [UIView commitAnimations];
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


#pragma mark - Notifications
- (void)unsubscribeToNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


#pragma mark - Memory
- (void)dealloc {
    [self unsubscribeToNotifications];
    _messageDelegate = nil;
    _messageDataSource = nil;
    _messageInputView = nil;
}


@end
