//
//  WHSpringFlowLayout.h
//  UICollectionView-Spring-Demo
//
//  Created by Ash Furrow on 2013-07-31.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//  https://github.com/AshFurrow/ASHSpringyCollectionView


@import UIKit;

#import "WHCollectionViewFlowLayout.h"
#import "WHCollectionViewCancelableLayout.h"

/// The default resistance factor that determines the bounce of the collection. Default is 900.0f.
#define kScrollResistanceFactorDefault 900.0f;


/// A UICollectionViewFlowLayout subclass that, when implemented, creates a dynamic / bouncing scroll effect for UICollectionViews.
@interface WHSpringFlowLayout : WHCollectionViewFlowLayout <WHCollectionViewCancelableLayout>


/// The scrolling resistance factor determines how much bounce / resistance the collection has. A higher number is less bouncy, a lower number is more bouncy. The default is 900.0f.
@property (nonatomic, assign) CGFloat scrollResistanceFactor;

/// The dynamic animator used to animate the collection's bounce
@property (nonatomic, strong, readonly) UIDynamicAnimator *dynamicAnimator;


@property (assign, nonatomic) BOOL springinessEnabled;

- (void)setShouldUseFinalLayout:(BOOL)shouldUseFinalLayout;

@end
