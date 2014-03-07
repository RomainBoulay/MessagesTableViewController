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

#import "WHDemoBubbleView.h"

#import "WHMessageInputView.h"
#import "WHDemoAvatarImageFactory.h"
#import "NSString+WHMessages.h"

#define kMarginTop 8.0f
#define kMarginBottom 4.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 8.0f
#define kBubblePaddingRight 35.0f


@interface WHDemoBubbleView ()
@property (assign, nonatomic, readwrite) WHBubbleMessageType type;
@end


@interface WHDemoBubbleView()

- (void)setup;

- (void)addTextViewObservers;
- (void)removeTextViewObservers;

+ (CGSize)textSizeForText:(NSString *)txt;
+ (CGSize)neededSizeForText:(NSString *)text;
+ (CGFloat)neededHeightForText:(NSString *)text;

@end


@implementation WHDemoBubbleView

@synthesize font = _font;


#pragma mark - Setup
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


#pragma mark - Initialization
- (instancetype)initWithFrame:(CGRect)frame
                   bubbleType:(WHBubbleMessageType)bubbleType
              bubbleImageView:(UIImageView *)bubbleImageView
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
        _type = bubbleType;
        
        bubbleImageView.userInteractionEnabled = YES;
        [self addSubview:bubbleImageView];
        _bubbleImageView = bubbleImageView;
        
        UITextView *textView = [[UITextView alloc] init];
        textView.font = [UIFont systemFontOfSize:16.0f];
        textView.textColor = [UIColor blackColor];
        textView.editable = NO;
        textView.userInteractionEnabled = YES;
        textView.showsHorizontalScrollIndicator = NO;
        textView.showsVerticalScrollIndicator = NO;
        textView.scrollEnabled = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.contentInset = UIEdgeInsetsZero;
        textView.scrollIndicatorInsets = UIEdgeInsetsZero;
        textView.contentOffset = CGPointZero;
        [self addSubview:textView];
        [self bringSubviewToFront:textView];
        _textView = textView;
        
        if ([_textView respondsToSelector:@selector(textContainerInset)]) {
            _textView.textContainerInset = UIEdgeInsetsMake(8.0f, 4.0f, 2.0f, 4.0f);
        }
        
        [self addTextViewObservers];
        
        //        NOTE: TODO: textView frame & text inset
        //        --------------------
        //        future implementation for textView frame
        //        in layoutSubviews : "self.textView.frame = textFrame;" is not needed
        //        when setting the property : "_textView.textContainerInset = UIEdgeInsetsZero;"
        //        unfortunately, this API is available in iOS 7.0+
        //        update after dropping support for iOS 6.0
        //        --------------------
    }
    return self;
}

- (void)dealloc
{
    [self removeTextViewObservers];
    _bubbleImageView = nil;
    _textView = nil;
}


- (void)configureBubbleType:(WHBubbleMessageType)bubbleType {
    self.type = bubbleType;
}


#pragma mark - KVO
- (void)addTextViewObservers
{
    [_textView addObserver:self
                forKeyPath:@"text"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [_textView addObserver:self
                forKeyPath:@"font"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [_textView addObserver:self
                forKeyPath:@"textColor"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
}


- (void)removeTextViewObservers
{
    [_textView removeObserver:self forKeyPath:@"text"];
    [_textView removeObserver:self forKeyPath:@"font"];
    [_textView removeObserver:self forKeyPath:@"textColor"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.textView) {
        if ([keyPath isEqualToString:@"text"]
            || [keyPath isEqualToString:@"font"]
            || [keyPath isEqualToString:@"textColor"]) {
            [self setNeedsLayout];
        }
    }
}


#pragma mark - Setters
- (void)setFont:(UIFont *)font
{
    _font = font;
    _textView.font = font;
}


#pragma mark - UIAppearance Getters
- (UIFont *)font
{
    if (_font == nil) {
        _font = [[[self class] appearance] font];
    }
    
    if (_font != nil) {
        return _font;
    }
    
    return [UIFont systemFontOfSize:16.0f];
}


#pragma mark - Getters
- (CGRect)bubbleFrame
{
    CGSize bubbleSize = [WHDemoBubbleView neededSizeForText:self.textView.text];
    
    return CGRectIntegral(CGRectMake((self.type == WHBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 0.0f),
                                     kMarginTop,
                                     bubbleSize.width,
                                     bubbleSize.height + kMarginTop));
}


#pragma mark - Layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bubbleImageView.frame = [self bubbleFrame];
    
    CGFloat textX = self.bubbleImageView.frame.origin.x;
    
    if (self.type == WHBubbleMessageTypeIncoming) {
        textX += (self.bubbleImageView.image.capInsets.left / 2.0f);
    }
    
    CGRect textFrame = CGRectMake(textX,
                                  self.bubbleImageView.frame.origin.y,
                                  self.bubbleImageView.frame.size.width - (self.bubbleImageView.image.capInsets.right / 2.0f),
                                  self.bubbleImageView.frame.size.height - kMarginTop);
    
    self.textView.frame = CGRectIntegral(textFrame);
}


#pragma mark - Bubble view
+ (CGSize)textSizeForText:(NSString *)txt
{
    CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.70f;
    CGFloat maxHeight = MAX([WHMessageTextView numberOfLinesForMessage:txt],
                            [txt numberOfLines]) * [WHMessageInputView textViewLineHeight];
    maxHeight += kJSAvatarImageSize;
    
    CGSize stringSize;
    CGRect stringRect = [txt boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{ NSFontAttributeName : [[WHDemoBubbleView appearance] font] }
                                          context:nil];
    
    stringSize = CGRectIntegral(stringRect).size;
    return CGSizeMake(roundf(stringSize.width), roundf(stringSize.height));
}

+ (CGSize)neededSizeForText:(NSString *)text
{
    CGSize textSize = [WHDemoBubbleView textSizeForText:text];
    
	return CGSizeMake(textSize.width + kBubblePaddingRight,
                      textSize.height + kPaddingTop + kPaddingBottom);
}

+ (CGFloat)neededHeightForText:(NSString *)text
{
    CGSize size = [WHDemoBubbleView neededSizeForText:text];
    return size.height + kMarginTop + kMarginBottom;
}

@end