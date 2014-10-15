//
//  APCSegmentedButton.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APCSegmentedButton : NSObject

@property (nonatomic) NSInteger selectedIndex;

- (instancetype)initWithButtons:(NSArray *)buttons normalColor: (UIColor*) normalColor highlightColor: (UIColor*) highlightColor;

@end
