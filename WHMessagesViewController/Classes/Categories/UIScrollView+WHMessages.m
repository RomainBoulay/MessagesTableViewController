//
//  UIScrollView+WHMessages.m
//  WHMessagesDemo
//
//  Created by Romain Boulay on 07/03/14.
//  Copyright (c) 2014 Wimdu. All rights reserved.
//

#import "UIScrollView+WHMessages.h"


@implementation UIScrollView (WHMessages)

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint bottomOffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
    [self setContentOffset:bottomOffset animated:animated];
}


@end
