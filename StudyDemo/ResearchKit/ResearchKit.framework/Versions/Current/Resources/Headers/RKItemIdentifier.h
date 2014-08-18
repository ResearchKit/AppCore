//
//  RKItemIdentifier.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * An RKItemIdentifier is a "."-separated set of strings.
 *
 */
@interface RKItemIdentifier : NSObject<NSCopying,NSSecureCoding>

-(instancetype)initWithString:(NSString*)string;

-(instancetype)initWithComponents:(NSArray*)components;

/**
 * Component strings of the identifier (separated by ".")
 */
-(NSArray*)components;

-(RKItemIdentifier*)itemIdentifierByAppendingComponent:(NSString*)component;

/**
 * String value of the identifier
 */
-(NSString*)stringValue;

@end
