//
//  WHCollectionViewFlowLayout.m
//
//  Created by Romain Boulay on 25/02/14.
//  Copyright (c) 2014 Wimdu. All rights reserved.
//

#import "WHCollectionViewFlowLayout.h"

@implementation WHCollectionViewFlowLayout

- (instancetype)init {
    self = [super init];
    if (self){
        [self setup];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}


- (void)setup {
    self.minimumLineSpacing = 0;
    self.sectionInset = UIEdgeInsetsZero;
}


- (CGSize)collectionViewContentSize {
    CGSize currentContentSize = [super collectionViewContentSize];
    CGSize minContentSize = [self customCollectionViewContentSize];
    
    CGSize newContentSize = CGSizeMake(currentContentSize.width,
                                       MAX(currentContentSize.height, minContentSize.height+1));
    return newContentSize;
}


- (CGSize)customCollectionViewContentSize {
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    
    CGFloat top = self.collectionView.contentInset.top;
    CGFloat bottom = self.collectionView.contentInset.bottom;
    
    CGFloat height = CGRectGetHeight(self.collectionView.frame)-top-bottom;
    return CGSizeMake(width, height);
}


@end
