//  Avero
//
//  Created by Mark Pospesel on 11/13/2012.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import "Enumerations.h"

#import <UIKit/UIKit.h>

CGRect CGRectIntegralScaled_i(CGRect rect, CGFloat scale)
{
    return CGRectMake(floorf(rect.origin.x * scale) / scale, floorf(rect.origin.y * scale) / scale, ceilf(rect.size.width * scale) / scale, ceilf(rect.size.height * scale) / scale);
}

CGRect CGRectIntegralScaled(CGRect rect)
{
    return CGRectIntegralScaled_i(rect, [[UIScreen mainScreen] scale]);
}

CGRect CGRectIntegralMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    return CGRectIntegralScaled_i(CGRectMake(x, y, width, height), [[UIScreen mainScreen] scale]);
}

CGPoint CGPointIntegralScaled_i(CGFloat x, CGFloat y, CGFloat scale)
{
    return CGPointMake(align(x, scale), align(y, scale));
}

CGPoint CGPointCenterIntegralScaled_i(CGFloat x, CGFloat y, CGSize size, CGFloat scale)
{
    BOOL oddWidth = align(size.width / 2, scale) * 2 != size.width;
    BOOL oddHeight = align(size.height / 2, scale) * 2 != size.height;
    CGPoint aligned = CGPointIntegralScaled_i(x, y, scale);
    if (!oddWidth && !oddHeight)
        return aligned;
    else
        return CGPointMake(aligned.x + (oddWidth? (0.5/scale) : 0), aligned.y + (oddHeight? (0.5/scale) : 0));
}

CGPoint CGPointCenterIntegralScaled(CGPoint center, CGSize size)
{
    return CGPointCenterIntegralScaled_i(center.x, center.y, size, [[UIScreen mainScreen] scale]);
}

extern CGPoint CGPointIntegralMake(CGFloat x, CGFloat y, CGSize size)
{
    return CGPointCenterIntegralScaled_i(x, y, size, [[UIScreen mainScreen] scale]);
}

CGFloat IOS7Padding()
{
    if(isIOS7())
        return 20.0f;
    
    return 0;
}

CGFloat IntegralMinYPadding(CGFloat y)
{
    if(isIOS7())
        return (y+20.0f);
        
    return y;
}

CGFloat IntegralUltraMinYPadding(CGFloat y)
{
    if(isIOS7())
        return (y+10.0f);
    
    return y;
}

CGFloat IOS7UltraPadding()
{
    if(isIOS7())
        return 10.0f;
    
    return 0;
}

CGRect IntegralRevisedFrame(CGRect frame, BOOL updateHeight)
{
    if(!isIOS7())
        return frame;
    
    CGRect newframe = frame;
    
    if(updateHeight)
    {
        newframe.size = CGSizeMake(newframe.size.width, newframe.size.height + IOS7Padding());
    }
    else
    {
        newframe.origin = CGPointMake(newframe.origin.x, newframe.origin.y + IOS7Padding());
    }
    
    return newframe;
}

BOOL isIOS7()
{
    return ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending);
}

BOOL isSmallerThanIOS6()
{
    return ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending);
}

BOOL is4InchDisplay()
{
    CGRect appliationFrame = [[UIScreen mainScreen]bounds];
    return (CGRectGetHeight(appliationFrame) == 568.0f);
}
