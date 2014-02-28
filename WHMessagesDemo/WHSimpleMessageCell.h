//
//  WHSimpleMessageCell.h
//  WHMessagesDemo
//
//  Created by Romain Boulay on 28/02/14.
//  Copyright (c) 2014 Wimdu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHSimpleMessageCell : UICollectionViewCell

@property (weak, nonatomic, readonly) IBOutlet UILabel *titleLabel;

+ (UINib*)cellNib;
+ (CGFloat)preferredHeightForCellWithMessage:(NSString *)message;

@end
