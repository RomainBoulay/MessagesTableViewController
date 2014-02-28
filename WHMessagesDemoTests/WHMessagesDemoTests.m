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

#import <XCTest/XCTest.h>
#import "WHMessagesViewController.h"


@interface WHMessagesDemoTests : XCTestCase

@end



@implementation WHMessagesDemoTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInit
{
    WHMessagesViewController *vc = [[WHMessagesViewController alloc] init];
    XCTAssertNotNil(vc, @"View controller should not be nil");
}

@end
