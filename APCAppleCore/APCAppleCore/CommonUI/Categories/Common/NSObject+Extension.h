//
//  NSObject+NSObject_Extension.h
//  parentgini
//
//  Created by Karthik Keyan B on 9/25/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AppDelegate;

@interface NSObject (Extension)

+ (AppDelegate *) appDelegate;

+ (BOOL) isNilOrNull:(id)obj;

+ (void) performInMainThread:(void (^)(void))block;

+ (void) performInThread:(void (^)(void))block;

- (void) performSelector:(SEL)selector withObject:(id)argument1 object:(id)argument2 afterDelay:(NSTimeInterval)delay;

@end
