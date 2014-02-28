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

#import "WHBubbleMessageCell.h"

#import "WHAvatarImageFactory.h"
#import "UIColor+WHMessagesView.h"


static const CGFloat kJSLabelPadding = 5.0f;
static const CGFloat kJSTimeStampLabelHeight = 15.0f;
static const CGFloat kJSSubtitleLabelHeight = 15.0f;


@interface WHBubbleMessageCell ()

@property (weak, nonatomic, readwrite) WHBubbleView *bubbleView;
@property (weak, nonatomic, readwrite) UILabel *timestampLabel;
@property (weak, nonatomic, readwrite) UIImageView *avatarImageView;
@property (weak, nonatomic, readwrite) UILabel *subtitleLabel;
@property (assign, nonatomic) WHBubbleMessageType defaultType;

@end


@implementation WHBubbleMessageCell


#pragma mark - Init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        [self setup];
    }
    
    return self;
}


#pragma mark - Setup
- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.defaultType = WHBubbleMessageTypeOutgoing;
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(handleLongPressGesture:)];
    [recognizer setMinimumPressDuration:0.4f];
    [self addGestureRecognizer:recognizer];
}


#pragma mark - Getters
- (UILabel *)timestampLabel {
    if (_timestampLabel)
        return _timestampLabel;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kJSLabelPadding,
                                                               kJSLabelPadding,
                                                               self.contentView.frame.size.width - (kJSLabelPadding * 2.0f),
                                                               kJSTimeStampLabelHeight)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor messagesTimestampColorClassic];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.font = [UIFont boldSystemFontOfSize:12.0f];
    
    [self.contentView addSubview:label];
    [self.contentView bringSubviewToFront:label];
    self.timestampLabel = label;
    
    return _timestampLabel;
}


- (UIImageView *)avatarImageView {
    if (_avatarImageView)
        return _avatarImageView;
    
    CGFloat avatarX = 0.5f;
    WHBubbleMessageType type = self.defaultType;
    
    if (type == WHBubbleMessageTypeOutgoing) {
        avatarX = (self.contentView.frame.size.width - kJSAvatarImageSize);
    }
    
    CGFloat avatarY = self.contentView.frame.size.height - kJSAvatarImageSize;
    if (_subtitleLabel) {
        avatarY -= kJSSubtitleLabelHeight;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(avatarX, avatarY, kJSAvatarImageSize, kJSAvatarImageSize)];
    imageView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                                  | UIViewAutoresizingFlexibleLeftMargin
                                  | UIViewAutoresizingFlexibleRightMargin);
    
    [self.contentView addSubview:imageView];
    self.avatarImageView = imageView;
    
    return _avatarImageView;
}


- (UILabel *)subtitleLabel {
    if (_subtitleLabel)
        return _subtitleLabel;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = (self.defaultType == WHBubbleMessageTypeOutgoing) ? NSTextAlignmentRight : NSTextAlignmentLeft;
    label.textColor = [UIColor messagesTimestampColorClassic];
    label.font = [UIFont systemFontOfSize:12.5f];
    
    [self.contentView addSubview:label];
    self.subtitleLabel = label;
    
    return _subtitleLabel;
}


#pragma mark - Configurations
- (void)configureAvatarImageViewForMessageType:(WHBubbleMessageType)type {
    CGFloat avatarX = 0.5f;
    if (type == WHBubbleMessageTypeOutgoing) {
        avatarX = (self.contentView.frame.size.width - kJSAvatarImageSize);
    }
    
    CGFloat avatarY = self.contentView.frame.size.height - kJSAvatarImageSize;
    if (_subtitleLabel) {
        avatarY -= kJSSubtitleLabelHeight;
    }
    
    self.avatarImageView.hidden = NO;
    self.avatarImageView.frame = CGRectMake(avatarX, avatarY, kJSAvatarImageSize, kJSAvatarImageSize);
}


- (void)configureSubtitleLabelForMessageType:(WHBubbleMessageType)type {
    self.subtitleLabel.textAlignment = (type == WHBubbleMessageTypeOutgoing) ? NSTextAlignmentRight : NSTextAlignmentLeft;
}


- (void)configureWithType:(WHBubbleMessageType)type
          bubbleImageView:(UIImageView *)bubbleImageView
                  message:(id <WHMessageData>)message
        displaysTimestamp:(BOOL)displaysTimestamp
                   avatar:(BOOL)hasAvatar {
    CGFloat bubbleY = 0.0f;
    CGFloat bubbleX = 0.0f;
    
    CGFloat offsetX = 0.0f;
    
    if (displaysTimestamp) {
        self.timestampLabel.hidden = NO;
        bubbleY = 14.0f;
    }
    else {
        [_timestampLabel removeFromSuperview];
        self.timestampLabel = nil;
    }
    
    
    if ([message sender]) {
        [self configureSubtitleLabelForMessageType:type];
    }
    else {
        [_subtitleLabel removeFromSuperview];
        self.subtitleLabel = nil;
    }
    
    
    if (hasAvatar) {
        offsetX = 4.0f;
        bubbleX = kJSAvatarImageSize;
        if (type == WHBubbleMessageTypeOutgoing) {
            offsetX = kJSAvatarImageSize - 4.0f;
        }
        
        [self configureAvatarImageViewForMessageType:type];
    }
    else {
        [_avatarImageView removeFromSuperview];
        self.avatarImageView = nil;
    }
    
    
    CGRect frame = CGRectMake(bubbleX - offsetX,
                              bubbleY,
                              self.contentView.frame.size.width - bubbleX,
                              self.contentView.frame.size.height - _timestampLabel.frame.size.height - _subtitleLabel.frame.size.height);
    
    [self configureBubbleViewWithFrame:frame
                            bubbleType:type
                       bubbleImageView:bubbleImageView];

    [self setMessage:message];
}


- (void)configureBubbleViewWithFrame:(CGRect)frame
                          bubbleType:(WHBubbleMessageType)bubbleType
                     bubbleImageView:(UIImageView *)bubbleImageView {
    if (_bubbleView) {
        [self.bubbleView configureBubbleType:bubbleType];
    }
    else {
        self.bubbleView = [self bubbleViewWithFrame:frame bubbleType:bubbleType bubbleImageView:bubbleImageView];
    }
}


- (WHBubbleView *)bubbleViewWithFrame:(CGRect)frame
                           bubbleType:(WHBubbleMessageType)bubbleType
                      bubbleImageView:(UIImageView *)bubbleImageView {
    
    WHBubbleView *bubbleView = [[WHBubbleView alloc] initWithFrame:frame
                                                        bubbleType:bubbleType
                                                   bubbleImageView:bubbleImageView];
    
    bubbleView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                   | UIViewAutoresizingFlexibleHeight
                                   | UIViewAutoresizingFlexibleBottomMargin);
    
    [self.contentView addSubview:bubbleView];
    [self.contentView sendSubviewToBack:bubbleView];
    
    return bubbleView;
}


//- (void)configureWithType:(WHBubbleMessageType)type
//          bubbleImageView:(UIImageView *)bubbleImageView
//                  message:(id <WHMessageData>)message
//        displaysTimestamp:(BOOL)displaysTimestamp
//                   avatar:(BOOL)hasAvatar {
//    CGFloat bubbleY = 0.0f;
//    CGFloat bubbleX = 0.0f;
//    
//    CGFloat offsetX = 0.0f;
//    
//    if (displaysTimestamp) {
//        [self configureTimestampLabel];
//        bubbleY = 14.0f;
//    }
//    
//    if ([message sender]) {
//        // ok
//        [self configureSubtitleLabelForMessageType:type];
//    }
//    
//    if (hasAvatar) {
//        offsetX = 4.0f;
//        bubbleX = kJSAvatarImageSize;
//        if (type == WHBubbleMessageTypeOutgoing) {
//            offsetX = kJSAvatarImageSize - 4.0f;
//        }
//        
//        [self configureAvatarImageView:[[UIImageView alloc] init] forMessageType:type];
//    }
//    
//    CGRect frame = CGRectMake(bubbleX - offsetX,
//                              bubbleY,
//                              self.contentView.frame.size.width - bubbleX,
//                              self.contentView.frame.size.height - _timestampLabel.frame.size.height - _subtitleLabel.frame.size.height);
//    
//    WHBubbleView *bubbleView = [[WHBubbleView alloc] initWithFrame:frame
//                                                        bubbleType:type
//                                                   bubbleImageView:bubbleImageView];
//    
//    bubbleView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
//                                   | UIViewAutoresizingFlexibleHeight
//                                   | UIViewAutoresizingFlexibleBottomMargin);
//    
//    [self.contentView addSubview:bubbleView];
//    [self.contentView sendSubviewToBack:bubbleView];
//    _bubbleView = bubbleView;
//    
//    
//    [self setMessage:message];
//}


#pragma mark - UICollectionReusableView
- (void)prepareForReuse {
    [super prepareForReuse];
    self.bubbleView.textView.text = nil;
    self.timestampLabel.text = nil;
    self.avatarImageView = nil;
    self.subtitleLabel.text = nil;
}


- (void)setBackgroundColor:(UIColor *)color {
    [super setBackgroundColor:color];
    [self.contentView setBackgroundColor:color];
    [self.bubbleView setBackgroundColor:color];
}


#pragma mark - Setters
- (void)setText:(NSString *)text {
    self.bubbleView.textView.text = text;
}


- (void)setTimestamp:(NSDate *)date {
    self.timestampLabel.text = [NSDateFormatter localizedStringFromDate:date
                                                              dateStyle:NSDateFormatterMediumStyle
                                                              timeStyle:NSDateFormatterShortStyle];
}


- (void)setSubtitle:(NSString *)subtitle {
    self.subtitleLabel.text = subtitle;
}


- (void)setMessage:(id <WHMessageData>)message {
    [self setText:[message text]];
    [self setTimestamp:[message date]];
    [self setSubtitle:[message sender]];
}


- (void)setAvatarImage:(UIImage *)image {
    _avatarImageView.image = image;
}


#pragma mark - Getters
- (WHBubbleMessageType)messageType {
    return _bubbleView.type;
}


#pragma mark - Class methods
+ (CGFloat)neededHeightForBubbleMessageCellWithMessage:(id <WHMessageData>)message
                                        displaysAvatar:(BOOL)displaysAvatar
                                     displaysTimestamp:(BOOL)displaysTimestamp {
    CGFloat timestampHeight = displaysTimestamp ? kJSTimeStampLabelHeight : 0.0f;
    CGFloat avatarHeight = displaysAvatar ? kJSAvatarImageSize : 0.0f;
    CGFloat subtitleHeight = [message sender] ? kJSSubtitleLabelHeight : 0.0f;
    
    CGFloat subviewHeights = timestampHeight + subtitleHeight + kJSLabelPadding;
    
    CGFloat bubbleHeight = [WHBubbleView neededHeightForText:[message text]];
    
    CGFloat result =  subviewHeights + MAX(avatarHeight, bubbleHeight);
    return result;
}


#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.subtitleLabel) {
        self.subtitleLabel.frame = CGRectMake(kJSLabelPadding,
                                              self.contentView.frame.size.height - kJSSubtitleLabelHeight,
                                              self.contentView.frame.size.width - (kJSLabelPadding * 2.0f),
                                              kJSSubtitleLabelHeight);
    }
}


#pragma mark - Copying
- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:));
}


- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.bubbleView.textView.text];
    [self resignFirstResponder];
}


#pragma mark - Gestures
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    CGRect targetRect = [self convertRect:[self.bubbleView bubbleFrame]
                                 fromView:self.bubbleView];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    self.bubbleView.bubbleImageView.highlighted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
}


#pragma mark - Notifications
- (void)handleMenuWillHideNotification:(NSNotification *)notification {
    self.bubbleView.bubbleImageView.highlighted = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}


- (void)handleMenuWillShowNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}


#pragma mark - Memory
- (void)dealloc {
    _bubbleView = nil;
    _timestampLabel = nil;
    _avatarImageView = nil;
    _subtitleLabel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end