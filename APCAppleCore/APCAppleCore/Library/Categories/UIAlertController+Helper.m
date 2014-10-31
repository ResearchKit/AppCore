//
//  UIAlertController+Helper.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
