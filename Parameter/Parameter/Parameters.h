//
//  Parameters.h
//  Parameters
//
//  Created by Karthik Keyan on 8/14/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ParametersValueChangeNotification;


@interface Parameters : NSObject

// Use [NSObject valueForKey:] to get value and [NSObject setValue:forKey:] to set values
- (NSArray *) allKeys;

// Clear all value and load values freshly from bundle
- (void) reset;

// Writes all changes into file
- (BOOL) save;

@end
