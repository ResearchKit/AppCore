//
//  APCSegmentedButton.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSegmentedButton.h"

@interface APCSegmentedButton ()

@property (nonatomic, strong) NSArray * buttons; //Of UIButtons
@property (nonatomic, strong) UIColor * normalColor;
@property (nonatomic, strong) UIColor * highlightColor;

@end

@implementation APCSegmentedButton

- (instancetype)initWithButtons:(NSArray *)buttons normalColor: (UIColor*) normalColor highlightColor: (UIColor*) highlightColor
{
    self = [super init];
    if (self) {
        _buttons = buttons;
        [buttons enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
            button.tintColor = normalColor;
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }];
        _normalColor = normalColor;
        _highlightColor = highlightColor;
        _selectedIndex = -1;
    }
    return self;
}

- (void) buttonPressed: (UIButton*) button
{
    [self.buttons enumerateObjectsUsingBlock:^(UIButton* localButton, NSUInteger idx, BOOL *stop) {
        if ([localButton isEqual:button]) {
            localButton.tintColor = self.highlightColor;
            self.selectedIndex = idx;
        }
        else
        {
            localButton.tintColor = self.normalColor;
        }
    }];
    [self.delegate segmentedButtonPressed:button selectedIndex:self.selectedIndex];
}


@end
