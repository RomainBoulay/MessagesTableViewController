//
//  WHCollectionViewCancelableLayout.h
//  WHMessagesDemo
//
//  Created by Romain Boulay on 08/04/14.
//  Copyright (c) 2014 Wimdu. All rights reserved.
//

@import Foundation;

@protocol WHCollectionViewCancelableLayout <NSObject>

@required
- (void)setShouldUseFinalLayout:(BOOL)shouldUseFinalLayout;

@end
