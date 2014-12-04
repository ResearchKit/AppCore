// 
//  UIAlertController+Helper.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "UIAlertController+Helper.h"

@implementation UIAlertController (Helper)

+ (UIAlertController *) simpleAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okayAction];
    
    return alertController;
}

@end
