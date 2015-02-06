// 
//  UIView+Helper.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "UIView+Helper.h"
#import "UIImage+ImageEffects.h"

@implementation UIView (Helper)

- (CGFloat) top {
    return CGRectGetMinY(self.frame);
}

- (CGFloat) bottom {
    return CGRectGetMaxY(self.frame);
}

- (CGFloat) left {
    return CGRectGetMinX(self.frame);
}

- (CGFloat) right {
    return CGRectGetMaxX(self.frame);
}

- (CGFloat) width {
    return CGRectGetWidth(self.frame);
}

- (CGFloat) height {
    return CGRectGetHeight(self.frame);
}

- (CGFloat) innerWidth {
    return CGRectGetWidth(self.bounds);
}

- (CGFloat) innerHeight {
    return CGRectGetHeight(self.bounds);
}

- (CGFloat) horizontalCenter {
    return CGRectGetMidX(self.bounds);
}

- (CGFloat) verticalCenter {
    return CGRectGetMidY(self.bounds);
}

+ (void) frame:(CGRect *)frame animationDuration:(CGFloat *)duration animationCurve:(UIViewAnimationCurve *)animationCurve fromKeyboardNotification:(NSNotification *)notification {
    *duration = 0.25;
    
    if ([[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey]) {
        *duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    }
    
    *animationCurve = UIViewAnimationCurveLinear;
    
    if ([[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey]) {
        *animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    }
    
    if ([[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]) {
        [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:frame];
    }
}

- (UIImage *)blurredSnapshot
{
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    
    [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
    
    // Get the snapshot
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Now apply the blur effect using UIImageEffect category
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    
    // Or apply any other effects available in "UIImage+ImageEffects.h"
    // UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
    
    // Be nice and clean your mess up
    UIGraphicsEndImageContext();
    
    return blurredSnapshotImage;
}

- (UIImage *)blurredSnapshotDark
{
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    
    [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
    
    // Get the snapshot
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Now apply the blur effect using UIImageEffect category
    UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    
    // Or apply any other effects available in "UIImage+ImageEffects.h"
    // UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
    
    // Be nice and clean your mess up
    UIGraphicsEndImageContext();
    
    return blurredSnapshotImage;
}

@end
