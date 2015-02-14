//
//  ORKDefines_Private.h
//  ResearchKit
//
//  Created by John Earl on 12/12/14.
//  Copyright © 2014 Apple. All rights reserved.
//

#import <ResearchKit/ORKDefines.h>


ORK_EXTERN NSBundle *_ORKBundle() ORK_AVAILABLE_DECL;

#define ORKLocalizedString(key, comment) \
[_ORKBundle() localizedStringForKey:(key) value:@"" table:nil]

#define ORKDynamicCast(x, c) ((c *) ([x isKindOfClass:[c class]] ? x : nil))

