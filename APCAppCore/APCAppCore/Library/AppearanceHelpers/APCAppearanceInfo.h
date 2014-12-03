// 
//  APCAppearanceInfo.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface APCAppearanceInfo : NSObject

+ (void) setAppearanceDictionary: (NSDictionary*) appearanceDictionary;
+ (id) valueForAppearanceKey: (NSString*) key;
@end
