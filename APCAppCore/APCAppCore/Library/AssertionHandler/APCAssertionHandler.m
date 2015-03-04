// 
//  APCAssertionHandler.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCAssertionHandler.h"

@import UIKit;

@implementation APCAssertionHandler

- (void) handleFailureInMethod: (SEL) __unused selector
                        object: (id) __unused object
                          file: (NSString *) __unused fileName
                    lineNumber: (NSInteger) __unused line
                   description: (NSString *) __unused format, ...
{
    [self exitGracefully];
}

- (void) handleFailureInFunction: (NSString *) __unused functionName
                            file: (NSString *) __unused fileName
                      lineNumber: (NSInteger) __unused line
                     description: (NSString *) __unused format, ...
{
    [self exitGracefully];
}

- (void) exitGracefully {
    NSString *alertTitle = NSLocalizedString(@"Somthings Wrong!", @"");
    
    NSString *alertMessage = NSLocalizedString(@"Oops! Something went wrong. We are really sorry for the inconvenience. Since we are not taking any risk on your data, you may need to restart the app.", @"");
    
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Okay", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * __unused action) {
        exit(0);
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:dismissAction];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

@end
