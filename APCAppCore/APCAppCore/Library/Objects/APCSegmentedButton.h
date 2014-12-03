//
//  APCSegmentedButton.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol APCSegmentedButtonDelegate <NSObject>

@required
- (void) segmentedButtonPressed:(UIButton*) button selectedIndex: (NSInteger) selectedIndex;

@end

@interface APCSegmentedButton : NSObject

@property (nonatomic, weak) id<APCSegmentedButtonDelegate> delegate;
@property (nonatomic) NSInteger selectedIndex;

- (instancetype)initWithButtons:(NSArray *)buttons normalColor: (UIColor*) normalColor highlightColor: (UIColor*) highlightColor;

@end
