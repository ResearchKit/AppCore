//
//  APCAssertionHandler.m
//  APCAppCore
//
//  Created by Karthik Keyan on 9/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAssertionHandler.h"

@import UIKit;

@implementation APCAssertionHandler

- (void) handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format,... {
    [self exitGracefully];
}

- (void) handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format,... {
    [self exitGracefully];
}

- (void) exitGracefully {
    NSString *alertTitle = NSLocalizedString(@"Somthings Wrong!", @"");
    
    NSString *alertMessage = NSLocalizedString(@"Oops! Something went wrong. We are really sorry for the inconvenience. Since we are not taking any risk on your data, you may need to restart the app.", @"");
    
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Okay", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        exit(0);
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:dismissAction];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

@end
