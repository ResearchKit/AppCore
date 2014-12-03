//
//  APCAppearanceInfo.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface APCAppearanceInfo : NSObject

+ (void) setAppearanceDictionary: (NSDictionary*) appearanceDictionary;
+ (id) valueForAppearanceKey: (NSString*) key;
@end
