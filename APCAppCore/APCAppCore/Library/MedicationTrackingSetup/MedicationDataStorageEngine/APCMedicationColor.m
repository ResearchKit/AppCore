//
//  APCMedicationColor.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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

- (CGFloat) safeFloatForEntryName: (NSString *) entryName
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

- (CGFloat) red   { return [self safeFloatForEntryName: @"red"];   }
- (CGFloat) green { return [self safeFloatForEntryName: @"green"]; }
- (CGFloat) blue  { return [self safeFloatForEntryName: @"blue"];  }
- (CGFloat) alpha { return [self safeFloatForEntryName: @"alpha"]; }

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
    NSString *result = [NSString stringWithFormat: @"Color { name: %@, red: %3.2f, green: %3.2f, blue: %3.2f, alpha: %3.2f }",
                        self.name, self.red, self.green, self.blue, self.alpha
                        ];

    return result;
}

@end
