// 
//  APCMedicationColor.m 
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
 
#import "APCMedicationColor.h"

@implementation APCMedicationColor

- (id) init
{
    self = [super init];

    if (self)
    {
        self.name = nil;
        self.argbValues = nil;
    }

    return self;
}

/**
 Reads a 0..255 value from the color dictionary.
 Clamps the value to 0..255.
 Returns that value.
 */
- (NSUInteger) safeColorComponentIntForEntryName: (NSString *) entryName
{
    NSUInteger result = 50;

    id thingy = self.argbValues [entryName];

    if (thingy != nil && [thingy isKindOfClass: [NSNumber class]])
    {
        NSInteger colorInt = [thingy integerValue];

        if (colorInt < 0) colorInt = 0;
        if (colorInt > 255) colorInt = 255;

        result = colorInt;
    }
    
    return result;
}

/**
 Reads a 0..255 value from the color dictionary.
 Clamps the value to 0..255.
 Returns (that value / 255).
 */
- (CGFloat) safeColorComponentFloatForEntryName: (NSString *) entryName
{
    NSUInteger colorInt = [self safeColorComponentIntForEntryName: entryName];
    CGFloat result = (CGFloat) colorInt / (CGFloat) 255;
    return result;
}

- (CGFloat) safeOpacityFloatForEntryName: (NSString *) entryName
{
    CGFloat result = 1;

    id thingy = self.argbValues [entryName];

    if (thingy != nil && [thingy isKindOfClass: [NSNumber class]])
    {
        result = [thingy floatValue];

        if (result < 0) result = 0;
        if (result > 1) result = 1;
    }

    return result;
}

- (NSUInteger) redInt   { return [self safeColorComponentIntForEntryName: @"red"];   }
- (NSUInteger) greenInt { return [self safeColorComponentIntForEntryName: @"green"]; }
- (NSUInteger) blueInt  { return [self safeColorComponentIntForEntryName: @"blue"];  }

- (CGFloat) red   { return [self safeColorComponentFloatForEntryName: @"red"];   }
- (CGFloat) green { return [self safeColorComponentFloatForEntryName: @"green"]; }
- (CGFloat) blue  { return [self safeColorComponentFloatForEntryName: @"blue"];  }

- (CGFloat) alpha { return [self safeOpacityFloatForEntryName: @"alpha"]; }

- (UIColor *) UIColor
{
    UIColor *result = [UIColor colorWithRed: self.red
                                      green: self.green
                                       blue: self.blue
                                      alpha: self.alpha];

    return result;
}

- (NSString *) description
{
    NSString *result = [NSString stringWithFormat: @"Color { name: %@, uniqueId: %d, rgba (%d, %d, %d, %3.2f) }",
                        self.name,
                        self.uniqueId.intValue,
                        (int) self.redInt,
                        (int) self.greenInt,
                        (int) self.blueInt,
                        self.alpha
                        ];

    return result;
}

@end




