//
//  Enumerations.h
//  Avero
//
//  Created by Mahesh on 10/12/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#ifndef Avero_Enumerations_h
#define Avero_Enumerations_h

#import <CoreGraphics/CoreGraphics.h>
#import <CoreFoundation/CoreFoundation.h>

static inline CGFloat align(CGFloat value, CGFloat scale)
{
    return roundf(value * scale) / scale;
}

extern CGRect CGRectIntegralScaled(CGRect rect);
extern CGRect CGRectIntegralMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height);

extern CGPoint CGPointCenterIntegralScaled(CGPoint center, CGSize size);
extern CGPoint CGPointIntegralMake(CGFloat x, CGFloat y, CGSize size);

extern CGFloat IntegralMinYPadding(CGFloat y);
extern CGFloat IOS7Padding();
extern CGFloat IntegralUltraMinYPadding(CGFloat y);
extern CGFloat IOS7UltraPadding();
extern CGRect IntegralRevisedFrame(CGRect frame, BOOL updateHeight);

extern BOOL isIOS7();
extern BOOL isSmallerThanIOS6();

extern BOOL is4InchDisplay();

#endif
