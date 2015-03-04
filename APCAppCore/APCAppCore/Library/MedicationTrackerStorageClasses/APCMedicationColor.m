//
//  APCMedicationColor.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
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




