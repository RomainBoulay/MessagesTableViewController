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

#import "WHDemoAvatarImageFactory.h"
#import "UIImage+WHMessagesView.h"

CGFloat const kJSAvatarImageSize = 50.0f;

@implementation WHDemoAvatarImageFactory

+ (UIImage *)avatarImageNamed:(NSString *)filename
              croppedToCircle:(BOOL)croppedToCircle
{
    UIImage *image = [UIImage imageNamed:filename];
    return [self avatarImage:image croppedToCircle:croppedToCircle];
}

+ (UIImage *)avatarImage:(UIImage *)originalImage
         croppedToCircle:(BOOL)croppedToCircle
{
    return [originalImage imageAsCircle:croppedToCircle
                               withDiamter:kJSAvatarImageSize
                               borderColor:nil
                               borderWidth:0.0f
                              shadowOffSet:CGSizeZero];
}

+ (UIImage *)classicAvatarImageNamed:(NSString *)filename
                     croppedToCircle:(BOOL)croppedToCircle
{
    UIImage *image = [UIImage imageNamed:filename];
    return [image imageAsCircle:croppedToCircle
                       withDiamter:kJSAvatarImageSize
                       borderColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.8f alpha:1.0f]
                       borderWidth:1.0f
                      shadowOffSet:CGSizeMake(0.0f, 1.0f)];
}

@end
