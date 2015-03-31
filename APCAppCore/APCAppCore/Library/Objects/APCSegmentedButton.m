// 
//  APCSegmentedButton.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
        [buttons enumerateObjectsUsingBlock: ^(UIButton* button,
                                               NSUInteger __unused idx,
                                               BOOL * __unused stop) {
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
    [self.buttons enumerateObjectsUsingBlock: ^(UIButton* localButton,
                                                NSUInteger idx,
                                                BOOL * __unused stop) {
        if ([localButton isEqual:button]) {
            self.selectedIndex = idx;
            localButton.tintColor = self.highlightColor;
        }
        else
        {
            localButton.tintColor = self.normalColor;
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(segmentedButtonPressed:selectedIndex:)]) {
        [self.delegate segmentedButtonPressed:button selectedIndex:self.selectedIndex];
    }
    
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;

    for (NSUInteger i=0; i<self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        if (i == (NSUInteger)selectedIndex) {
            button.tintColor = self.highlightColor;
        } else {
            button.tintColor = self.normalColor;
        }
    }
    
}

@end
