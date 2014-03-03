//
//  WHSimpleMessageCell.m
//  WHMessagesDemo
//
//  Created by Romain Boulay on 28/02/14.
//  Copyright (c) 2014 Wimdu. All rights reserved.
//

#import "WHSimpleMessageCell.h"

#import "NSString+WHMessagesView.h"


#define kMarginTop 8.0f
#define kMarginBottom 4.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 8.0f
#define kBubblePaddingRight 35.0f


@interface WHSimpleMessageCell ()

@property (weak, nonatomic, readwrite) IBOutlet UILabel *titleLabel;

@end


@implementation WHSimpleMessageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


static UINib *cellNib;
+ (UINib*)cellNib
{
	if (cellNib)
		return cellNib;
	
	// Build cell nib
	cellNib = [UINib nibWithNibName:@"WHSimpleMessageCell" bundle:nil];
	
	return cellNib;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.opaque = YES;
}


+ (CGFloat)preferredHeightForCellWithMessage:(NSString *)message {
    CGFloat bubbleHeight = [self neededHeightForText:message];
    return bubbleHeight;
}



#pragma mark - Bubble view
+ (NSUInteger)maxCharactersPerLine
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 33 : 109;
}


+ (NSUInteger)numberOfLinesForMessage:(NSString *)text
{
    return (text.length / [self maxCharactersPerLine]) + 1;
}


+ (CGFloat)textViewLineHeight
{
    return 36.0f; // for fontSize 16.0f
}

+ (UIFont *)font {
    return [UIFont systemFontOfSize:16];
}


+ (CGSize)textSizeForText:(NSString *)txt
{
    CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.70f;
    CGFloat maxHeight = MAX([self numberOfLinesForMessage:txt],
                            [txt numberOfLines]) * [self textViewLineHeight];
    
    CGSize stringSize;
    
    if ([txt respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGRect stringRect = [txt boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{ NSFontAttributeName : [self font] }
                                              context:nil];
        
        stringSize = CGRectIntegral(stringRect).size;
    }
    else {
        stringSize = [txt sizeWithFont:[self font]
                     constrainedToSize:CGSizeMake(maxWidth, maxHeight)];
    }
    
    return CGSizeMake(roundf(stringSize.width), roundf(stringSize.height));
}


+ (CGSize)neededSizeForText:(NSString *)text
{
    CGSize textSize = [self textSizeForText:text];
    
	return CGSizeMake(textSize.width + kBubblePaddingRight,
                      textSize.height + kPaddingTop + kPaddingBottom);
}


+ (CGFloat)neededHeightForText:(NSString *)text
{
    CGSize size = [self neededSizeForText:text];
    return size.height + kMarginTop + kMarginBottom;
}

@end
