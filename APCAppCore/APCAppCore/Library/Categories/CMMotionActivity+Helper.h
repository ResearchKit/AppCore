//
//  CMMotionActivity+Helper.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

/**
 We track CoreMotion motion activity as one of our "passive data"
 objects, using our "passive data collector."  This category helps
 us convert a CMMotionActivity object into a human-readable and
 machine-parseable entry in a comma-separated-values file.
 
 The category contains a bunch of potentially-useful methods,
 including a typedef converting 6 Boolean fields into an enum.
 However, since no one *needs* that stuff outside this file,
 yet, I kept them inside.  Please feel free to expose them;
 they all work (we're using them when we call -csvColumValues).
 */
@interface CMMotionActivity (Helper)

+ (NSArray *) csvColumnNames;
- (NSArray *) csvColumnValues;

@end
