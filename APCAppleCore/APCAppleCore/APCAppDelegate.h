//
//  APCAppDelegate.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APCNetworkManager;
@interface APCAppDelegate : UIResponder <UIApplicationDelegate>

@property  (strong, nonatomic)  UIWindow                *window;

//APC Related Methods
@property (strong, nonatomic) APCNetworkManager * networkManager;

@end
