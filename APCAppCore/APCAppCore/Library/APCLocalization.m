//
//  APCLocalization.m
//  APCAppCore
//
//  Created by Erin Mounts on 11/18/15.
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCLocalization.h"
#import "APCOnboarding.h"

NSBundle *APCBundle() {
    static NSBundle *__bundle;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __bundle = [NSBundle bundleForClass:[APCOnboarding class]];
    });
    
    return __bundle;
}

NSBundle *APCDefaultLocaleBundle() {
    static NSBundle *__bundle;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [APCBundle() pathForResource:[APCBundle() objectForInfoDictionaryKey:@"CFBundleDevelopmentRegion"] ofType:@"lproj"];
        __bundle = [NSBundle bundleWithPath:path];
    });
    
    return __bundle;
}
